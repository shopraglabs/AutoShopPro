#!/usr/bin/env python3
"""
update_build_log.py — Append a new session entry to AutoShopPro_Build_Log.docx
Usage: python3 docs/update_build_log.py

Reads session data from the SESSION dict below, then inserts the entry
directly after the "Build Sessions" heading in the document.

Requires: pip3 install python-docx
"""

from docx import Document
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
import os

DOCX_PATH = os.path.join(os.path.dirname(__file__), 'AutoShopPro_Build_Log.docx')

# ── Fill this in at the end of each session ───────────────────────────────────
SESSION = {
    'heading':  'Session 15 — v0.10.3 Buttoned Up',
    'date':     'March 25, 2026',
    'version':  'v0.10.3 Buttoned Up',
    'number':   '15',
    'built': [
        'MIT LICENSE — added standard MIT license file at repo root (copyright ShopRag Labs)',
        'Money as integer cents — all price/cost/rate columns in the database converted from REAL (floating point) to INTEGER (cents); eliminates floating-point rounding errors on financial totals; schema v26 migration converts existing data via ROUND(col * 100)',
        'money.dart utility — new lib/core/utils/money.dart with toCents(), fromCents(), formatMoney() (omits .00 in UI), and formatMoneyFull() (always 2 decimal places for PDFs)',
        'Foreign key constraints — all FK columns annotated with .references() and onDelete cascade/setNull; PRAGMA foreign_keys = ON enabled at DB open time',
        'Transaction safety — deleteCustomer, deleteVehicle, deleteEstimate, deleteServiceTemplate, and clearAllCustomerData all wrapped in transaction() for atomicity',
        'Strict linting — analysis_options.yaml upgraded with production-strict rules: missing_return as error, avoid_print, avoid_dynamic_calls, unawaited_futures, always_declare_return_types, and more',
    ],
    'bugs': [
        'All price/cost/rate values were stored as REAL (floating point) in SQLite, causing rounding errors on financial totals (e.g. $120.00 stored as 119.99999... cents)',
        'No foreign key enforcement — deleting a parent record could silently leave orphaned children with no referential integrity check at the DB level',
        'Multi-step delete operations (cascade delete customer + all children) were not atomic — a crash mid-way could leave data in a partial state',
    ],
    'files_added': [
        'LICENSE — MIT license (ShopRag Labs)',
        'lib/core/utils/money.dart — toCents(), fromCents(), formatMoney(), formatMoneyFull()',
    ],
    'files_modified': [
        'lib/database/database.dart — schema v26, money columns REAL→INTEGER, FK .references() annotations, PRAGMA foreign_keys = ON, transaction() wrapping on 5 DAO delete methods',
        'lib/features/estimates/line_item_form_screen.dart — toCents()/fromCents() on all read/write paths, template part sellPrice conversion',
        'lib/features/estimates/estimate_detail_screen.dart — fromCents() on all display and total calculations',
        'lib/features/estimates/estimate_list_screen.dart — fromCents() in subtotal fold',
        'lib/features/inventory/part_form_screen.dart — toCents()/fromCents() on cost and sellPrice',
        'lib/features/inventory/part_list_screen.dart — formatMoney() for sellPrice display',
        'lib/features/settings/settings_screen.dart — toCents()/fromCents() on labor rate and markup rule min/max cost',
        'lib/features/service_templates/service_template_form_screen.dart — toCents()/fromCents() on defaultRate',
        'lib/features/invoices/invoice_service.dart — fromCents() on all unitPrice calculations and PDF display in all 3 invoice builders',
        'lib/features/repair_orders/ro_detail_screen.dart — fromCents() on all unitPrice display and total calculations',
        'lib/features/data/data_service.dart — toCents() on CSV import inserts, fromCents() on CSV export display',
        'analysis_options.yaml — upgraded to production-strict lint rules',
        'docs/module_plan.md — v0.10.3 section added',
        'README.md — v0.10.3 entry',
        'CLAUDE.md — version bumped to v0.10.3',
    ],
    'next': 'Invoice list + detail screens for closed ROs, or payments module.',
}
# ──────────────────────────────────────────────────────────────────────────────


def add_bold_label(para, label):
    run = para.add_run(label)
    run.bold = True


def add_kv_row(doc, label, value):
    """Add a label: value line (bold label, normal value)."""
    para = doc.add_paragraph(style='Normal')
    add_bold_label(para, f'{label}: ')
    para.add_run(value)


def add_section(doc, label, items):
    """Add a bold label followed by bulleted items."""
    if not items:
        return
    para = doc.add_paragraph(style='Normal')
    add_bold_label(para, label)
    for item in items:
        doc.add_paragraph(item, style='List Bullet')


def insert_session(session):
    doc = Document(DOCX_PATH)

    # Find the paragraph index of "Build Sessions" heading
    insert_idx = None
    for i, para in enumerate(doc.paragraphs):
        if 'Build Sessions' in para.text:
            insert_idx = i
            break

    if insert_idx is None:
        print("ERROR: Could not find 'Build Sessions' heading in document.")
        return

    # python-docx can't insert paragraphs at an arbitrary position directly,
    # so we use the underlying XML to splice in after the target paragraph.
    from docx.oxml.ns import qn
    from docx.oxml import OxmlElement
    import copy

    body = doc.element.body
    all_paras = body.findall(f'.//{qn("w:p")}')
    target_para_el = doc.paragraphs[insert_idx]._element

    def make_para(text, bold=False, style_id=None):
        p = OxmlElement('w:p')
        if style_id:
            pPr = OxmlElement('w:pPr')
            pStyle = OxmlElement('w:pStyle')
            pStyle.set(qn('w:val'), style_id)
            pPr.append(pStyle)
            p.append(pPr)
        r = OxmlElement('w:r')
        if bold:
            rPr = OxmlElement('w:rPr')
            b = OxmlElement('w:b')
            rPr.append(b)
            r.append(rPr)
        t = OxmlElement('w:t')
        t.text = text
        t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        r.append(t)
        p.append(r)
        return p

    def make_bullet(text):
        p = OxmlElement('w:p')
        pPr = OxmlElement('w:pPr')
        pStyle = OxmlElement('w:pStyle')
        pStyle.set(qn('w:val'), 'ListBullet')
        pPr.append(pStyle)
        p.append(pPr)
        r = OxmlElement('w:r')
        t = OxmlElement('w:t')
        t.text = text
        t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        r.append(t)
        p.append(r)
        return p

    # Build the block of new XML elements (in reverse order, each inserted after target)
    blocks = []

    # Next session
    blocks.append(make_para('Next session'))
    blocks.append(make_para(session['next']))

    # Files modified
    if session['files_modified']:
        blocks.append(make_para('Files modified', bold=True))
        for f in session['files_modified']:
            blocks.append(make_bullet(f))

    # Files added
    if session['files_added']:
        blocks.append(make_para('Files added', bold=True))
        for f in session['files_added']:
            blocks.append(make_bullet(f))

    # Bugs
    if session['bugs']:
        blocks.append(make_para('Bugs fixed', bold=True))
        for b in session['bugs']:
            blocks.append(make_bullet(b))

    # What was built
    if session['built']:
        blocks.append(make_para('What was built', bold=True))
        for item in session['built']:
            blocks.append(make_bullet(item))

    # Metadata rows
    blocks.append(make_para(f"Session: {session['number']}"))
    blocks.append(make_para(f"Version: {session['version']}"))
    blocks.append(make_para(f"Date: {session['date']}"))

    # Section heading
    blocks.append(make_para(session['heading'], style_id='Heading2'))

    # Blank line before heading
    blocks.append(make_para(''))

    # Insert all blocks after the "Build Sessions" heading (reversed so order is correct)
    ref = target_para_el
    for block in blocks:
        ref.addnext(block)

    doc.save(DOCX_PATH)
    print(f"✅ Session entry '{session['heading']}' added to {DOCX_PATH}")


def read_build_log():
    """Print the build log contents to the terminal."""
    doc = Document(DOCX_PATH)
    for para in doc.paragraphs:
        text = para.text.strip()
        if not text:
            continue
        style = para.style.name if para.style else ''
        if 'Heading 1' in style:
            print(f'\n=== {text} ===')
        elif 'Heading 2' in style:
            print(f'\n--- {text} ---')
        elif 'List' in style:
            print(f'  • {text}')
        else:
            print(text)


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'read':
        read_build_log()
    else:
        insert_session(SESSION)

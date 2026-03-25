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
    'heading':  'Session 14 — v0.10.2 Buttoned Up',
    'date':     'March 25, 2026',
    'version':  'v0.10.2 Buttoned Up',
    'number':   '14',
    'built': [
        'Cascade deletes — deleting a customer now removes all linked vehicles, estimates, line items, and ROs; deleting a vehicle removes its estimates and ROs; deleting an estimate removes its line items; deleting a service template removes its linked parts',
        'Archive vendors — replaced hard delete with soft-delete (isArchived flag, schema v25); archived vendors hidden from lists and pickers but all existing records are preserved',
        'Archive technicians — replaced hard delete with soft-delete (isArchived flag, schema v25); archived technicians hidden from lists and pickers but existing ROs that reference them are preserved',
        'RO tax rate fix — RO detail and invoice PDFs now read taxRate from the linked estimate instead of defaulting to 0%',
        'Other items in invoices — OTHER line items were missing from both Itemized and Simple invoice PDFs; now included in their own OTHER section',
        'Invoice date fix — invoice date was always the PDF generation date (today); now uses the RO service date (or createdAt as fallback)',
        'Stock floor — inventory stock can no longer go negative; deductions are clamped to 0 on both individual toggle and Complete All',
        'Complete All improvements — added confirmation dialog showing item count; declined items are now correctly filtered out',
        'Estimate list order — estimates now sorted newest-first (by id DESC)',
        'Search enhancements — vehicle year is now included in vehicle search; typing an RO number (e.g. "RO 42" or just "42") finds the matching repair order',
        'Router edit loader fix — all 8 edit loader widgets now cache their database future in initState instead of creating it in build(); prevents repeated DB queries on every rebuild',
    ],
    'bugs': [
        'Deleting a customer left orphaned vehicles, estimates, line items, and ROs in the database',
        'Vendors and technicians could be permanently deleted, breaking historical line items and ROs that referenced them',
        'RO detail showed $0.00 tax even when the estimate had a tax rate set',
        'Invoice PDFs omitted all "Other" line items entirely',
        'Invoice date showed today\'s date instead of the RO service date',
        'Marking parts done on an RO could push stock quantity below zero',
        'Complete All marked declined items as done and tried to deduct their stock',
        'Estimate list showed oldest estimates first',
        'Searching for a vehicle by year returned no results',
        'RO number search did not work',
        'Edit loader widgets (customer, vehicle, vendor, etc.) re-queried the database on every UI rebuild',
    ],
    'files_added': [],
    'files_modified': [
        'lib/database/database.dart — isArchived on vendors and technicians (schema v25), cascade deletes, watchAllVendors/watchAllTechnicians filter archived, archiveVendor/archiveTechnician methods, estimate list orderBy, search enhancements',
        'lib/features/vendors/vendor_form_screen.dart — archive instead of delete, contextMenuBuilder on fields',
        'lib/features/vendors/vendor_list_screen.dart — archive instead of delete in context menu and dialog',
        'lib/features/technicians/technician_form_screen.dart — archive instead of delete, contextMenuBuilder on fields',
        'lib/features/invoices/invoice_service.dart — OTHER section in both PDF builders, invoice date from serviceDate',
        'lib/features/repair_orders/ro_detail_screen.dart — tax rate from linked estimate, Complete All confirmation + declined filter, stock floor clamping',
        'lib/features/customers/customers_provider.dart — added customerProvider and vehicleProvider StreamProvider.family',
        'lib/router.dart — all 8 edit loaders converted to cached futures in initState or StreamProvider.when()',
        'docs/module_plan.md — v0.10.2 audit section added',
        'README.md — v0.10.2 entry added',
        'CLAUDE.md — version bumped to v0.10.2',
    ],
    'next': 'Invoice screens (list + detail) for closed ROs, or payments module.',
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

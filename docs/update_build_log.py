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
    'heading':  'Session 17 — v0.12.0 Full Picture',
    'date':     'March 29, 2026',
    'version':  'v0.12.0 Full Picture',
    'number':   '17',
    'built': [
        'Service date bug root-cause fix — Drift stores DateTimes as UNIX seconds; prior migrations v27–v30 wrote millisecond values causing dates to display as year ~58,023; fixed in schema v31 with correct local-timezone second values for all 12 existing ROs; safety net clears any remaining out-of-range values',
        'Service date UX — read-only on RO detail screen; editable from within estimate detail via roForEstimateProvider (tappable blue row, date picker, 2-year future limit)',
        'Dashboard "Today" and "This Week" sections — invoices closed, revenue, and gross profit for each period',
        'Dashboard "This Year" section — invoices closed, revenue, gross profit, and car count for the current calendar year; uses Apple indigo color (#5856D6)',
        'Gross profit added to every dashboard section — revenue minus known part costs; labor treated as 100% margin since technician wages are not tracked',
        '"View PDF" option — first item in invoice action sheet (isDefaultAction: true) and right-click context menu; saves to temp file and opens in Preview with no print dialog',
        'Sidebar "Repair Orders" renamed to "Records"; Invoices moved inside the Records hub screen alongside Customers, Estimates, Repair Orders, Vendors; "Payments" item added to sidebar as future placeholder',
        'Records hub screen order updated: Customers → Estimates → Repair Orders → Invoices → Vendors',
        'README backfilled v0.10.2 entry that was missing between v0.10.3 and v0.10.1',
    ],
    'bugs': [
        'All service dates displayed as "—" — root cause: Drift reads stored integer as seconds × 1000 but migrations wrote millisecond timestamps, resulting in DateTime year ~58,023 which _fmtDate rejected as out of range',
        'Edit buttons on RO detail were confusing — "Edit Record" navigated to estimate; simplified to single "Edit Line Items" → estimate flow; service date now editable from within estimate detail',
    ],
    'files_added': [],
    'files_modified': [
        'lib/database/database.dart — schemaVersion 30→31; migration v31 corrects service_date and created_at for ROs 1–12 to proper UNIX seconds; safety net clears values > 4102444800',
        'lib/features/repair_orders/ro_detail_screen.dart — service date row read-only; edit buttons simplified',
        'lib/features/estimates/estimate_detail_screen.dart — service date row added (editable via roForEstimateProvider); _pickServiceDate() with 2-year future limit',
        'lib/features/dashboard/dashboard_provider.dart — added closedThisYear, revenueThisYear, carCountThisYear, grossProfitToday, grossProfitThisWeek, grossProfitThisMonth, grossProfitThisYear, grossProfitAllTime to DashboardStats; year date range; GP calculation per RO',
        'lib/features/dashboard/dashboard_screen.dart — Today, This Week, This Year sections added; Gross Profit row in every section',
        'lib/features/invoices/invoice_service.dart — _handleView() saves to temp and opens in Preview; "View PDF" added to action sheet and right-click menu',
        'lib/features/repair_orders/repair_orders_screen.dart — title "Records"; Invoices row added; order: Customers, Estimates, Repair Orders, Invoices, Vendors',
        'lib/main.dart — sidebar "Repair Orders"→"Records"; "Payments" item added; _selectedIndex cleaned up',
        'docs/module_plan.md — v0.12.0 section added; dashboard KPI items updated',
        'README.md — v0.12.0 entry added; v0.10.2 entry backfilled',
        'CLAUDE.md — version bumped to v0.12.0',
    ],
    'next': 'Payment processing (Stripe/Square), invoice detail standalone screen, or technician performance dashboard.',
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

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
    'heading':  'Session 13 — v0.10.0 Buttoned Up',
    'date':     'March 23, 2026',
    'version':  'v0.10.0 Buttoned Up',
    'number':   '13',
    'built': [
        'Scrollbars on vendor, technician, and part list screens — CupertinoScrollbar wraps each ListView/CustomScrollView so the scroll indicator appears on desktop',
        'Hover cursors on list rows — MouseRegion with SystemMouseCursors.click wraps every tappable row in vendor, technician, and part list screens',
        'Desktop dropdown context menus — replaced CupertinoActionSheet with showContextMenu on macOS/Windows for: approval badge on estimate line items, category picker on part form, invoice actions on estimate detail and RO detail',
        'After saving a new vehicle → navigate to vehicle detail — vehicle_form_screen.dart captures the returned newId and calls context.go() to the vehicle detail page instead of popping back to the customer page',
        'Labor form field order — Labor Name is now the first field (with autofocus), Labor Description second; makes naming the service the first action when adding labor',
        'Typing in Total updates Hours — previously updating the Total box would back-calculate Rate; now it back-calculates Hours so Rate stays fixed as entered',
        'Duplicate customer concerns removed from estimate detail header — the complaint text was showing both in the customer/vehicle header card and in the CUSTOMER CONCERN section; header copy removed',
        'Customer concern editable after entry — CUSTOMER CONCERN section header now has an Add/Edit blue link on the right; tapping it opens a dialog with a multi-line text field to set or change the complaint',
        'Vehicle history section on vehicle detail page — _VehicleHistorySection widget shows a chronological list of estimates and ROs for that vehicle; if an estimate has a linked RO only the RO row is shown (same deduplication logic as customer detail)',
        '"Complete All Services" button on open ROs — shown in ACTIONS when any line item is unchecked; tapping it marks every item done and deducts inventory stock in one operation',
        'Simplified RO status: Open → Closed only — removed In Progress and Completed statuses; "Close Repair Order" is now the single advancement action; RO list filters updated to All / Open / Closed',
        'Edit Repair Order consolidated — replaced separate "Edit Estimate" and "Edit Record" buttons with a single "Edit Repair Order" row navigating to the linked estimate',
        '"Other" line item type — new type alongside labor and parts; form has Name (required), Description, Cost, and List Price fields; displayed in an OTHER section on estimate and RO detail screens; name shown as title via laborName field',
        'RO invoice comment — INVOICE COMMENT section on every RO detail with Add/Edit link; comment text is printed on both Itemized and Simple Invoice PDFs between the totals and the thank-you footer',
        'Schema v23 migration — comment column added to repair_orders table; database.g.dart regenerated',
        'Apply Template removed from ADD ITEMS — redundant now that template access is built into Add Labor via the Operation picker',
    ],
    'bugs': [],
    'files_added': [],
    'files_modified': [
        'lib/database/database.dart — comment column on RepairOrders; schema v23; migration v23; watchEstimatesForVehicle and watchRepairOrdersForVehicle stream methods',
        'lib/database/database.g.dart — regenerated via build_runner',
        'lib/features/vendors/vendor_list_screen.dart — CupertinoScrollbar; MouseRegion hover cursor on rows',
        'lib/features/technicians/technician_list_screen.dart — CupertinoScrollbar; MouseRegion hover cursor on rows',
        'lib/features/inventory/part_list_screen.dart — CupertinoScrollbar; MouseRegion hover cursor on rows',
        'lib/features/inventory/part_form_screen.dart — category picker uses showContextMenu on desktop, CupertinoActionSheet on mobile',
        'lib/features/vehicles/vehicle_form_screen.dart — on insert, captures newId and navigates to vehicle detail instead of popping',
        'lib/features/vehicles/vehicle_detail_screen.dart — _VehicleHistorySection; _VehicleHistoryRow; watchEstimatesForVehicle + watchRepairOrdersForVehicle streams',
        'lib/features/estimates/estimate_detail_screen.dart — duplicate concerns removed from header; customer concern Add/Edit link + dialog; Convert to RO moved to ACTIONS; otherLines section; Add Other button; Apply Template removed; approval badge uses showContextMenu on desktop; _LineItemRow shows laborName for other type',
        'lib/features/estimates/line_item_form_screen.dart — _isOther getter; Other form fields (Name/Description/Cost/List Price); Other save logic; Labor Name first in labor form; total→hours sync',
        'lib/features/repair_orders/ro_detail_screen.dart — status simplified to Open/Closed; Complete All button; Edit Repair Order consolidated; otherLines section; _RoLineItemRow shows laborName for other type; INVOICE COMMENT section + _editComment dialog; _generateInvoice passes ro.comment',
        'lib/features/repair_orders/ro_list_screen.dart — filters All/Open/Closed; statusLabel/statusColor simplified',
        'lib/features/customers/customer_detail_screen.dart — roDot/roStatusLabel simplified to Open/Closed',
        'lib/features/invoices/invoice_service.dart — comment param in buildInvoicePdf, buildSimpleInvoicePdf, _buildBytes, _handleSave/Print/Email, showInvoiceActions; comment printed before footer in both PDF layouts',
        'lib/router.dart — line-items/other route added',
    ],
    'next': 'Invoice PDF from closed RO (Module 3), or continue UX polish.',
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

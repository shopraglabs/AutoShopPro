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
    'heading':  'Session 6 — v0.5.0 Sign-Off',
    'date':     'March 22, 2026',
    'version':  'v0.5.0 Sign-Off',
    'number':   '6',
    'built': [
        'Unit cost + markup % / markup $ / unit list price fields on Add Part form — editing markup % auto-updates markup $ and vice versa (schema v10)',
        'Parts can be linked to a labor line via a labor picker on the Add Part form (parentLaborId, schema v10)',
        'Parts grouped under their linked labor sub-header in estimate detail and RO detail screens',
        'Customer complaint field added to new estimate form and displayed in estimate/RO detail header (schema v11)',
        'Internal note field on customer form — shown on customer detail, auto-populates estimate internal note when customer is picked (schema v12)',
        'License plate shown in vehicle picker dropdown and selected row on estimate form',
        '"NO PLATE" stored when plate field is left empty on vehicle save; displayed as-is in all pickers, estimate headers, and RO headers',
        'Mark items done on repair order — checkmark circle toggle per line item when RO is not closed (schema v12)',
        'Edit Estimate link added to non-closed RO detail screens',
        '"+ New Customer" / "+ New Vehicle" / "+ Add Vendor" rows added to all picker sheets so you can create records without leaving the form',
        'contextMenuBuilder added to all CupertinoTextFields for right-click copy/cut/paste on macOS (standing rule saved to memory)',
        'Partial estimate approval — tap approval circle badge on any line item to approve or decline it (schema v13, approvalStatus column)',
        'Declined items display with strikethrough + gray text on estimate; excluded entirely from repair order',
        'Totals section shows "X items declined −$Y.YY" footnote in red when items are declined',
        'Migration pattern corrected from from == N to from < N with PRAGMA guards to safely handle devices jumping multiple versions',
    ],
    'bugs': [
        'Migration blocks used from == N which would skip migrations on devices jumping multiple schema versions — corrected to from < N throughout',
    ],
    'files_added': [],
    'files_modified': [
        'lib/database/database.dart — added unitCost, parentLaborId (v10), customerComplaint (v11), internalNote, isDone (v12), approvalStatus (v13); bumped schemaVersion to 13; fixed all migration blocks to from < N',
        'lib/features/estimates/line_item_form_screen.dart — unit cost + markup % / $ / list fields with auto-sync; labor picker row; vendorSheet with + Add Vendor',
        'lib/features/estimates/estimate_form_screen.dart — customer complaint field; internal note field; _PickerSheet updated with createNew and sublabel support; vehicle picker shows plate',
        'lib/features/estimates/estimate_detail_screen.dart — approval badge on each row; action sheet to approve/decline/reset; declined items styled with strikethrough; totals footnote for declined; declinedTotal excluded from subtotal',
        'lib/features/repair_orders/ro_detail_screen.dart — declined items filtered out; mark-done checkmark toggle; Edit Estimate action row; customer complaint in header',
        'lib/features/customers/customer_form_screen.dart — internal note field added',
        'lib/features/customers/customer_detail_screen.dart — internal note shown in CONTACT section',
        'lib/features/vehicles/vehicle_form_screen.dart — NO PLATE stored when plate field is empty',
        'lib/features/estimates/estimate_detail_screen.dart — removed NO PLATE display filter; plate shown as-is',
        'lib/features/estimates/estimate_form_screen.dart — removed NO PLATE display filters in picker and selected row',
        'lib/features/repair_orders/ro_detail_screen.dart — removed NO PLATE display filter',
    ],
    'next': 'Begin Module 3 — Invoice PDF generation from a closed repair order.',
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

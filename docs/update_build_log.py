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
    'heading':  'Session 11 — v0.9.0 Dialed In',
    'date':     'March 22, 2026',
    'version':  'v0.9.0 Dialed In',
    'number':   '11',
    'built': [
        'Add Part button under each labor row — estimate detail screen shows an indented "Add Part" row beneath every labor line; tapping it opens the Add Part form with parentLaborId pre-linked so the part groups under that labor entry automatically',
        'Customer concern on estimate detail — CUSTOMER CONCERN section now displays on the estimate detail screen (bullet list, one per complaint); previously it was only saved to the DB and sent to PDFs',
        'Template linked parts as opt-in dropdown — when a service template is applied to an estimate, linked parts appear in a collapsible picker sheet (all unchecked by default); user selects which parts to add and sets quantities before confirming',
        'Linked parts dropdown in Add Labor form — when a service template is chosen via the Operation picker on the Add Labor form, a collapsible LINKED PARTS section appears below with checkboxes and qty fields; selected parts are inserted as part lines linked to the new labor entry on save',
        'Part number on line items (schema v21) — parts line items now have an optional Part # field; shown as a gray subtitle on estimate and RO detail rows; auto-filled from inventory when a catalog part is picked',
        'Line preview labor+parts total — the live preview at the bottom of Add Labor shows a three-row breakdown: labor cost / parts cost / total when linked template parts are present',
        'New estimate from vehicle page uses form — tapping New Estimate on the vehicle detail screen now navigates to the New Estimate form with customer and vehicle pre-filled, so the user can add complaints before saving',
        'Number fields select-all on tap, text fields do not — corrected across line_item_form_screen, part_form_screen, and service_template_form_screen; only numeric keyboard fields get the select-all onTap behavior',
        'Other category added to parts inventory — inventory parts can now be categorised as Other in addition to Part / Fluid / Filter / Chemical',
    ],
    'bugs': [
        'Template linked parts all checked by default — fixed: parts now start unchecked in the picker sheet',
        'Service template not loading on first tap — fixed: added ref.watch(serviceTemplatesProvider) in build() to warm the stream before the callback fires',
    ],
    'files_added': [],
    'files_modified': [
        'lib/database/database.dart — added partNumber column to EstimateLineItems (schema v21); migration v21; watchEstimatesForCustomer, watchRepairOrdersForCustomer stream queries',
        'lib/database/database.g.dart — regenerated via build_runner',
        'lib/features/estimates/estimate_detail_screen.dart — Add Part button under each labor row; CUSTOMER CONCERN section; _TemplatePartsSheet with unchecked-by-default parts; ref.watch(serviceTemplatesProvider) to warm stream',
        'lib/features/estimates/estimate_form_screen.dart — preCustomerId / preVehicleId params; initState loads and pre-fills customer+vehicle when opened from vehicle page',
        'lib/features/estimates/line_item_form_screen.dart — parentLaborId constructor param; _linkedTemplateParts list with collapsible dropdown UI; _LinkedPartQtyRow widget; _LinePreview updated with labor+parts+total breakdown; selectAllOnTap param on _Field; numeric fields pass selectAllOnTap: true; partNumber controller wired through save/edit',
        'lib/features/inventory/part_form_screen.dart — Other added to categories; _field helper select-all made conditional on keyboardType',
        'lib/features/service_templates/service_template_form_screen.dart — _field helper select-all made conditional on keyboardType; linked parts quantity removed (set at estimate time); partNumber shown in subtitle',
        'lib/features/vehicles/vehicle_detail_screen.dart — _newEstimate navigates to form with query params instead of silently inserting',
        'lib/router.dart — line-items/part route reads parentLaborId query param; estimates/new route reads customerId and vehicleId query params',
        'lib/features/customers/customer_detail_screen.dart — _HistorySection showing estimates and ROs per customer',
        'lib/features/repair_orders/repair_orders_screen.dart — removed Technicians row (moved to Settings)',
        'lib/features/settings/settings_screen.dart — added PEOPLE section with Technicians navigation row',
        'lib/features/inventory/part_list_screen.dart — right-click context menu with Edit/Delete on each row',
        'lib/features/invoices/invoice_service.dart — buildEstimatePdf, showEstimateActions; customerComplaint bullet list in all PDF builders',
    ],
    'next': 'Continue UX polish or begin Module 3 — payments and invoice PDF from closed RO.',
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

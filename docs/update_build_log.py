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
    'heading':  'Session 10 — v0.8.0 Linked Up',
    'date':     'March 22, 2026',
    'version':  'v0.8.0 Linked Up',
    'number':   '10',
    'built': [
        'Labor name as title — labor lines in estimate detail, RO detail, and invoice PDFs now show the template name (e.g. "Oil Change") as a bold title with the detailed description as a smaller subtitle below',
        'Hours × rate = total live calc — service template form and line item form both have Cost | Markup or Hours | Rate | Total rows where all three fields are editable; changing any field recalculates the others with bidirectional sync',
        'Select-all on tap — tapping any number text field now selects all existing text so you can type a new value without deleting manually; applied consistently across all forms app-wide',
        'Smart money formatting — UI screens omit .00 cents (e.g. $90 not $90.00) but preserve real cents (e.g. $13.50); invoice PDFs always show two decimal places as official documents',
        'Part categories — inventory parts now have a category field (Part / Fluid / Filter / Chemical); action sheet picker on the form; blue badge shown on list rows for non-Part categories',
        'Markup on inventory part form — replaced separate Cost and Sell Price fields with an inline Cost | Markup % | Sell Price row; markup tier from Settings auto-applies when cost is typed; editing Sell Price back-calculates Markup %',
        'Service Template linked parts (schema v20) — template form has a full LINKED PARTS section; add inventory parts with a quantity; searchable picker filters already-linked parts; save replaces all links; editing a template reloads existing links',
        'Apply Template inserts linked parts — when a template is applied to an estimate, the labor line is inserted first, then all linked inventory parts are inserted as part line items grouped under it with current cost/sell price from inventory',
    ],
    'bugs': [],
    'files_added': [],
    'files_modified': [
        'lib/database/database.dart — added category column to InventoryParts; added ServiceTemplateParts table (schema v20); migration v20; watchTemplatePartsForTemplate, getTemplatePartsForTemplate, insertTemplatePart, deleteTemplatePart, deleteAllTemplatePartsForTemplate',
        'lib/database/database.g.dart — regenerated via build_runner',
        'lib/features/inventory/part_form_screen.dart — added _markupPercentCtrl; _applyMarkupTier, _recalcSellPrice, _onSellPriceChanged; _markupRow inline Cost|Markup%|Sell Price widget; _loadDefaultMarkup; category picker',
        'lib/features/inventory/part_list_screen.dart — blue category badge on list rows; smart sell price formatting',
        'lib/features/service_templates/service_template_form_screen.dart — _total controller with bidirectional hours×rate sync; full LINKED PARTS section with _PartPickerSheet, qty dialog, _LinkedPartRow; save/load linked parts logic',
        'lib/features/estimates/estimate_detail_screen.dart — _applyTemplate now passes laborName, captures labor line id, fetches and inserts linked template parts',
        'lib/features/estimates/estimate_detail_screen.dart — _LineItemRow shows laborName as bold title + description as subtitle; smart _money() helper',
        'lib/features/repair_orders/ro_detail_screen.dart — same _LineItemRow laborName display + smart _money() helper',
        'lib/features/invoices/invoice_service.dart — _lineRow optional subtitle param; labor rows pass laborName as title + description as subtitle; simple invoice renderer also updated',
        'lib/features/estimates/line_item_form_screen.dart — _laborTotal controller with bidirectional hours×rate sync; select-all onTap on markup fields; placeholder cleanup',
        'lib/features/settings/settings_screen.dart — select-all onTap on markup rule dialog fields; placeholder cleanup',
        'lib/features/vehicles/vehicle_form_screen.dart — select-all onTap + contextMenuBuilder on all fields',
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

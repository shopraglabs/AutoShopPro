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
    'heading':  'Session 9 — v0.7.1 Smooth Operator',
    'date':     'March 22, 2026',
    'version':  'v0.7.1 Smooth Operator',
    'number':   '9',
    'built': [
        'Default approve — new line items now save as approved automatically; no more tapping each item to approve it',
        'Chevron + right-click on estimate line items — gray chevron on every row makes edit affordance obvious; right-click shows Edit / Delete context menu',
        'Inline search in all picker sheets — customer, vehicle, vendor, labor, technician, and template pickers autofocus a search field on open; list filters as you type; "No results" message when nothing matches',
        'Service Templates (schema v18) — new ServiceTemplates table; manage templates at Settings → Service Templates; each template stores a name, labor description, default hours, and optional rate override',
        'Apply Template action on estimates — "Apply Template" row under ADD ITEMS opens a searchable template picker; selecting one instantly adds a pre-filled approved labor line using the template rate or the shop default',
        'Rate/hr placeholder on template form shows the actual shop default dollar value (e.g. 120.00) loaded from settings',
        'Global search screen — Search in sidebar + Cmd+F shortcut; searches customers, vehicles, estimates, and ROs simultaneously; results grouped by section; tap any result to navigate directly to it',
    ],
    'bugs': [],
    'files_added': [
        'lib/features/service_templates/service_templates_provider.dart',
        'lib/features/service_templates/service_template_list_screen.dart',
        'lib/features/service_templates/service_template_form_screen.dart',
        'lib/features/search/search_screen.dart',
    ],
    'files_modified': [
        'lib/database/database.dart — added ServiceTemplates table (schema v18); searchCustomers, searchVehicles, searchEstimates, searchRepairOrders methods; ServiceTemplates CRUD queries',
        'lib/features/estimates/line_item_form_screen.dart — approvalStatus defaults to approved on insert; _VendorPickerSheet and _LaborPickerSheet converted to StatefulWidget with inline search',
        'lib/features/estimates/estimate_detail_screen.dart — chevron on line item rows; onSecondaryTapUp right-click context menu; _applyTemplate method; Apply Template action row; _TemplatePickerSheet widget',
        'lib/features/estimates/estimate_form_screen.dart — _PickerSheet converted to StatefulWidget with inline CupertinoSearchTextField',
        'lib/features/repair_orders/ro_detail_screen.dart — _TechPickerSheet converted to StatefulWidget with inline search',
        'lib/features/settings/settings_screen.dart — Service Templates navigation row added; go_router import added',
        'lib/main.dart — Search sidebar item above Settings; Cmd+F shortcut; _openSearch helper; _selectedIndex handles /search route',
        'lib/router.dart — /settings/service-templates routes; /search route; _ServiceTemplateEditLoader loader class',
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

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
    'heading':  'Session 8 — v0.7.0 Parts Counter',
    'date':     'March 22, 2026',
    'version':  'v0.7.0 Parts Counter',
    'number':   '8',
    'built': [
        'Parts Inventory — list screen with searchable parts, color-coded stock badges (In Stock / Low Stock / Out of Stock), add/edit/delete form with part number, cost, sell price, stock qty, and low stock threshold (schema v15)',
        'Catalog picker on Add Part form — pick a part from inventory to auto-fill description, cost, and sell price; markup sync runs automatically after',
        'Stock deduction on RO mark-done — checking off a parts line item on an RO deducts qty from inventory; unchecking restores it (schema v16 adds inventoryPartId to estimate_line_items)',
        'Settings screen — dedicated full screen at /settings, accessible from sidebar gear icon (bottom) and Cmd+, menu bar shortcut',
        'Settings: Shop Info (shop name), Labor (default labor rate), Tax (default tax rate), Parts Markup Rules sections',
        'Markup Rules — tiered cost-range matrix; add, edit (tap row), and delete (swipe) rules; auto-applies matching tier markup % when cost is typed on Add Part form (schema v17)',
        'Default tax rate applied to new estimates automatically on creation',
        'Select-all on tap for pre-populated numeric fields (stock qty, low stock threshold, line item qty)',
        'Removed old settings dialog in favor of full settings screen navigation',
    ],
    'bugs': [
        'StreamProvider data empty on first picker tap — fixed by ref.watch()-ing all picker providers in build() so streams are active before user taps',
        'Parts Inventory search bar clipped behind nav bar — fixed by wrapping CustomScrollView in SafeArea',
        'Stock deduction was incorrectly placed at estimate save time — moved to RO mark-done toggle for accurate real-world tracking',
    ],
    'files_added': [
        'lib/features/inventory/inventory_provider.dart',
        'lib/features/inventory/part_list_screen.dart',
        'lib/features/inventory/part_form_screen.dart',
        'lib/features/settings/settings_screen.dart',
        'lib/features/settings/markup_rules_provider.dart',
    ],
    'files_modified': [
        'lib/database/database.dart — added InventoryParts table (v15), inventoryPartId on line items (v16), MarkupRules table + shopName + defaultTaxRate on ShopSettings (v17); schema v17',
        'lib/features/estimates/line_item_form_screen.dart — catalog picker row + sheet; markup tier auto-apply on cost change; ref.watch for vendors/inventory/markup providers',
        'lib/features/estimates/estimate_detail_screen.dart — stock-aware delete removed (stock tracks on RO mark-done instead)',
        'lib/features/estimates/estimate_form_screen.dart — reads defaultTaxRate from settings on estimate creation',
        'lib/features/repair_orders/ro_detail_screen.dart — _toggleDone deducts/restores inventory stock for catalog-linked parts',
        'lib/main.dart — removed old settings dialog; Cmd+, navigates to /settings; sidebar gear icon at bottom; Settings highlighted when active',
        'lib/router.dart — /settings route added; /parts/:partId/edit route added',
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

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
    'heading':  'Session 13 — v0.10.1 Buttoned Up',
    'date':     'March 23, 2026',
    'version':  'v0.10.1 Buttoned Up',
    'number':   '13',
    'built': [
        'Left-click fix — invoice buttons (Itemized Invoice, Simple Invoice), estimate Save/Print/Email, approval badge, and category picker all showed a context menu dropdown on left click; fixed to show a CupertinoActionSheet modal on left click and the context menu on right click',
        'Open button — replaced "Show in Finder" with "Open" on the save-to-downloads confirmation dialog for both invoices and estimates; opens the PDF directly in Preview',
        'Hover cursors — added MouseRegion(cursor: SystemMouseCursors.click) to vehicle tile rows and history rows on the customer detail screen',
        'List-row button — replaced CupertinoButton.filled with the standard list-row style on the "Add Parts" confirm button in the template parts picker sheet',
        'Patch naming rule — patches now inherit the name of their parent minor version (e.g. v0.10.1 → Buttoned Up); updated v0.1.1 to Bones and v0.7.1 to Parts Counter in all docs',
    ],
    'bugs': [
        'Left click on invoice/estimate/approval/category rows triggered a context menu dropdown instead of a proper action',
        'Right click on those same rows did nothing',
        '"Show in Finder" opened Finder instead of the PDF',
        'Vehicle and history rows on customer detail had no pointer cursor on hover',
        'Add Parts confirm button used CupertinoButton.filled instead of list-row style',
    ],
    'files_added': [],
    'files_modified': [
        'lib/features/repair_orders/ro_detail_screen.dart — invoice GestureDetectors changed from onTapUp to onTap + onSecondaryTapUp',
        'lib/features/estimates/estimate_detail_screen.dart — _ActionRow gains onSecondaryTapUp param; Save/Print/Email row uses onTap; approval badge uses onTap + onSecondaryTapUp; _showApprovalSheet takes optional position; Add Parts confirm button replaced with list-row style',
        'lib/features/inventory/part_form_screen.dart — category picker GestureDetector changed from onTapUp to onTap + onSecondaryTapUp',
        'lib/features/invoices/invoice_service.dart — _handleSave dialogs: "Show in Finder" replaced with "Open" using open without -R flag; button order swapped (OK default, Open secondary)',
        'lib/features/customers/customer_detail_screen.dart — MouseRegion added to _VehicleTile and _HistoryRow',
        'docs/module_plan.md — v0.1.1 renamed Bones, v0.7.1 renamed Parts Counter, v0.10.1 section added',
        'README.md — v0.10.1 entry added; v0.7.1 renamed Parts Counter; v0.1.1 renamed Bones',
        'CLAUDE.md — version bumped to v0.10.1; patch naming convention documented',
    ],
    'next': 'Invoice screens (list + detail) for closed ROs, or continue UX polish.',
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

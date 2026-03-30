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
    'heading':  'Session 20 — v0.12.1 Full Picture',
    'date':     'March 30, 2026',
    'version':  'v0.12.1 Full Picture',
    'number':   '20',
    'built': [
        'Phase 1 production audit fixes — 12 critical/high issues resolved before any real shop data enters the app',
        'AppleScript injection fix — customer email and PDF file path are now escaped before interpolation into osascript; prevents crafted email addresses from executing arbitrary shell commands',
        'Estimate locking — estimate line items become read-only (no add/edit/delete) once the linked Repair Order is closed; open ROs still allow editing; locked banner shown with lock icon',
        'N+1 query elimination — dashboard, invoice totals, and customer stats providers now bulk-fetch all line items in a single query and look up by map, instead of calling getLineItemsForEstimate() per RO in a loop',
        'Integer-cents subtotals — all 4 total-calculation sites (estimate detail, RO detail, invoice detail, invoice_service.dart × 2) now stay in integer cents throughout; tax rounded after multiplication; no more floating-point rounding errors',
        'GP formula fix on invoice detail — gross profit now only deducts items with a known cost (unitCost > 0); previously used unitPrice as fallback, making labor appear 0% margin and overstating costs',
        'Convert-to-RO transaction — updateEstimate + insertRepairOrder are now wrapped in db.transaction() so a crash between them cannot leave the estimate approved without an RO',
        'Double-tap guard on Convert to RO — _ConvertRow converted to ConsumerStatefulWidget with _converting bool; second tap while in-flight returns early; button label changes to "Converting…"',
        'Stock deduction transactions — _toggleDone and _completeAll in ro_detail_screen now wrap all line item + inventory updates in db.transaction()',
        'Stock clamp removed — floor clamp at 0 broke check/uncheck symmetry (check + uncheck would inflate stock phantom units); negative stock accurately means "used more than on-hand"; Out of Stock badge handles qty ≤ 0',
        'Close RO unchecked-item warning — _advanceStatus now checks for part line items not marked done before closing; dialog offers "Close Anyway" or "Complete & Close" (which marks them done and deducts stock)',
        'TTF font in PDFs — Arial regular + bold loaded from assets via rootBundle; assigned to pw.ThemeData; all three PDF builders (itemized invoice, simple invoice, estimate) now use Arial; fixes boxes for accented characters (José, García, etc.)',
        'Migration v8 guard fixed — changed from < 8 to from == 7 for the supplier_id → vendor_id RENAME; prevents crash on devices upgrading from v1–v5 where the column does not yet exist',
    ],
    'bugs': [
        'Customer email interpolated raw into AppleScript string — RCE via crafted email address',
        'Estimate editable after RO closed — line items could be changed, silently altering closed invoice figures',
        'N+1 DB queries in dashboard/RO/customer providers — one query per RO, O(n) instead of O(1)',
        'Floating-point subtotals — quantity × fromCents(unitPrice) accumulated rounding errors across many line items',
        'GP formula used unitPrice fallback for labor — made labor appear 0% margin and overstated cost',
        'Convert-to-RO not atomic — crash between updateEstimate and insertRepairOrder left inconsistent state',
        'Double-tap on Convert to RO created duplicate ROs and crashed on stream',
        'Stock deduction not atomic — read-modify-write on inventory could race or partially fail',
        'Stock clamp at 0 broke check/uncheck symmetry — phantom stock units created on uncheck',
        'RO close skipped stock deduction for unchecked items — parts installed but not checked off were never deducted',
        'PDF Helvetica font — no support for accented characters; names like José rendered as boxes',
        'Migration v8 used from < 8 instead of from == 7 — RENAME would crash on fresh installs upgrading multiple versions',
    ],
    'files_added': [
        'assets/fonts/Arial.ttf — bundled font for PDF generation',
        'assets/fonts/Arial Bold.ttf — bundled bold font for PDF generation',
    ],
    'files_modified': [
        'lib/features/invoices/invoice_service.dart — _escapeForAppleScript() helper; import flutter/services.dart; _loadPdfTheme() loads Arial TTF; all 3 pw.Document() calls use theme; integer-cents subtotals in invoice and estimate PDF builders',
        'lib/features/estimates/estimate_detail_screen.dart — locked state (ro.status == closed); ADD ITEMS hidden when locked; per-labor Add Part hidden when locked; _LineItemSection and _LineItemRow accept locked param; Dismissible/edit skipped when locked; _ConvertRow → ConsumerStatefulWidget with _converting guard and db.transaction(); integer-cents subtotals',
        'lib/features/repair_orders/ro_detail_screen.dart — _advanceStatus takes BuildContext; unchecked-item dialog on close with Complete & Close option; _toggleDone wrapped in db.transaction() with clamp removed; _completeAll wrapped in db.transaction() with clamp removed; integer-cents subtotals',
        'lib/features/invoices/invoice_detail_screen.dart — integer-cents subtotals; GP formula fixed to only deduct unitCost > 0 items',
        'lib/features/dashboard/dashboard_provider.dart — bulk line item fetch with getLineItemsForEstimates(); Map lookup replaces per-RO await',
        'lib/features/repair_orders/repair_orders_provider.dart — bulk line item fetch in invoiceTotalsProvider',
        'lib/features/customers/customers_provider.dart — bulk line item fetch in customerStatsProvider',
        'lib/database/database.dart — migration v8 guard changed from < 8 to == 7',
        'pubspec.yaml — assets section added with Arial.ttf and Arial Bold.ttf',
        'docs/module_plan.md — v0.12.1 audit fixes section added',
        'README.md — v0.12.1 entry added',
        'CLAUDE.md — version bumped to v0.12.1',
    ],
    'next': 'Phase 2 audit fixes (tax rate on RO, shop address on invoice, input validation, PDF to app container) or Payments module.',
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

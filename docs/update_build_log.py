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
    'heading':  'Session 21 — v0.12.2 Full Picture',
    'date':     'March 30, 2026',
    'version':  'v0.12.2 Full Picture',
    'number':   '21',
    'built': [
        'Phase 2 audit fixes (11 items) — fixes before first paying customer: VIN char validation, keyboard shortcuts back-stack fix, negative prices allowed (coupons), markup tier gap prevention via UI lock, markup display fix (cents shown as dollars), ARO denominator fix, dashboard revenue labels, PDF temp file cleanup, shop contact info on invoices (schema v32), tax rate snapshot on RO (schema v33), invoice list totals include tax',
        'Phase 3 audit fixes (8 items) — architecture and UX improvements: reopen RO action, parentLaborId null-out on labor delete, 200ms search debounce, DB indexes on all FK columns (schema v34), markup recomputed from tier rules at catalog/template insert, About dialog version constant, template linked-part default quantities editable, CSV import wrapped in per-row transaction',
        'Reopen Repair Order — "Reopen Repair Order" row (↺ icon) added to closed RO ACTIONS section; confirmation dialog warns invoice becomes inactive; sets status back to Open',
        'Search debounce — 200ms Timer in search_screen.dart; keystroke-by-keystroke DB queries eliminated; 4 queries fire only after typing pauses',
        'DB indexes — schema v34 adds 7 CREATE INDEX statements on FK columns; eliminates full-table scans on all common joins',
        'Tax rate snapshot — taxRateBps stored on RepairOrder at convert time; invoice PDF always uses the correct rate regardless of future estimate edits',
        'Shop contact info — address/phone/email columns added to ShopSettings (schema v32); printed in header of all invoice and estimate PDFs',
        'Template linked-part quantities — each linked part row in the template form now shows an editable qty field; default qty saved to and loaded from DB; previously always 1.0',
        'CSV import transaction — each row\'s DB writes wrapped in _db.transaction(); failed row rolls back cleanly without leaving orphaned customers or estimates',
        'Markup recomputed at catalog insert — catalog picker now calls _applyMarkupTier() + _recalcFromCostAndPercent() instead of back-computing from stale stored sell price; template part insertions use _computeSellPriceCents() helper',
    ],
    'bugs': [
        'VIN decoder accepted VINs with illegal characters (I, O, Q) — now rejected before API call',
        '⌘N and ⌘F used context.go — destroyed navigation back stack; fixed to context.push',
        'Negative prices blocked — coupons and discounts require negative values; only a $999,999.99 cap now enforced',
        'Markup tier display showed cents as dollars (e.g. $5000 instead of $50) — fromCents() not applied to minCost/maxCost in display',
        'ARO denominator included ROs with no estimate/revenue — average was artificially low',
        'Dashboard showed "Revenue" — misleading since tax was excluded; renamed to "Revenue (excl. tax)"',
        'PDF temp files never deleted — accumulated in /tmp indefinitely; now cleaned up 30–60s after opening',
        'parentLaborId not nulled on labor delete — child parts became ungrouped orphans in the DB',
        'Search fired 4 DB queries on every keystroke — O(n×4) queries just for typing',
        'No DB indexes on any FK column — every list screen triggered full table scans',
        'Catalog picker used stored sell price — stale after markup tier rule changes; now recomputed fresh',
        'Template parts used stored sell price — same stale-price issue; now uses _computeSellPriceCents()',
        'CSV import had no transaction — partial row failure (e.g. estimate created but RO insert crashed) left orphaned records',
        'About dialog showed version 0.10.3 — hardcoded stale string; now uses _appVersion constant',
        'Template linked-part qty always saved as 1.0 — no way to set "5 quarts" for an oil change template',
    ],
    'files_added': [],
    'files_modified': [
        'lib/main.dart — _appVersion constant; copyright 2026; context.push for ⌘N and ⌘F',
        'lib/database/database.dart — schema v32 (shopAddress/Phone/Email on ShopSettings); schema v33 (taxRateBps on RepairOrders); schema v34 (7 FK indexes); deleteLineItem now nulls parentLaborId on child parts first',
        'lib/features/search/search_screen.dart — dart:async import; Timer? _debounce field; 200ms debounce in _onQueryChanged',
        'lib/features/repair_orders/ro_detail_screen.dart — _reopenRO() method; Reopen Repair Order action row in closed ACTIONS section; tax rate prefers taxRateBps; showInvoiceActions passes shop contact',
        'lib/features/repair_orders/repair_orders_provider.dart — invoiceTotalsProvider includes tax; prefers taxRateBps fallback',
        'lib/features/invoices/invoice_detail_screen.dart — tax rate prefers taxRateBps; showInvoiceActions passes shop contact',
        'lib/features/invoices/invoice_service.dart — shopAddress/Phone/Email params throughout; PDF headers show contact; _deleteTempAfterDelay() helper cleans up temp files',
        'lib/features/estimates/estimate_detail_screen.dart — _convert() snapshots taxRateBps at RO creation',
        'lib/features/estimates/line_item_form_screen.dart — _pickFromCatalog uses _applyMarkupTier+_recalcFromCostAndPercent; _computeSellPriceCents() helper; template parts use fresh sell price; negative price allowed; $999,999.99 cap',
        'lib/features/settings/settings_screen.dart — shopAddress/Phone/Email controllers; _showAddRuleDialog auto-fills From cost as read-only; markup display uses fromCents()',
        'lib/features/service_templates/service_template_form_screen.dart — qtyController added to _LinkedPart typedef; qty field shown on each linked part row; qty saved/loaded from DB',
        'lib/features/dashboard/dashboard_screen.dart — "Revenue" → "Revenue (excl. tax)" labels',
        'lib/features/dashboard/dashboard_provider.dart — ARO uses countedROsForARO denominator',
        'lib/features/vehicles/vin_service.dart — character set validation rejects I/O/Q before API call',
        'lib/features/data/data_service.dart — per-row DB writes wrapped in _db.transaction(); continue → return inside lambda',
        'pubspec.yaml — version bumped to 0.12.2+22',
        'lib/features/repair_orders/ro_detail_screen.dart — _advanceStatus takes BuildContext; unchecked-item dialog on close with Complete & Close option; _toggleDone wrapped in db.transaction() with clamp removed; _completeAll wrapped in db.transaction() with clamp removed; integer-cents subtotals',
        'lib/features/invoices/invoice_detail_screen.dart — integer-cents subtotals; GP formula fixed to only deduct unitCost > 0 items',
        'lib/features/dashboard/dashboard_provider.dart — bulk line item fetch with getLineItemsForEstimates(); Map lookup replaces per-RO await',
        'lib/features/repair_orders/repair_orders_provider.dart — bulk line item fetch in invoiceTotalsProvider',
        'lib/features/customers/customers_provider.dart — bulk line item fetch in customerStatsProvider',
        'lib/database/database.dart — migration v8 guard changed from < 8 to == 7',
        'docs/module_plan.md — Phase 2 + Phase 3 audit sections added',
        'README.md — v0.12.2 entry added',
        'CLAUDE.md — version bumped to v0.12.2; What\'s Built updated',
    ],
    'next': 'Phase 3 remaining: #23 move dbProvider to lib/core, #24 store taxAmountCents on invoice, #25 GDPR export/erasure, #26 CSV export audit log, #32 shop_id for multi-shop, #33 route guards stub.',
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

# AutoShopPro — Module Plan

Track build progress here. Check off tasks as they are completed.

**Legend:** ⬜ Not started · 🔄 In progress · ✅ Done

---

## Module 1 — Repair Order (RO) Engine

The heart of the app. Everything else depends on this.

### Customer & Vehicle Records
- ✅ Customer model (name, phone, email, internal note)
- ✅ Vehicle model (year, make, model, VIN, mileage, license plate)
- ✅ Link vehicles to customers (one customer → many vehicles)
- ✅ Customer list screen (searchable, live-updating)
- ✅ Customer detail screen
- ✅ Add / edit customer form (phone formatter, word capitalization)
- ✅ Vehicle list screen (per customer, on detail screen)
- ✅ Add / edit vehicle form (mileage formatter, plate formatter, VIN caps)

### VIN Decode
- ✅ VIN decode API integration (NHTSA free API, no key required)
- ✅ Auto-fill year/make/model from VIN on vehicle form

### Estimates
- ✅ Estimate model (customer, vehicle, note, status, tax rate)
- ✅ Create new estimate (customer + vehicle picker)
- ✅ Add labor lines to estimate (description, hours, rate/hr)
- ✅ Add parts lines to estimate (description, qty, unit price, vendor)
- ✅ Calculate totals (subtotal + tax + total)
- ✅ Estimate list screen (status dot, customer name, vehicle, total)
- ✅ Estimate detail screen (labor section, parts section, totals section)
- ✅ Swipe-to-delete line items
- ✅ Live line total preview on line item form
- ✅ Default labor rate auto-filled from shop settings
- ✅ Edit existing line items
- ✅ Convert estimate → Repair Order
- ✅ Customer complaint field on new estimate form
- ✅ Parts linked to labor lines (grouped display in detail)
- ✅ Unit cost + markup % / markup $ / unit list price fields on Add Part
- ✅ Add customer / add vehicle / add vendor from within picker sheets
- ✅ Partial estimate approval — approve or decline individual line items
- ✅ Declined items shown with strikethrough/gray; excluded from totals
- ✅ Totals section shows "X items declined −$Y.YY" footnote

### Vendors
- ✅ Vendor model (name, contact, phone, account #)
- ✅ Vendor list screen
- ✅ Add / edit vendor form (account # forced uppercase)
- ✅ Delete vendor (with confirmation)
- ✅ Vendor picker when adding a part to an estimate

### Shop Settings
- ✅ Single-row settings table (default labor rate, default parts markup)
- ✅ Settings dialog accessible via ⌘, menu bar shortcut

### Repair Orders (RO)
- ✅ RO model (estimateId, customerId, vehicleId, note, status, createdAt)
- ✅ RO status flow: Open → In Progress → Completed → Closed
- ✅ Create new RO (via Convert from estimate)
- ✅ RO list screen (color-coded status dots, customer name, vehicle)
- ✅ RO detail screen (line items, totals, status badge, advancement action)
- ✅ Close RO
- ✅ Mark items done on RO (checkmark toggle per line item while open)
- ✅ Edit Estimate link from non-closed RO detail
- ✅ Declined items filtered out of RO totals and work items
- ✅ Declined items shown in separate DECLINED section on RO detail (gray strikethrough, red X)
- ✅ Declined items shown in DECLINED — NOT BILLED section on invoice PDFs
- ✅ Edit RO details
- ✅ Assign technician to RO
- ✅ RO list status filters

### Local Database (Drift/SQLite)
- ✅ Drift database setup
- ✅ Tables: customers, vehicles, estimates, estimate_line_items, vendors, shop_settings, repair_orders
- ✅ CRUD for customers, vehicles, estimates, line items, vendors, settings, repair orders
- ✅ Schema versioning + migration strategy (v13)

---

## Module 2 — Parts & Ordering

### Inventory
- ✅ Part model (part number, description, cost, sell price, stock quantity)
- ✅ Parts list screen
- ✅ Add / edit part form
- ✅ Stock level display (in stock / low stock / out of stock)
- ✅ Catalog picker on Add Part form — pick from inventory, auto-fills description/cost/sell price
- ✅ Stock deduction when RO line item is checked off; restore when unchecked
- ✅ Part category field (Part / Fluid / Filter / Chemical) — picker on form, badge on list
- ✅ Markup on inventory part form — Cost | Markup % | Sell Price row with auto-rules and bidirectional sync

### Cost & Markup Rules
- ✅ Markup rule model (tiered matrix by cost range)
- ✅ Apply markup tier automatically when cost is typed on Add Part form
- ✅ Markup rules settings screen (add, edit, delete tiers)
- ✅ Markup tier auto-applies on inventory part form when cost is entered

### Supplier Integrations
- ⬜ PartsTech API integration
- ⬜ Epicor/OEConnection API integration
- ⬜ NexPart API integration
- ⬜ RepairLink API integration
- ⬜ Search parts from supplier catalog
- ⬜ Order parts from within the app
- ⬜ Track order status

### Core Returns
- ⬜ Core charge tracking on parts
- ⬜ Core return workflow
- ⬜ Core credit applied to invoice

---

## Module 3 — Payments

### Invoice Generation
- ⬜ Invoice model (derived from closed RO)
- ⬜ Invoice PDF generation (pdf package)
- ⬜ Invoice detail screen
- ⬜ Invoice list screen

### Payment Processing
- ⬜ Stripe integration
- ⬜ Square integration (alternative)
- ⬜ Card-on-file (save customer payment method)
- ⬜ Text-to-pay (send payment link via SMS)
- ⬜ Payment confirmation screen
- ⬜ Payment history per customer

---

## Module 4 — Owner Dashboards

### KPI Metrics
- ⬜ Average Repair Order (ARO) calculation
- ⬜ Gross Profit (GP) per job
- ⬜ Technician utilization rate
- ⬜ Car count (daily / weekly / monthly)
- ⬜ Revenue (daily / weekly / monthly)

### Dashboard Screens
- ⬜ Main dashboard screen with KPI cards
- ⬜ Date range picker (today / this week / this month / custom)
- ⬜ Technician performance screen
- ⬜ Job profitability screen

### Multi-Location
- ⬜ Location model
- ⬜ Location switcher in nav
- ⬜ Filter all data by selected location
- ⬜ Roll-up view (all locations combined)

---

## Module 5 — QuickBooks / Xero Sync

### OAuth Setup
- ⬜ QuickBooks OAuth 2.0 flow
- ⬜ Xero OAuth 2.0 flow
- ⬜ Token storage and refresh

### Accounting Export
- ⬜ Map RO line items → accounting categories
- ⬜ Export closed invoices to QuickBooks
- ⬜ Export closed invoices to Xero
- ⬜ Sync customers to accounting platform
- ⬜ Error handling and sync status display
- ⬜ Sync history log screen

---

## Infrastructure & App Shell

### App Foundation (v0.1.0 — v0.1.1 Bones ✅)
- ✅ Flutter project created
- ✅ App running on macOS via Xcode
- ✅ CupertinoApp with system blue theme (#007AFF)
- ✅ Adaptive layout — sidebar on desktop (>700px width), CupertinoTabBar on mobile
- ✅ AutoShopPro branding in sidebar
- ✅ All 5 module nav items with Cupertino icons
- ✅ Active state highlighting (system blue background, white text/icon)
- ✅ CupertinoNavigationBar on each screen
- ✅ Placeholder screens for all 5 modules (icon + title + "Coming soon")
- ✅ Mobile tab bar layout (CupertinoTabScaffold + CupertinoTabBar)
- ✅ Git initialized and connected to GitHub
- ✅ README.md, module_plan.md, AutoShopPro_Build_Log.docx created

### Infrastructure (v0.1.1 Bones ✅)
- ✅ Riverpod state management setup
- ✅ go_router navigation setup (ShellRoute with 5 module routes)
- ✅ Drift database initialization (customers + vehicles tables)
- ✅ Dock display name fixed to AutoShopPro

### Customer & Vehicle Records (v0.2.0 Intake ✅)
- ✅ Repair Orders hub screen (module entry point)
- ✅ Customer list with live search and avatar initials
- ✅ New customer → lands on customer detail page
- ✅ Edit customer form (pre-filled)
- ✅ Delete customer (with confirmation dialog)
- ✅ Vehicle list on customer detail (live-updating)
- ✅ Add / edit / delete vehicles
- ✅ Phone formatter: (555) 867-5309
- ✅ Mileage formatter: 45,000
- ✅ Plate formatter: ABC 1234
- ✅ VIN auto-uppercase
- ✅ Name / Make / Model word capitalization enforced

### Estimates & Vendors (v0.3.0 Write-Up)
- ✅ VIN decode via NHTSA API (auto-fills year/make/model)
- ✅ macOS network entitlement added for outbound HTTP
- ✅ dio HTTP client added
- ✅ Estimates — full create/view/delete flow
- ✅ Line items — labor and parts, swipe to delete
- ✅ Vendor system — list, add, edit, delete
- ✅ Vendor picker on Add Part form
- ✅ Shop settings — default labor rate + parts markup, saved to DB
- ✅ Apple-style macOS menu bar (AutoShopPro / File / Window / Help)
- ✅ ⌘N → New Estimate, ⇧⌘N → New Customer, ⌘, → Settings
- ✅ Right-click context menus on customer, estimate, and vendor list rows
- ✅ New Estimate shortcut from vehicle detail screen
- ✅ Smart dependency navigation (no customers → go to New Customer, etc.)
- ✅ All alert dialogs fixed to use dialog context (no stuck popups)
- ✅ Edit existing line items (tap row to edit description, qty, price, vendor)
- ✅ Account # forced uppercase in vendor form
- ✅ docs/update_build_log.py — python-docx build log script

### Repair Order Engine (v0.4.0 Open Bay)
- ✅ RepairOrders table (schema v9) + full CRUD queries
- ✅ repair_orders_provider.dart — Riverpod stream providers for RO list, detail, and roForEstimate
- ✅ RO list screen — color-coded status dots (blue/orange/green/gray), customer name, vehicle
- ✅ RO detail screen — customer/vehicle header, line items, totals, status badge, ACTIONS row
- ✅ Status advancement: Open → In Progress → Completed → Closed (list-row action, not filled button)
- ✅ "Convert to Repair Order" action on estimate detail (list-row style under ACTIONS section)
- ✅ "View Repair Order" link on estimate once RO is created
- ✅ Repair Orders hub row enabled (was "Coming soon")
- ✅ Button/action design rule standardized — all actions use list-row style (blue icon + label + chevron)
- ✅ Button style rule saved permanently to CLAUDE.md

### Write-Up Polish & Approval (v0.5.0 Sign-Off)
- ✅ Unit cost + markup % / markup $ / unit list price fields on Add Part (schema v10)
- ✅ Markup % ↔ Markup $ auto-sync as you type
- ✅ Parts can be linked to a labor line (parentLaborId, schema v10)
- ✅ Parts grouped under their labor sub-header in estimate and RO detail
- ✅ Customer complaint field added to estimate form and detail header (schema v11)
- ✅ Internal note on customers — form field, detail display, auto-populates estimate note (schema v12)
- ✅ License plate shown in vehicle picker dropdown and selected row
- ✅ "NO PLATE" stored when plate field is empty on save; displayed as-is in all pickers and headers
- ✅ Mark items done on RO — checkmark toggle per line item (schema v12)
- ✅ Edit Estimate link on non-closed RO detail
- ✅ "+ New Customer" / "+ New Vehicle" / "+ Add Vendor" inside all picker sheets
- ✅ Right-click copy/cut/paste (contextMenuBuilder) on all CupertinoTextFields
- ✅ Partial estimate approval — approve/decline individual line items (schema v13)
- ✅ Declined items: strikethrough + gray in estimate; filtered from RO entirely
- ✅ Totals section shows "X items declined −$Y.YY" footnote

### Module 1 Complete (v0.6.0 Full Bay)

- ✅ RO list status filter pills (All / Open / In Progress / Completed / Closed)
- ✅ Edit RO details form (internal note, accessible from ACTIONS on non-closed ROs)
- ✅ Technicians table (schema v14) — name, specialty, phone
- ✅ Technician list screen + add/edit/delete form
- ✅ Assign technician to RO (bottom sheet picker with "+ New Technician" option)
- ✅ Assigned technician shown in RO detail header
- ✅ Technicians row added to Repair Orders hub screen

---

### Module 2 Phase 1 — Parts Inventory & Settings (v0.7.0 Parts Counter)
- ✅ Parts inventory — list, add/edit/delete, stock badges
- ✅ Catalog picker on Add Part form — auto-fills description, cost, sell price
- ✅ Stock deduction on RO mark-done; restore on uncheck
- ✅ Markup rules — tiered matrix, auto-apply on cost entry, add/edit/delete
- ✅ Settings screen — shop info, default labor rate, default tax rate, markup rules
- ✅ Default tax rate applied to new estimates
- ✅ ⌘, navigates to Settings screen; gear icon in sidebar

---

### UX Polish & Search (v0.7.1 Parts Counter)
- ✅ New line items default to approved (no manual tap required)
- ✅ Chevron on estimate line item rows + right-click context menu (Edit / Delete)
- ✅ Inline search in all picker sheets — customer, vehicle, vendor, labor, technician, template
- ✅ Service Templates — new table (schema v18), list/add/edit/delete, Settings → Service Templates
- ✅ Apply Template action on estimates — searchable picker adds pre-filled labor line in one tap
- ✅ Global search screen — Search sidebar item + ⌘F; searches customers, vehicles, estimates, ROs

### Linked Parts, Markup & Polish (v0.8.0 Linked Up)
- ✅ Labor name (short title) shown as bold header on labor lines in estimate/RO detail and invoice PDFs; description shown as subtitle
- ✅ Hours × rate = total live calc on service template form and line item form — all three fields editable with bidirectional sync
- ✅ Select-all on tap for all number text fields across the app
- ✅ Smart money formatting — UI omits .00 cents (e.g. $90 not $90.00), real cents always shown (e.g. $13.50); invoice PDFs always use 2 decimal places
- ✅ Part category field (Part / Fluid / Filter / Chemical) — action sheet picker on form, blue badge on list
- ✅ Markup on inventory part form — Cost | Markup % | Sell Price inline row; markup tier auto-applies from rules when cost is typed; bidirectional sync
- ✅ Service Template linked parts — add inventory parts to a template with qty; Apply Template inserts part line items grouped under the labor line
- ✅ ServiceTemplateParts table (schema v20) with getTemplatePartsForTemplate DB method

---

### UX Polish & RO Cleanup (v0.10.0 Buttoned Up — v0.10.1 Buttoned Up)
- ✅ Scrollbars on vendor, technician, and part list screens (CupertinoScrollbar)
- ✅ Hover cursors on list rows throughout the app (MouseRegion)
- ✅ Dropdown context menus on desktop for category pickers, approval badge, invoice actions
- ✅ After saving a new vehicle → navigate to that vehicle's detail page
- ✅ Labor form field order: Labor Name first, then Labor Description
- ✅ Typing in the Total field back-calculates Hours (rate stays fixed)
- ✅ Duplicate customer concerns removed from estimate detail header
- ✅ Customer concern editable after entry — Add/Edit link next to section title
- ✅ Vehicle history section on vehicle detail page (estimates + ROs, deduplication)
- ✅ "Complete All Services" button on open ROs — checks every item done in one tap
- ✅ Simplified RO status: Open → Closed only (removed In Progress and Completed)
- ✅ RO list filter pills: All / Open / Closed
- ✅ Edit Repair Order consolidates Edit Estimate + Edit Record into one button
- ✅ "Other" line item type — name, description, cost, list price; shown in OTHER section
- ✅ RO invoice comment field — Add/Edit on RO detail; prints on PDF invoices
- ✅ Schema v23 — comment column on repair_orders
- ✅ Apply Template removed from ADD ITEMS (template access is in Add Labor → Operation)
- ✅ Estimate date field — editable date on estimate detail, stored as estimateDate, falls back to createdAt
- ✅ RO service date read-only on detail screen; editable only via Edit Repair Order form
- ✅ RO list shows date on each row (service date or createdAt)
- ✅ RO list sorted by id descending (newest first, consistent order)
- ✅ Schema v24 — estimateDate column on estimates
- ✅ Left-click on invoice/estimate/approval/category buttons now shows action sheet (not context menu dropdown)
- ✅ Right-click on those same buttons shows context menu at cursor position
- ✅ "Show in Finder" replaced with "Open" on save-to-downloads dialogs
- ✅ Hover cursors added to vehicle tiles and history rows on customer detail
- ✅ "Add Parts" confirm button in template picker replaced with list-row style
- ✅ Patch naming convention: patches inherit parent minor/major version name

### Data Integrity & Infrastructure (v0.10.3 Buttoned Up)
- ✅ MIT LICENSE file added (ShopRag Labs)
- ✅ analysis_options.yaml — production-strict lint rules added on top of flutter_lints
- ✅ Money columns converted from REAL (float) to INTEGER (cents) — schema v26; migration converts existing data with ROUND(col * 100); all UI screens use fromCents()/toCents() helpers
- ✅ lib/core/utils/money.dart — toCents(), fromCents(), formatMoney(), formatMoneyFull() helpers
- ✅ Foreign key constraints — .references() annotations on all FK columns; PRAGMA foreign_keys = ON at DB open
- ✅ Transaction wrapping on cascade-delete DAO methods (deleteCustomer, deleteVehicle, deleteEstimate, deleteServiceTemplate, clearAllCustomerData)

### Audit & Bug Fixes (v0.10.2 Buttoned Up)
- ✅ Cascade deletes — deleting a customer removes all linked vehicles, estimates, line items, and ROs; deleting a vehicle removes its estimates, line items, and ROs; deleting an estimate removes its line items; deleting a service template removes its linked parts
- ✅ Archive vendors — soft-delete with isArchived flag (schema v25); archived vendors hidden from lists and pickers but records preserved
- ✅ Archive technicians — soft-delete with isArchived flag (schema v25); archived technicians hidden from lists and pickers but existing ROs preserved
- ✅ Estimate list sorted newest-first (orderBy id DESC)
- ✅ RO detail tax rate sourced from linked estimate (was always 0% if taxRate not re-derived)
- ✅ Complete All confirmation dialog — shows item count, filters out declined items
- ✅ Stock floor clamping — inventory stock cannot go below 0 (individual toggle and Complete All)
- ✅ Other items included in invoice PDFs (both Itemized and Simple)
- ✅ Invoice date uses RO service date instead of generation date
- ✅ Search enhancements — vehicle year included in search; RO search supports RO number lookup
- ✅ Router edit loaders fixed — futures cached in initState (no re-fire on rebuild)
- ✅ Schema v25 — isArchived column on vendors and technicians tables

---

### Backend (Go — planned)
- ⬜ Go project scaffolding
- ⬜ PostgreSQL schema
- ⬜ Redis caching layer
- ⬜ REST API design
- ⬜ Flutter ↔ backend sync logic

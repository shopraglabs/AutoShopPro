# AutoShopPro — Module Plan

Track build progress here. Check off tasks as they are completed.

**Legend:** ⬜ Not started · 🔄 In progress · ✅ Done

---

## Module 1 — Repair Order (RO) Engine

The heart of the app. Everything else depends on this.

### Customer & Vehicle Records
- ✅ Customer model (name, phone, email)
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
- ✅ Declined items filtered out of RO (not shown, not counted in totals)
- ⬜ Edit RO details
- ⬜ Assign technician to RO
- ⬜ RO list status filters

### Local Database (Drift/SQLite)
- ✅ Drift database setup
- ✅ Tables: customers, vehicles, estimates, estimate_line_items, vendors, shop_settings, repair_orders
- ✅ CRUD for customers, vehicles, estimates, line items, vendors, settings, repair orders
- ✅ Schema versioning + migration strategy (v13)

---

## Module 2 — Parts & Ordering

### Inventory
- ⬜ Part model (part number, description, cost, sell price, stock quantity)
- ⬜ Parts list screen
- ⬜ Add / edit part form
- ⬜ Stock level display (in stock / low stock / out of stock)

### Cost & Markup Rules
- ⬜ Markup rule model (flat %, matrix by cost tier)
- ⬜ Apply markup rules when adding parts to RO
- ⬜ Markup settings screen

### Supplier Integrations
- ⬜ PartsTech API integration
- ⬜ Epicor API integration
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

### App Foundation (v0.1.0 Bones ✅)
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

### Infrastructure (v0.1.1 Ignition ✅)
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
- ✅ "NO PLATE" stored when plate field is empty on save
- ✅ Mark items done on RO — checkmark toggle per line item (schema v12)
- ✅ Edit Estimate link on non-closed RO detail
- ✅ "+ New Customer" / "+ New Vehicle" / "+ Add Vendor" inside all picker sheets
- ✅ Right-click copy/cut/paste (contextMenuBuilder) on all CupertinoTextFields
- ✅ Partial estimate approval — approve/decline individual line items (schema v13)
- ✅ Declined items: strikethrough + gray in estimate; filtered from RO entirely
- ✅ Totals section shows "X items declined −$Y.YY" footnote

### Backend (Go — planned)
- ⬜ Go project scaffolding
- ⬜ PostgreSQL schema
- ⬜ Redis caching layer
- ⬜ REST API design
- ⬜ Flutter ↔ backend sync logic

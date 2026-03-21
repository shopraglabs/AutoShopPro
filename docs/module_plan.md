# AutoShopPro — Module Plan

Track build progress here. Check off tasks as they are completed.

**Legend:** ⬜ Not started · 🔄 In progress · ✅ Done

---

## Module 1 — Repair Order (RO) Engine

The heart of the app. Everything else depends on this.

### Customer & Vehicle Records
- ⬜ Customer model (name, phone, email, address)
- ⬜ Vehicle model (year, make, model, trim, VIN, mileage, license plate)
- ⬜ Link vehicles to customers (one customer → many vehicles)
- ⬜ Customer list screen
- ⬜ Customer detail screen
- ⬜ Add / edit customer form
- ⬜ Vehicle list screen (per customer)
- ⬜ Add / edit vehicle form

### VIN Decode
- ⬜ VIN decode API integration (NHTSA free API)
- ⬜ Auto-fill year/make/model/trim from VIN on vehicle form

### Estimates
- ⬜ Estimate model
- ⬜ Create new estimate
- ⬜ Add labor lines to estimate
- ⬜ Add parts lines to estimate
- ⬜ Calculate totals (parts + labor + tax)
- ⬜ Estimate list screen
- ⬜ Estimate detail screen
- ⬜ Convert estimate → Repair Order

### Repair Orders (RO)
- ⬜ RO model
- ⬜ RO status flow: Draft → Approved → In Progress → Completed → Closed
- ⬜ Create new RO
- ⬜ Edit RO
- ⬜ Assign technician to RO
- ⬜ RO list screen (with status filters)
- ⬜ RO detail screen
- ⬜ Close RO

### Local Database (Drift/SQLite)
- ⬜ Drift database setup
- ⬜ Tables: customers, vehicles, estimates, repair_orders, line_items
- ⬜ Basic CRUD operations for all tables

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

### App Foundation (v1.0.0 Bones ✅)
- ✅ Flutter project created
- ✅ App running on macOS via Xcode
- ⬜ Riverpod setup
- ⬜ go_router navigation setup
- ⬜ Adaptive layout shell (sidebar on desktop, tab bar on mobile)
- ⬜ Cupertino theme configuration (colors, typography)
- ⬜ Drift database initialization

### Backend (Go — planned)
- ⬜ Go project scaffolding
- ⬜ PostgreSQL schema
- ⬜ Redis caching layer
- ⬜ REST API design
- ⬜ Flutter ↔ backend sync logic

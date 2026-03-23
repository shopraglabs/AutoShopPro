# AutoShopPro

A cross-platform automotive shop management app built with Flutter. One codebase, four platforms: **Windows, macOS, Android, and iOS**.

---

## Project Status

**v0.9.0 — Dialed In** — UX polish: Add Part button under each labor row (auto-linked), customer complaints shown on estimate detail, template linked parts as opt-in dropdown with quantities, part number field on line items, new estimate from vehicle page goes through the form with customer/vehicle pre-filled, and number fields now select-all on tap throughout the app.

**v0.8.0 — Linked Up** — Templates now link to inventory parts; applying a template drops in the labor line plus all linked parts in one tap. Parts inventory has categories (Part/Fluid/Filter/Chemical) and a full markup calculator with auto-tier rules. Labor names show as bold titles throughout estimates, ROs, and invoice PDFs.

**v0.7.1 — Smooth Operator** — UX polish session. New line items default to approved, inline search in every picker sheet, right-click context menus on line items, service templates for common jobs, and a global search screen accessible from the sidebar or ⌘F.

**v0.7.0 — Parts Counter** — Module 2 Phase 1: parts inventory (list, add/edit/delete, stock badges), catalog picker on Add Part form, stock deduction on RO mark-done, tiered markup rules, and a full Settings screen.

**v0.6.0 — Full Bay** — Module 1 complete. RO list status filters, edit RO note, technician management (add/edit/delete), and assign technician to repair orders with bottom sheet picker.

**v0.5.0 — Sign-Off** — Full write-up workflow: customer complaints, parts with cost/markup pricing, parts linked to labor lines, individual item approval/decline on estimates, declined items excluded from repair orders.

**v0.4.0 — Open Bay** — Full repair order engine working: create estimate, convert to RO, track job status (Open → In Progress → Completed → Closed), mark items done, and close the RO.

**v0.3.0 — Write-Up** — Customers, vehicles, VIN decode, estimates (labor + parts + totals), vendors, shop settings, and menu bar all working.

**v0.2.0 — Intake** — Customer & Vehicle records fully working. Add, edit, delete, and search customers. Add vehicles to customers with year, make, model, VIN, mileage, and plate. Smart input formatting throughout (phone, mileage, plate, capitalization). All data saved locally to SQLite via Drift.

**v0.1.1 — Ignition** — Infrastructure wired up. Riverpod state management, go_router navigation, and Drift local database (customers + vehicles tables) all running.

**v0.1.0 — Bones** — Adaptive app shell complete. Sidebar navigation on desktop, tab bar on mobile, all 5 module placeholders wired up.

---

## GitHub

[https://github.com/shopraglabs/AutoShopPro](https://github.com/shopraglabs/AutoShopPro)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter beta 3.43.0 / Dart |
| State Management | Riverpod |
| Local Database | Drift (SQLite, offline-first) |
| Navigation | go_router |
| HTTP Client | Dio |
| PDF Generation | pdf package |
| Backend (planned) | Go |
| Database (planned) | PostgreSQL + Redis |

---

## Target Platforms

- macOS
- Windows
- iOS
- Android

---

## Developer Machine

| Detail | Info |
|---|---|
| Machine | MacBook Neo |
| Chip | Apple A18 Pro |
| OS | macOS Tahoe 26.3.2 |
| Flutter | beta 3.43.0 |
| Project Location | ~/Documents/autoshoppro |

---

## How to Run the App

> ⚠️ **Important:** Flutter CLI has a code signing bug on macOS Tahoe. Do NOT use `flutter run` from the terminal.

**Correct way to run:**

1. Open `~/Documents/autoshoppro/macos/Runner.xcworkspace` in **Xcode**
2. Select **My Mac** as the target device
3. Press the **Play ▶ button**

---

## Core Modules (Build Order)

1. **Repair Order (RO) Engine** — Estimates, RO create/edit/close, customer & vehicle records, VIN decode
2. **Parts & Ordering** — PartsTech/Epicor integration, inventory stock levels, cost/markup rules, core returns
3. **Payments** — Stripe/Square, card-on-file, text-to-pay, invoice PDF generation
4. **Owner Dashboards** — ARO, GP per job, technician utilization, KPIs, multi-location support
5. **QuickBooks/Xero Sync** — OAuth integration, accounting export

---

## Design Philosophy

The app is designed to feel native on every platform — not a generic cross-platform UI, but something that belongs on each OS.

**Widgets:** Cupertino widgets throughout. No Material design.

**Navigation:**
- Desktop (macOS/Windows): Sidebar navigation, generous whitespace, translucent sidebars
- Mobile (iOS/Android): Bottom tab bar, swipe gestures, pull-to-refresh

**Colors:**
- Primary accent: System Blue `#007AFF`
- Backgrounds: Pure whites and light grays
- Text: Deep grays

**Typography:** Clean, hierarchical — large bold titles, smaller muted subtitles, SF Pro style

**Animations:** Smooth, physics-based, subtle

**Cards & Lists:** Native macOS grouped lists on desktop; native iOS table views on mobile

**Spacing:** Generous and breathable

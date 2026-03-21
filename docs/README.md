# AutoShopPro

A cross-platform automotive shop management app built with Flutter, inspired by Tekmetric, Shopmonkey, and AutoLeap. One codebase, four platforms: **Windows, macOS, Android, and iOS**.

---

## Project Status

**v0.1.1 — Ignition** — Infrastructure wired up. Riverpod state management, go_router navigation, and Drift local database (customers + vehicles tables) all running. Ready to build Module 1.

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

The app should feel like it was designed by Apple — clean, minimal, and confident.

**Widgets:** Always use `flutter_cupertino` equivalents. No Material widgets.

**Navigation:**
- Desktop (macOS/Windows): Sidebar navigation, generous whitespace, translucent sidebars
- Mobile (iOS/Android): Bottom tab bar, swipe gestures, pull-to-refresh

**Colors:**
- Primary accent: System Blue `#007AFF`
- Backgrounds: Pure whites and light grays
- Text: Deep grays

**Typography:** Clean, hierarchical — large bold titles, smaller muted subtitles, SF Pro style

**Animations:** Smooth, physics-based, subtle — nothing flashy

**Cards & Lists:** Should feel like native iOS grouped table views

**Spacing:** Generous and breathable, like Apple apps

---

## Coding Rules

This project is built by a beginner. All code contributions must follow these rules:

- Always explain what code does **before** writing it
- Keep changes **small and focused** — one thing at a time
- Always specify **exactly which file to open** and where to paste code
- Never rewrite large chunks without explaining why
- After each change, explain **how to verify it worked**

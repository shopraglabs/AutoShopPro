# AutoShopPro — Claude Code Instructions

## Who I Am
My name is Jim. I am a complete beginner at coding. I am building AutoShopPro, a cross-platform automotive shop management app. Treat me like an intelligent adult who is new to code — explain what things do before writing them, keep changes small and focused, and always tell me exactly which file to open and where to paste code.

## How to Talk to Me
- Always explain what a piece of code does BEFORE writing it
- Keep changes small — one thing at a time
- Tell me exactly which file to open and where to make changes
- After every change, tell me how to verify it worked
- Never rewrite large chunks of code without explaining why
- If something could break other things, warn me first
- Use simple language — avoid jargon unless you explain it
- Be encouraging — I am learning as I build

## Project Overview
AutoShopPro is a cross-platform automotive shop management app inspired by Tekmetric, Shopmonkey, and AutoLeap. Built with Flutter targeting Windows, macOS, Android, and iOS from a single codebase.

## Tech Stack
- Flutter beta 3.43.0 / Dart
- State management: Riverpod
- Local DB: Drift (offline-first, SQLite)
- Navigation: go_router
- HTTP: Dio
- PDF generation: pdf package
- Backend: Go (planned, not started)
- Database: PostgreSQL + Redis (planned)

## What's Built So Far
- **App shell** — sidebar nav (desktop), tab bar (mobile), all 5 module placeholders
- **Customers** — list (searchable), detail, add/edit/delete, phone/name formatting, internal note field
- **Vehicles** — list per customer, detail, add/edit/delete, VIN decode (NHTSA API), all formatters, "NO PLATE" auto-stored when plate is blank and shown as-is in all displays
- **Estimates** — list, create (customer + vehicle picker with "+ New" options), detail (labor + parts + totals), customer complaint field, delete
- **Line items** — add labor (hrs × rate, default rate from settings), add parts (unit cost + markup % / $ / list, vendor picker, link to labor line), swipe to delete, live total preview, edit existing items
- **Parts display** — grouped under their linked labor line sub-header in estimate and RO detail
- **Estimate approval** — tap circle badge on any line item to approve or decline; declined items show strikethrough/gray and are excluded from totals; "X items declined" footnote in totals section
- **Repair Orders** — convert estimate → RO (declined items excluded), RO list (color-coded status), RO detail, status flow (Open → In Progress → Completed → Closed), mark items done per line item, Edit Estimate link on non-closed ROs
- **Vendors** — list, add/edit/delete, account # forced uppercase, contact name
- **Shop settings** — default labor rate + parts markup, stored in DB, accessible via ⌘,
- **macOS menu bar** — AutoShopPro / File (⌘N, ⇧⌘N) / Window / Help
- **Right-click context menus** — on customer, estimate, and vendor list rows; contextMenuBuilder on all CupertinoTextFields
- **Database** — Drift/SQLite, schema v13, tables: customers, vehicles, estimates, estimate_line_items, vendors, shop_settings, repair_orders

## Core Modules (in build order)
1. Repair Order (RO) engine — estimates, RO create/edit/close, customer & vehicle records, VIN decode
2. Parts & ordering — PartsTech/Epicor integration, inventory, cost/markup rules, core returns
3. Payments — Stripe/Square, card-on-file, text-to-pay, invoice PDF generation
4. Owner dashboards — ARO, GP per job, technician utilization, KPIs, multi-location
5. QuickBooks/Xero sync — OAuth, accounting export

## Button & Action Design Rule
All action buttons throughout the app must use the **list-row style** — never `CupertinoButton.filled` or custom rounded buttons. The standard pattern is:
- White container, full-width
- Blue icon on the left (size 18)
- Blue label text (fontSize 16) in the middle
- Gray chevron (`CupertinoIcons.chevron_right`, size 16, color `0xFFC7C7CC`) on the right
- Grouped under a small-caps section header (e.g. `ACTIONS`, `ADD ITEMS`)
- Separator lines between rows (`height: 0.5, color: 0xFFE5E5EA`)

This matches the "New Estimate" row on the vehicle detail screen and must be used as the default for every action/button across all screens.

The only exception is destructive actions (delete), which use a centered `CupertinoButton` with `CupertinoColors.destructiveRed` text — no filled button.

## Design Philosophy — Apple-Native Feel
- The app should feel like it was designed by Apple — clean, minimal, confident
- Use flutter_cupertino package for iOS/macOS native widgets
- On desktop (macOS/Windows): sidebar navigation, generous whitespace, SF Pro-style typography
- On mobile (iOS/Android): bottom tab bar, swipe gestures, pull-to-refresh
- Colors: system blue (#007AFF) as primary accent, pure whites and light grays for backgrounds
- Typography: clean, well-spaced, hierarchical — large bold titles, smaller muted subtitles
- Animations: smooth, physics-based, subtle — nothing flashy
- Cards and lists should feel like native iOS grouped table views
- NO Material design widgets — always prefer Cupertino equivalents
- Spacing should feel generous and breathable like Apple apps

## Device & Build Info
- MacBook Neo, Apple A18 Pro, macOS Tahoe 26.3.2
- Flutter is installed at: /Users/jamestoney/flutter/bin/flutter (not on system PATH — always use full path in terminal)
- Flutter CLI has a code signing bug on macOS Tahoe
- To run the app: open ~/Documents/autoshoppro/macos/Runner.xcworkspace in Xcode, select My Mac, press Play
- Project location: ~/Documents/autoshoppro

## Worktrees
Claude Code sometimes starts in a git worktree (a separate copy of the project under .claude/worktrees/). Do NOT work in the worktree — Xcode builds from the main project at ~/Documents/autoshoppro. Always read and write files in ~/Documents/autoshoppro/lib/ directly.

## Database Schema Changes
Any time a table definition in lib/database/database.dart is changed (columns added, removed, or renamed), the generated file database.g.dart must be regenerated by running:
```
cd /Users/jamestoney/Documents/autoshoppro && /Users/jamestoney/flutter/bin/dart run build_runner build --delete-conflicting-outputs
```
Also bump schemaVersion by 1 and add a migration in the MigrationStrategy block.

## Adding New Plugins (macOS)
When adding a new Flutter plugin with native macOS code:
1. Add to pubspec.yaml and run `/Users/jamestoney/flutter/bin/flutter pub get`
2. Run `/Users/jamestoney/flutter/bin/flutter build macos --debug` to register the plugin with Swift Package Manager (will fail at code signing — that's expected and fine)
3. Run `swift package resolve` in `macos/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage`
4. Quit and reopen Xcode, then press Play

## Versioning
- Uses semantic versioning: MAJOR.MINOR.PATCH
- 0.x.x = in development, not ready for real users
- 1.0.0 = first stable release to real shops
- PATCH (0.1.0 → 0.1.1): under-the-hood changes, nothing visible
- MINOR (0.1.x → 0.2.0): new module or major feature working
- MAJOR (0.x.x → 1.0.0): app is shippable to real customers

## Session Rules
- At the start of each session, check the current state of code
- Keep each session focused on one clear goal
- Tell me when it is a good stopping point
- When starting a session, start with "Current version: (insert version number and name) — this session goal: (list goals for the this session here)"
- When ending a session, assign a version number with a cool name, summarize what was built, and update these four files:

  **1. `docs/module_plan.md`**
  - Change `⬜` to `✅` for everything completed this session
  - Add any new tasks that were discovered (keep them `⬜`)
  - Add a new Infrastructure section at the bottom for the new version if it doesn't exist

  **2. `docs/AutoShopPro_Build_Log.docx`**
  - Fill in the SESSION dict at the top of `docs/update_build_log.py`
  - Run: `python3 docs/update_build_log.py`
  - Verify with: `python3 docs/update_build_log.py read`

  **3. `README.md`**
  - Update the single line in the **Project Status** section: change the version number and the one-sentence description of what's working

  **4. `CLAUDE.md`**
  - Update the **Current Version** field at the bottom
  - Update the **What's Built So Far** section to include anything new
- Save work to GitHub at end of every session

## Coding Rules (learned the hard way)

### Dialogs
- Always use `dialogCtx` — never `context` — inside `CupertinoAlertDialog` builders:
  ```dart
  showCupertinoDialog(
    context: context,
    builder: (dialogCtx) => CupertinoAlertDialog(
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(dialogCtx), // ← dialogCtx, not context
          ...
        ),
      ],
    ),
  );
  ```
- Reason: on macOS with go_router, `Navigator.pop(context)` can close the wrong route instead of the dialog.

### Missing Dependencies — Navigate, Don't Block
- If a screen requires something that doesn't exist yet (e.g. no customers when creating an estimate), navigate directly to the creation screen instead of showing a dead-end dialog:
  ```dart
  if (customers.isEmpty) {
    context.push('/repair-orders/customers/new');
    return;
  }
  ```

### Database Migrations
- Always use `from == N` (not `from < N`) for migrations that run SQL statements like `ALTER TABLE RENAME` that would fail if run more than once.
- For `addColumn`, guard with a PRAGMA check in case a partial migration already ran:
  ```dart
  final cols = await m.database.customSelect(
    "SELECT name FROM pragma_table_info('table') WHERE name='col'"
  ).get();
  if (cols.isEmpty) { await m.addColumn(...); }
  ```

### Build Log
- To read: `python3 docs/update_build_log.py read`
- To write: fill in the SESSION dict in `docs/update_build_log.py`, then run `python3 docs/update_build_log.py`
- Requires: `python-docx` (`pip3 install python-docx`)

## GitHub
Repository: https://github.com/shopraglabs/AutoShopPro

## Current Version
v0.5.0 Sign-Off

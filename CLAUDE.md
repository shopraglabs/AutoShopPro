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

## Core Modules (in build order)
1. Repair Order (RO) engine — estimates, RO create/edit/close, customer & vehicle records, VIN decode
2. Parts & ordering — PartsTech/Epicor integration, inventory, cost/markup rules, core returns
3. Payments — Stripe/Square, card-on-file, text-to-pay, invoice PDF generation
4. Owner dashboards — ARO, GP per job, technician utilization, KPIs, multi-location
5. QuickBooks/Xero sync — OAuth, accounting export

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
- When ending a session, assign a version number with a cool name, summarize what was built, and provide updated module_plan.md, README.md and AutoShopPro_Build_Log.docx
- Save work to GitHub at end of every session

## GitHub
Repository: https://github.com/shopraglabs/AutoShopPro

## Current Version
v0.1.1 Ignition

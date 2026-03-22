import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'database/database.dart';
import 'features/customers/customers_provider.dart';
import 'router.dart';

void main() {
  runApp(const ProviderScope(child: AutoShopProApp()));
}

class AutoShopProApp extends StatelessWidget {
  const AutoShopProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        // ── AutoShopPro ──────────────────────────────────────────────────────
        PlatformMenu(
          label: 'AutoShopPro',
          menus: [
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'About AutoShopPro',
                onSelected: _showAboutDialog,
              ),
            ]),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'Settings…',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.comma,
                  meta: true,
                ),
                onSelected: _openSettings,
              ),
            ]),
            const PlatformMenuItemGroup(members: [
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.servicesSubmenu),
            ]),
            const PlatformMenuItemGroup(members: [
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide),
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hideOtherApplications),
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.showAllApplications),
            ]),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'Quit AutoShopPro',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyQ,
                  meta: true,
                ),
                onSelected: () => exit(0),
              ),
            ]),
          ],
        ),
        // ── File ─────────────────────────────────────────────────────────────
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'New Estimate',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyN,
                  meta: true,
                ),
                onSelected: _newEstimate,
              ),
              PlatformMenuItem(
                label: 'New Customer',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyN,
                  meta: true,
                  shift: true,
                ),
                onSelected: _newCustomer,
              ),
            ]),
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'Search…',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyF,
                  meta: true,
                ),
                onSelected: _openSearch,
              ),
            ]),
          ],
        ),
        // ── Window ───────────────────────────────────────────────────────────
        PlatformMenu(
          label: 'Window',
          menus: [
            const PlatformMenuItemGroup(members: [
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.minimizeWindow),
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.zoomWindow),
            ]),
          ],
        ),
        // ── Help ─────────────────────────────────────────────────────────────
        PlatformMenu(
          label: 'Help',
          menus: [
            PlatformMenuItemGroup(members: [
              PlatformMenuItem(
                label: 'AutoShopPro Help',
                onSelected: _showHelpDialog,
              ),
            ]),
          ],
        ),
      ],
      child: CupertinoApp.router(
        title: 'AutoShopPro',
        theme: const CupertinoThemeData(
          primaryColor: Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}

// ─── Menu bar helpers ─────────────────────────────────────────────────────────

BuildContext? get _ctx => appNavigatorKey.currentContext;

Future<void> _showAboutDialog() async {
  final ctx = _ctx;
  if (ctx == null) return;
  showCupertinoDialog(
    context: ctx,
    builder: (d) => CupertinoAlertDialog(
      title: const Text('AutoShopPro'),
      content: const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Column(
          children: [
            Text('Version 0.5.0', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(
              'Professional shop management for independent automotive repair shops.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8),
            Text('© 2025 AutoShopPro', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(d),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// Settings: navigate to the Settings screen — Cmd+, convention.
Future<void> _openSettings() async {
  final ctx = _ctx;
  if (ctx == null) return;
  ctx.push('/settings');
}

// File menu helpers — navigate to the new-estimate / new-customer forms.
Future<void> _newEstimate() async {
  final ctx = _ctx;
  if (ctx == null) return;
  ctx.push('/repair-orders/estimates/new');
}

Future<void> _newCustomer() async {
  final ctx = _ctx;
  if (ctx == null) return;
  ctx.go('/repair-orders/customers/new');
}

Future<void> _openSearch() async {
  final ctx = _ctx;
  if (ctx == null) return;
  ctx.go('/search');
}

Future<void> _showHelpDialog() async {
  final ctx = _ctx;
  if (ctx == null) return;
  showCupertinoDialog(
    context: ctx,
    builder: (d) => CupertinoAlertDialog(
      title: const Text('AutoShopPro Help'),
      content: const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text('Full documentation is coming soon.'),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(d),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// AppShell is the outer frame that holds the sidebar (desktop) or tab bar
// (mobile). The current screen is passed in as 'child' by go_router.
class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // The list of routes in the same order as the nav items below.
  final List<String> _routes = const [
    '/repair-orders',
    '/parts',
    '/payments',
    '/dashboard',
    '/accounting',
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Repair Orders', icon: CupertinoIcons.wrench),
    _NavItem(label: 'Parts', icon: CupertinoIcons.cube_box),
    _NavItem(label: 'Payments', icon: CupertinoIcons.creditcard),
    _NavItem(label: 'Dashboard', icon: CupertinoIcons.chart_bar),
    _NavItem(label: 'Accounting', icon: CupertinoIcons.book),
  ];

  // Figure out which nav item is active by matching the current URL path.
  // Returns -1 for /settings, -2 for /search so no main nav item is highlighted.
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/settings')) return -1;
    if (location.startsWith('/search')) return -2;
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 700;
    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final selected = _selectedIndex(context);
    return CupertinoPageScaffold(
      child: Row(
        children: [
          Container(
            width: 220,
            color: const Color(0xFFF5F5F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'AutoShopPro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  final isSelected = selected == index;
                  return GestureDetector(
                    onTap: () => context.go(_routes[index]),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : CupertinoColors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 18,
                            color: isSelected
                                ? CupertinoColors.white
                                : const Color(0xFF3C3C43),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? CupertinoColors.white
                                  : const Color(0xFF3C3C43),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // ── Search ──────────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/search'),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected == -2
                          ? const Color(0xFF007AFF)
                          : CupertinoColors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 18,
                          color: selected == -2
                              ? CupertinoColors.white
                              : const Color(0xFF3C3C43),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected == -2
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected == -2
                                ? CupertinoColors.white
                                : const Color(0xFF3C3C43),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Settings gear at the bottom of the sidebar ─────────────
                GestureDetector(
                  onTap: () => context.go('/settings'),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 2, 8, 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected == -1
                          ? const Color(0xFF007AFF)
                          : CupertinoColors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.settings,
                          size: 18,
                          color: selected == -1
                              ? CupertinoColors.white
                              : const Color(0xFF3C3C43),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected == -1
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected == -1
                                ? CupertinoColors.white
                                : const Color(0xFF3C3C43),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, color: const Color(0xFFE5E5EA)),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final selected = _selectedIndex(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: selected,
        onTap: (index) => context.go(_routes[index]),
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
      tabBuilder: (context, index) => widget.child,
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.hammer,
              size: 48,
              color: Color(0xFF007AFF),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

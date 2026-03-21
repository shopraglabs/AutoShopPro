import 'package:flutter/cupertino.dart';

void main() {
  runApp(const AutoShopProApp());
}

class AutoShopProApp extends StatelessWidget {
  const AutoShopProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'AutoShopPro',
      theme: CupertinoThemeData(
        primaryColor: Color(0xFF007AFF),
        brightness: Brightness.light,
      ),
      home: AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Repair Orders', icon: CupertinoIcons.wrench),
    _NavItem(label: 'Parts', icon: CupertinoIcons.cube_box),
    _NavItem(label: 'Payments', icon: CupertinoIcons.creditcard),
    _NavItem(label: 'Dashboard', icon: CupertinoIcons.chart_bar),
    _NavItem(label: 'Accounting', icon: CupertinoIcons.book),
  ];

  final List<Widget> _screens = const [
    PlaceholderScreen(title: 'Repair Orders'),
    PlaceholderScreen(title: 'Parts'),
    PlaceholderScreen(title: 'Payments'),
    PlaceholderScreen(title: 'Dashboard'),
    PlaceholderScreen(title: 'Accounting'),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 700;
    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
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
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
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
              ],
            ),
          ),
          Container(width: 1, color: const Color(0xFFE5E5EA)),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
      tabBuilder: (context, index) => _screens[index],
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
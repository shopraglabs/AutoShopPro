import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

// This is the hub screen for Module 1 — Repair Orders.
// It lists the sub-sections of this module as tappable rows.
// Sections that aren't built yet are greyed out with "Coming soon".
class RepairOrdersScreen extends StatelessWidget {
  const RepairOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Repair Orders'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 28),
            const _SectionHeader(title: 'MODULE 1'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _MenuRow(
                    icon: CupertinoIcons.person_2_fill,
                    label: 'Customers',
                    onTap: () => context.go('/repair-orders/customers'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 62),
                  ),
                  _MenuRow(
                    icon: CupertinoIcons.doc_text_fill,
                    label: 'Repair Orders',
                    onTap: () => context.go('/repair-orders/ros'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 62),
                  ),
                  _MenuRow(
                    icon: CupertinoIcons.doc_fill,
                    label: 'Estimates',
                    onTap: () =>
                        context.go('/repair-orders/estimates'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 62),
                  ),
                  _MenuRow(
                    icon: CupertinoIcons.building_2_fill,
                    label: 'Vendors',
                    onTap: () => context.go('/repair-orders/vendors'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 62),
                  ),
                  _MenuRow(
                    icon: CupertinoIcons.person_2_square_stack_fill,
                    label: 'Technicians',
                    onTap: () => context.go('/repair-orders/technicians'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF8E8E93),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFAEAEB2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: CupertinoColors.white, size: 18),
            ),
            const SizedBox(width: 14),
            // Label and optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: active
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFF8E8E93),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                ],
              ),
            ),
            if (active)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFFC7C7CC),
              ),
          ],
        ),
      ),
    );
  }
}

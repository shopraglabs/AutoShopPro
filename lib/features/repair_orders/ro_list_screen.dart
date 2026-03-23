import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'repair_orders_provider.dart';

// Formats a repair order id as a number: 1 → "RO-0001"
String _roNumber(int id) => 'RO-${id.toString().padLeft(4, '0')}';

// Returns a human-readable label for each status value
String _statusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Open';
    case 'closed':
      return 'Closed';
    default:
      return status;
  }
}

// blue = open, gray = closed
Color _statusColor(String status) {
  switch (status) {
    case 'open':
      return const Color(0xFF007AFF);
    case 'closed':
      return const Color(0xFF8E8E93);
    default:
      return const Color(0xFF8E8E93);
  }
}

// The status filter options shown in the pill bar.
// null means "All" — no filtering applied.
const _filters = <(String label, String? value)>[
  ('All', null),
  ('Open', 'open'),
  ('Closed', 'closed'),
];

class RoListScreen extends ConsumerStatefulWidget {
  const RoListScreen({super.key});

  @override
  ConsumerState<RoListScreen> createState() => _RoListScreenState();
}

class _RoListScreenState extends ConsumerState<RoListScreen> {
  // null = show all; otherwise filter to that status string
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final rosAsync = ref.watch(repairOrdersProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Repair Orders'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Status filter pill bar ─────────────────────────────────────
            Container(
              color: CupertinoColors.systemGroupedBackground,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (int i = 0; i < _filters.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _FilterPill(
                        label: _filters[i].$1,
                        selected: _filter == _filters[i].$2,
                        onTap: () =>
                            setState(() => _filter = _filters[i].$2),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── RO list ───────────────────────────────────────────────────
            Expanded(
              child: rosAsync.when(
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (allRos) {
                  // Apply the active filter
                  final ros = _filter == null
                      ? allRos
                      : allRos
                          .where((r) => r.ro.status == _filter)
                          .toList();

                  if (ros.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.doc_text,
                              size: 48,
                              color: Color(0xFFC7C7CC),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filter == null
                                  ? 'No repair orders yet.'
                                  : 'No ${_statusLabel(_filter!).toLowerCase()} repair orders.',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3A3A3C),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _filter == null
                                  ? 'Convert an estimate to create your first RO.'
                                  : 'Try a different filter above.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return CupertinoScrollbar(
                    child: ListView.builder(
                    itemCount: ros.length,
                    itemBuilder: (context, index) {
                      final item = ros[index];
                      return _RoRow(
                        item: item,
                        onTap: () =>
                            context.push('/repair-orders/ros/${item.ro.id}'),
                        showDivider: index < ros.length - 1,
                      );
                    },
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Pill ───────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF007AFF)
              : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? CupertinoColors.white
                : const Color(0xFF3A3A3C),
          ),
        ),
      ),
    );
  }
}

// ─── RO List Row ──────────────────────────────────────────────────────────────
class _RoRow extends StatelessWidget {
  final RepairOrderWithDetails item;
  final VoidCallback onTap;
  final bool showDivider;

  const _RoRow({
    required this.item,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final ro = item.ro;
    final customerName = item.customer?.name ?? 'Customer #${ro.customerId}';
    final vehicle = item.vehicle;
    final vehicleLabel = vehicle != null
        ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
            .whereType<String>()
            .join(' ')
        : null;

    final color = _statusColor(ro.status);
    final label = _statusLabel(ro.status);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: CupertinoColors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Status color dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // RO number + customer + vehicle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _roNumber(ro.id),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3A3A3C),
                        ),
                      ),
                      if (vehicleLabel != null && vehicleLabel.isNotEmpty)
                        Text(
                          vehicleLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                    ],
                  ),
                ),
                // Status label + chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: Color(0xFFC7C7CC),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            color: const Color(0xFFE5E5EA),
            margin: const EdgeInsets.only(left: 38),
          ),
      ],
    );
  }
}

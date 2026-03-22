import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../estimates/estimates_provider.dart';
import 'repair_orders_provider.dart';

String _roNumber(int id) => 'RO-${id.toString().padLeft(4, '0')}';

String _money(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '\$$dollars.${parts[1]}';
}

String _qty(double q) =>
    q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);

// ─── Status helpers ───────────────────────────────────────────────────────────

String _statusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Open';
    case 'in_progress':
      return 'In Progress';
    case 'completed':
      return 'Completed';
    case 'closed':
      return 'Closed';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'open':
      return const Color(0xFF007AFF);
    case 'in_progress':
      return const Color(0xFFFF9500);
    case 'completed':
      return const Color(0xFF34C759);
    case 'closed':
      return const Color(0xFF8E8E93);
    default:
      return const Color(0xFF8E8E93);
  }
}

// Returns the icon for the advancement button based on current status.
IconData _nextIcon(String status) {
  switch (status) {
    case 'open':
      return CupertinoIcons.wrench_fill;
    case 'in_progress':
      return CupertinoIcons.checkmark_seal_fill;
    case 'completed':
      return CupertinoIcons.lock_fill;
    default:
      return CupertinoIcons.chevron_right;
  }
}

// Returns the label and next status for the advancement button.
// Returns null when the RO is closed (no further advancement possible).
({String buttonLabel, String nextStatus})? _nextStep(String status) {
  switch (status) {
    case 'open':
      return (buttonLabel: 'Start Job', nextStatus: 'in_progress');
    case 'in_progress':
      return (buttonLabel: 'Mark Complete', nextStatus: 'completed');
    case 'completed':
      return (buttonLabel: 'Close RO', nextStatus: 'closed');
    default:
      return null; // closed — nothing left to do
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RoDetailScreen extends ConsumerWidget {
  final int roId;
  const RoDetailScreen({super.key, required this.roId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roAsync = ref.watch(repairOrderProvider(roId));

    return roAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Repair Order')),
        child: Center(child: Text('Error: $e')),
      ),
      data: (ro) {
        if (ro == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Repair Order')),
            child: Center(child: Text('Repair order not found.')),
          );
        }
        // If this RO came from an estimate, stream those line items live.
        // If no estimate, show an empty list.
        final lineItemsAsync = ro.estimateId != null
            ? ref.watch(lineItemsProvider(ro.estimateId!))
            : const AsyncValue.data(<EstimateLineItem>[]);

        return _RoDetailView(ro: ro, lineItemsAsync: lineItemsAsync);
      },
    );
  }
}

// ─── Detail view ─────────────────────────────────────────────────────────────

class _RoDetailView extends ConsumerWidget {
  final RepairOrder ro;
  final AsyncValue<List<EstimateLineItem>> lineItemsAsync;

  const _RoDetailView({required this.ro, required this.lineItemsAsync});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Delete repair order?'),
        content: const Text('This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).deleteRepairOrder(ro.id);
              if (context.mounted) context.go('/repair-orders/ros');
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _advanceStatus(WidgetRef ref, String nextStatus) async {
    final db = ref.read(dbProvider);
    await db.updateRepairOrder(ro.copyWith(status: nextStatus));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineItems = lineItemsAsync.value ?? [];
    final laborLines = lineItems.where((l) => l.type == 'labor').toList();
    final partLines = lineItems.where((l) => l.type == 'part').toList();

    final subtotal =
        lineItems.fold(0.0, (s, l) => s + l.quantity * l.unitPrice);
    final total = subtotal; // ROs don't add extra tax (already on estimate)

    final next = _nextStep(ro.status);
    final statusColor = _statusColor(ro.status);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_roNumber(ro.id)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _confirmDelete(context, ref),
          child: const Icon(
            CupertinoIcons.trash,
            size: 20,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // ── Status badge ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel(ro.status),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Customer + Vehicle header ─────────────────────────────────
            _CustomerVehicleHeader(ro: ro),

            const SizedBox(height: 28),

            // ── Labor lines ───────────────────────────────────────────────
            if (laborLines.isNotEmpty) ...[
              _sectionHeader('LABOR'),
              _LineItemSection(items: laborLines),
              const SizedBox(height: 20),
            ],

            // ── Parts lines ───────────────────────────────────────────────
            if (partLines.isNotEmpty) ...[
              _sectionHeader('PARTS'),
              _LineItemSection(items: partLines),
              const SizedBox(height: 20),
            ],

            // ── Empty state ───────────────────────────────────────────────
            if (lineItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items on this repair order.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),

            // ── Totals ────────────────────────────────────────────────────
            if (lineItems.isNotEmpty) ...[
              _sectionHeader('TOTALS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: _money(subtotal)),
                    Container(height: 0.5, color: const Color(0xFFE5E5EA)),
                    _TotalRow(
                        label: 'Total',
                        value: _money(total),
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── Actions ───────────────────────────────────────────────────
            if (next != null) ...[
              _sectionHeader('ACTIONS'),
              GestureDetector(
                onTap: () => _advanceStatus(ref, next.nextStatus),
                child: Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        _nextIcon(ro.status),
                        size: 18,
                        color: const Color(0xFF007AFF),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          next.buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: Color(0xFFC7C7CC),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (ro.status == 'closed')
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Center(
                  child: Text(
                    'This repair order is closed.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      );
}

// ─── Customer + Vehicle Header ────────────────────────────────────────────────
class _CustomerVehicleHeader extends ConsumerWidget {
  final RepairOrder ro;
  const _CustomerVehicleHeader({required this.ro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: Future.wait([
        db.getCustomer(ro.customerId),
        if (ro.vehicleId != null) db.getVehicle(ro.vehicleId!),
      ]),
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final customer = results.isNotEmpty ? results[0] as Customer? : null;
        final vehicle = results.length > 1 ? results[1] as Vehicle? : null;

        final vehicleLabel = vehicle != null
            ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
                .whereType<String>()
                .join(' ')
            : null;

        return Container(
          color: CupertinoColors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.person_fill,
                      size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 6),
                  Text(
                    customer?.name ?? 'Customer #${ro.customerId}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              if (vehicleLabel != null && vehicleLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.car_fill,
                        size: 15, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 6),
                    Text(
                      vehicleLabel,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
              ],
              if (ro.note != null && ro.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  ro.note!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Line Item Section (read-only on RO) ─────────────────────────────────────
class _LineItemSection extends ConsumerWidget {
  final List<EstimateLineItem> items;
  const _LineItemSection({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _LineItemRow(item: items[i], ref: ref),
            if (i < items.length - 1)
              Container(
                height: 0.5,
                color: const Color(0xFFE5E5EA),
                margin: const EdgeInsets.only(left: 16),
              ),
          ],
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final EstimateLineItem item;
  final WidgetRef ref;
  const _LineItemRow({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.quantity * item.unitPrice;
    final qtyLabel = item.type == 'labor'
        ? '${_qty(item.quantity)} hr @ \$${item.unitPrice.toStringAsFixed(2)}/hr'
        : '${_qty(item.quantity)} × \$${item.unitPrice.toStringAsFixed(2)}';

    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF1C1C1E)),
                ),
                const SizedBox(height: 2),
                if (item.type == 'part' && item.vendorId != null)
                  FutureBuilder(
                    future: ref.read(dbProvider).getVendor(item.vendorId!),
                    builder: (context, snap) {
                      final vendorName = snap.data?.name;
                      final label = vendorName != null
                          ? '$qtyLabel · $vendorName'
                          : qtyLabel;
                      return Text(label,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF8E8E93)));
                    },
                  )
                else
                  Text(qtyLabel,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(lineTotal),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Total Row ────────────────────────────────────────────────────────────────
class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 16 : 15,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF1C1C1E),
              )),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 16 : 15,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF1C1C1E),
              )),
        ],
      ),
    );
  }
}

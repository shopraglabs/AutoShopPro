import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'estimates_provider.dart';
import '../repair_orders/repair_orders_provider.dart';

// Formats a double as a dollar amount: 1234.5 → "$1,234.50"
String _money(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '\$$dollars.${parts[1]}';
}

String _estimateNumber(int id) => 'EST-${id.toString().padLeft(4, '0')}';

class EstimateDetailScreen extends ConsumerWidget {
  final int estimateId;
  const EstimateDetailScreen({super.key, required this.estimateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimateAsync = ref.watch(estimateProvider(estimateId));
    final lineItemsAsync = ref.watch(lineItemsProvider(estimateId));

    return estimateAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Estimate')),
        child: Center(child: Text('Error: $e')),
      ),
      data: (estimate) {
        if (estimate == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Estimate')),
            child: Center(child: Text('Estimate not found.')),
          );
        }
        return _EstimateDetailView(
          estimate: estimate,
          lineItemsAsync: lineItemsAsync,
        );
      },
    );
  }
}

class _EstimateDetailView extends ConsumerWidget {
  final Estimate estimate;
  final AsyncValue<List<EstimateLineItem>> lineItemsAsync;

  const _EstimateDetailView({
    required this.estimate,
    required this.lineItemsAsync,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Delete estimate?'),
        content: const Text('This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).deleteEstimate(estimate.id);
              if (context.mounted) context.go('/repair-orders/estimates');
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineItems = lineItemsAsync.value ?? [];
    final laborLines =
        lineItems.where((l) => l.type == 'labor').toList();
    final partLines =
        lineItems.where((l) => l.type == 'part').toList();

    final subtotal =
        lineItems.fold(0.0, (s, l) => s + l.quantity * l.unitPrice);
    final tax = subtotal * (estimate.taxRate / 100);
    final total = subtotal + tax;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_estimateNumber(estimate.id)),
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

            // ── Customer + Vehicle header ──────────────────────────────────
            _CustomerVehicleHeader(estimate: estimate),

            const SizedBox(height: 16),

            // ── Convert to RO / View RO banner ────────────────────────────
            _RoBanner(estimate: estimate),

            const SizedBox(height: 20),

            // ── Labor lines ───────────────────────────────────────────────
            if (laborLines.isNotEmpty) ...[
              _sectionHeader('LABOR'),
              _LineItemSection(
                items: laborLines,
                onDelete: (id) => ref.read(dbProvider).deleteLineItem(id),
              ),
              const SizedBox(height: 20),
            ],

            // ── Parts lines ───────────────────────────────────────────────
            if (partLines.isNotEmpty) ...[
              _sectionHeader('PARTS'),
              _LineItemSection(
                items: partLines,
                onDelete: (id) => ref.read(dbProvider).deleteLineItem(id),
              ),
              const SizedBox(height: 20),
            ],

            // ── Empty state ───────────────────────────────────────────────
            if (lineItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items yet.\nAdd labor or parts below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),

            // ── Add items ─────────────────────────────────────────────────
            _sectionHeader('ADD ITEMS'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _ActionRow(
                    icon: CupertinoIcons.wrench_fill,
                    label: 'Add Labor',
                    onTap: () => context.push(
                        '/repair-orders/estimates/${estimate.id}/line-items/labor'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 46),
                  ),
                  _ActionRow(
                    icon: CupertinoIcons.cube_box_fill,
                    label: 'Add Part',
                    onTap: () => context.push(
                        '/repair-orders/estimates/${estimate.id}/line-items/part'),
                  ),
                ],
              ),
            ),

            // ── Totals ────────────────────────────────────────────────────
            if (lineItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionHeader('TOTALS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: _money(subtotal)),
                    if (estimate.taxRate > 0)
                      _TotalRow(
                        label:
                            'Tax (${estimate.taxRate.toStringAsFixed(1)}%)',
                        value: _money(tax),
                      ),
                    Container(
                        height: 0.5, color: const Color(0xFFE5E5EA)),
                    _TotalRow(
                      label: 'Total',
                      value: _money(total),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],

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
  final Estimate estimate;
  const _CustomerVehicleHeader({required this.estimate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: Future.wait([
        db.getCustomer(estimate.customerId),
        if (estimate.vehicleId != null) db.getVehicle(estimate.vehicleId!),
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
                  const Icon(
                    CupertinoIcons.person_fill,
                    size: 16,
                    color: Color(0xFF8E8E93),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    customer?.name ?? 'Customer #${estimate.customerId}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              if (vehicleLabel != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.car_fill,
                      size: 15,
                      color: Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehicleLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ],
              if (estimate.note != null && estimate.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  estimate.note!,
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

// ─── Line Item Section ────────────────────────────────────────────────────────
// Shows a group of line items (all labor, or all parts) with swipe-to-delete.
class _LineItemSection extends StatelessWidget {
  final List<EstimateLineItem> items;
  final Future<int> Function(int id) onDelete;

  const _LineItemSection({required this.items, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _LineItemRow(item: items[i], onDelete: onDelete),
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

class _LineItemRow extends ConsumerWidget {
  final EstimateLineItem item;
  final Future<int> Function(int id) onDelete;

  const _LineItemRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineTotal = item.quantity * item.unitPrice;
    final qtyLabel = item.type == 'labor'
        ? '${_qty(item.quantity)} hr @ \$${item.unitPrice.toStringAsFixed(2)}/hr'
        : '${_qty(item.quantity)} × \$${item.unitPrice.toStringAsFixed(2)}';

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.trash, color: CupertinoColors.white),
      ),
      onDismissed: (_) => onDelete(item.id),
      child: GestureDetector(
        onTap: () => context.push(
            '/repair-orders/estimates/${item.estimateId}/line-items/${item.id}/edit'),
        child: Container(
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
                      fontSize: 15,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // For parts, show vendor name alongside the qty label
                  if (item.type == 'part' && item.vendorId != null)
                    FutureBuilder(
                      future: ref
                          .read(dbProvider)
                          .getVendor(item.vendorId!),
                      builder: (context, snap) {
                        final vendorName = snap.data?.name;
                        final label = vendorName != null
                            ? '$qtyLabel · $vendorName'
                            : qtyLabel;
                        return Text(label,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93)));
                      },
                    )
                  else
                    Text(
                      qtyLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
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
      ),
      ),
    );
  }

  // Strips trailing ".0" for whole numbers: 1.0 → "1", 2.5 → "2.5"
  String _qty(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);
}

// ─── RO Banner ────────────────────────────────────────────────────────────────
// Shows a "Convert to Repair Order" button when no RO exists for this estimate.
// Shows a "View Repair Order" row when one already does.
class _RoBanner extends ConsumerWidget {
  final Estimate estimate;
  const _RoBanner({required this.estimate});

  Future<void> _convert(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    // Mark the estimate as approved
    await db.updateEstimate(estimate.copyWith(status: 'approved'));
    // Create the repair order, carrying over all the key details
    final roId = await db.insertRepairOrder(RepairOrdersCompanion(
      estimateId: Value(estimate.id),
      customerId: Value(estimate.customerId),
      vehicleId: Value(estimate.vehicleId),
      note: Value(estimate.note),
    ));
    if (context.mounted) context.push('/repair-orders/ros/$roId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roAsync = ref.watch(roForEstimateProvider(estimate.id));

    return roAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (ro) {
        if (ro == null) {
          // No RO yet — show Convert as a standard action row
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeaderStatic('ACTIONS'),
              _ActionRow(
                icon: CupertinoIcons.doc_text_fill,
                label: 'Convert to Repair Order',
                onTap: () => _convert(context, ref),
              ),
            ],
          );
        }

        // RO exists — show a "View RO" row in the same style
        final roNumber = 'RO-${ro.id.toString().padLeft(4, '0')}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeaderStatic('REPAIR ORDER'),
            GestureDetector(
              onTap: () => context.push('/repair-orders/ros/${ro.id}'),
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.doc_text_fill,
                        size: 18, color: const Color(0xFF34C759)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'View Repair Order',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF34C759)),
                          ),
                          Text(
                            roNumber,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 16, color: Color(0xFFC7C7CC)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Action Row ───────────────────────────────────────────────────────────────
// Standard action button style: blue icon + blue label + gray chevron.
// Matches the "New Estimate" row on the vehicle detail screen.
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF007AFF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
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
    );
  }
}

// A static (non-instance) version of _sectionHeader for use inside
// ConsumerWidgets that don't have access to the _EstimateDetailView instance.
Widget _sectionHeaderStatic(String label) => Padding(
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
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 15,
              fontWeight:
                  bold ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 15,
              fontWeight:
                  bold ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../../widgets/context_menu.dart';
import 'estimates_provider.dart';

// Formats a number as a dollar amount: 1234.5 → "$1,234.50"
String _formatMoney(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '\$$dollars.${parts[1]}';
}

// "EST-0001", "EST-0002", etc.
String _estimateNumber(int id) => 'EST-${id.toString().padLeft(4, '0')}';

// Calculates the grand total of an estimate's line items.
double _calcTotal(List<EstimateLineItem> items, double taxRate) {
  final subtotal = items.fold(0.0, (s, i) => s + i.quantity * fromCents(i.unitPrice));
  return subtotal + subtotal * (taxRate / 100);
}

class EstimateListScreen extends ConsumerStatefulWidget {
  const EstimateListScreen({super.key});

  @override
  ConsumerState<EstimateListScreen> createState() => _EstimateListScreenState();
}

class _EstimateListScreenState extends ConsumerState<EstimateListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final estimatesAsync = ref.watch(estimatesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Estimates'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/records/estimates/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: estimatesAsync.when(
          loading: () =>
              const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (estimates) {
            // Filter estimates by search query
            final q = _search.toLowerCase();
            final filtered = q.isEmpty
                ? estimates
                : estimates.where((item) {
                    final num = _estimateNumber(item.estimate.id).toLowerCase();
                    final customer = (item.customer?.name ?? '').toLowerCase();
                    final vehicle = item.vehicle != null
                        ? [
                            item.vehicle!.year?.toString() ?? '',
                            item.vehicle!.make,
                            item.vehicle!.model,
                          ].join(' ').toLowerCase()
                        : '';
                    return num.contains(q) ||
                        customer.contains(q) ||
                        vehicle.contains(q);
                  }).toList();

            return Column(
              children: [
                // ── Search bar ─────────────────────────────────────────────
                Container(
                  color: CupertinoColors.systemGroupedBackground,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: CupertinoSearchTextField(
                    placeholder: 'Search estimates…',
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.doc_fill,
                                size: 48,
                                color: Color(0xFFC7C7CC),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _search.isEmpty
                                    ? 'No estimates yet'
                                    : 'No results for "$_search"',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _search.isEmpty
                                    ? 'Tap + to create your first estimate'
                                    : 'Try a different search term',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              return _EstimateRow(item: filtered[i]);
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EstimateRow extends ConsumerWidget {
  final EstimateWithDetails item;
  const _EstimateRow({required this.item});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text('Delete ${_estimateNumber(item.estimate.id)}?'),
        content: const Text('All line items on this estimate will also be deleted. This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).deleteEstimate(item.estimate.id);
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
    final lineItemsAsync =
        ref.watch(lineItemsProvider(item.estimate.id));
    final lineItems = lineItemsAsync.value ?? [];
    final total = _calcTotal(lineItems, item.estimate.taxRate);

    final customerName = item.customer?.name ?? 'Unknown Customer';
    final vehicle = item.vehicle;
    final vehicleLabel = vehicle != null
        ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
            .whereType<String>()
            .join(' ')
        : 'No vehicle';

    final status = item.estimate.status;
    final statusColor = status == 'approved'
        ? const Color(0xFF34C759)
        : status == 'declined'
            ? const Color(0xFFFF3B30)
            : const Color(0xFF8E8E93);

    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
          onTap: () =>
              context.push('/records/estimates/${item.estimate.id}'),
          onSecondaryTapUp: (details) => showContextMenu(
            context: context,
            position: details.globalPosition,
            items: [
              ContextMenuAction(
                label: 'Open',
                icon: CupertinoIcons.doc_fill,
                onTap: () => context.push(
                    '/records/estimates/${item.estimate.id}'),
              ),
              contextMenuDivider,
              ContextMenuAction(
                label: 'Add Labor',
                icon: CupertinoIcons.wrench_fill,
                onTap: () => context.push(
                    '/records/estimates/${item.estimate.id}/line-items/labor'),
              ),
              ContextMenuAction(
                label: 'Add Part',
                icon: CupertinoIcons.cube_box_fill,
                onTap: () => context.push(
                    '/records/estimates/${item.estimate.id}/line-items/part'),
              ),
              contextMenuDivider,
              ContextMenuAction(
                label: 'Delete',
                icon: CupertinoIcons.trash,
                isDestructive: true,
                onTap: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          child: Container(
            color: CupertinoColors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Status dot
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _estimateNumber(item.estimate.id),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
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
                // Total + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lineItems.isEmpty ? '--' : _formatMoney(total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ),
          ),
        ),
        ),
        Container(
          height: 0.5,
          color: const Color(0xFFE5E5EA),
          margin: const EdgeInsets.only(left: 34),
        ),
      ],
    );
  }
}

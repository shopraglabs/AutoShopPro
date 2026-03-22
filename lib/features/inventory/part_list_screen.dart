import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'inventory_provider.dart';

class PartListScreen extends ConsumerStatefulWidget {
  const PartListScreen({super.key});

  @override
  ConsumerState<PartListScreen> createState() => _PartListScreenState();
}

class _PartListScreenState extends ConsumerState<PartListScreen> {
  String _search = '';

  // Returns a stock status label and color for a given part.
  ({String label, Color color}) _stockStatus(InventoryPart part) {
    if (part.stockQty <= 0) {
      return (label: 'Out of Stock', color: CupertinoColors.destructiveRed);
    }
    if (part.stockQty <= part.lowStockThreshold) {
      return (label: 'Low Stock', color: const Color(0xFFFF9500)); // system orange
    }
    return (label: 'In Stock', color: CupertinoColors.activeGreen);
  }

  @override
  Widget build(BuildContext context) {
    final partsAsync = ref.watch(inventoryPartsProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Parts Inventory'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/parts/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: partsAsync.when(
        loading: () =>
            const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (parts) {
          final filtered = _search.isEmpty
              ? parts
              : parts
                  .where((p) =>
                      p.description
                          .toLowerCase()
                          .contains(_search.toLowerCase()) ||
                      (p.partNumber
                              ?.toLowerCase()
                              .contains(_search.toLowerCase()) ??
                          false))
                  .toList();

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Search bar — scrolls with the list
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: CupertinoSearchTextField(
                      placeholder: 'Search parts…',
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      _search.isEmpty
                          ? 'No parts yet.\nTap + to add your first part.'
                          : 'No parts match "$_search".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final part = filtered[index];
                      final status = _stockStatus(part);
                      final isLast = index == filtered.length - 1;

                      return Container(
                        color: CupertinoColors.systemBackground,
                        child: Column(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  context.push('/parts/${part.id}/edit'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Stock dot
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: status.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // Part info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            part.description,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color:
                                                  CupertinoColors.label,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            [
                                              if (part.partNumber != null &&
                                                  part.partNumber!.isNotEmpty)
                                                part.partNumber!,
                                              '\$${part.sellPrice.toStringAsFixed(2)}',
                                              '${part.stockQty} in stock',
                                            ].join(' · '),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: CupertinoColors
                                                  .secondaryLabel,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: status.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: status.color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 16,
                                      color: Color(0xFFC7C7CC),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              Padding(
                                padding: const EdgeInsets.only(left: 38),
                                child: Container(
                                    height: 0.5,
                                    color: const Color(0xFFE5E5EA)),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

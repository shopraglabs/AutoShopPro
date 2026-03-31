import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

export '../customers/customers_provider.dart' show dbProvider;

// Emits a fresh list of all repair orders (with customer + vehicle attached)
// every time anything in the repair_orders table changes.
final repairOrdersProvider =
    StreamProvider<List<RepairOrderWithDetails>>((ref) {
  return ref.watch(dbProvider).watchAllRepairOrders();
});

// Emits a single repair order (or null) by id, updating whenever it changes.
final repairOrderProvider =
    StreamProvider.family<RepairOrder?, int>((ref, id) {
  return ref.watch(dbProvider).watchRepairOrder(id);
});

// Emits the RO linked to a specific estimate — null if none exists yet.
// The estimate detail screen uses this to show "Convert to RO" or "View RO".
final roForEstimateProvider =
    StreamProvider.family<RepairOrder?, int>((ref, estimateId) {
  return ref.watch(dbProvider).watchRoForEstimate(estimateId);
});

// Computes the post-tax total (in cents) for every closed RO.
// Returns Map<roId, totalCents> — used by the invoice list to show amounts on rows.
// Includes tax so the list amount matches the invoice the customer received.
// autoDispose so it refreshes when the screen is re-entered.
final invoiceTotalsProvider =
    FutureProvider.autoDispose<Map<int, int>>((ref) async {
  final db = ref.watch(dbProvider);
  final allRos = await db.watchAllRepairOrders().first;
  final closedROs = allRos.where((r) => r.ro.status == 'closed').toList();

  // Bulk-fetch all line items for closed ROs in one query (avoids N+1).
  final estimateIds = closedROs
      .where((r) => r.ro.estimateId != null)
      .map((r) => r.ro.estimateId!)
      .toList();
  final allItems = await db.getLineItemsForEstimates(estimateIds);
  final itemsByEstimate = <int, List<EstimateLineItem>>{};
  for (final item in allItems) {
    itemsByEstimate.putIfAbsent(item.estimateId, () => []).add(item);
  }

  // Also fetch estimates to get the tax rate for each RO (avoids N+1).
  final estimateList = await db.getEstimatesByIds(estimateIds);
  final taxRateByEstimate = <int, double>{
    for (final e in estimateList) e.id: e.taxRate,
  };

  final totals = <int, int>{};
  for (final roDetail in closedROs) {
    final ro = roDetail.ro;
    if (ro.estimateId == null) {
      totals[ro.id] = 0;
      continue;
    }
    final items = itemsByEstimate[ro.estimateId!] ?? [];
    final subtotalCents = items
        .where((i) => i.approvalStatus != 'declined')
        .fold<int>(0, (sum, i) => sum + (i.quantity * i.unitPrice).round());
    // Prefer snapshotted tax rate (v33+); fall back to estimate.taxRate for older ROs.
    final taxRate = ro.taxRateBps != null
        ? ro.taxRateBps! / 100.0
        : (taxRateByEstimate[ro.estimateId!] ?? 0.0);
    final taxCents = (subtotalCents * taxRate / 100).round();
    totals[ro.id] = subtotalCents + taxCents;
  }
  return totals;
});

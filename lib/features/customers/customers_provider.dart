import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';

// The single AppDatabase instance shared across the whole app.
// Riverpod creates it once and disposes it when the app closes.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Emits a fresh, sorted list of customers every time the database changes.
// Any screen that watches this will rebuild automatically when a customer
// is added, edited, or deleted.
final customersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(dbProvider).watchAllCustomers();
});

// Emits a single customer (or null) by id — rebuilds when that customer changes.
final customerProvider =
    StreamProvider.family<Customer?, int>((ref, customerId) {
  return ref.watch(dbProvider).watchCustomer(customerId);
});

// Emits a single vehicle (or null) by id — rebuilds when that vehicle changes.
final vehicleProvider =
    StreamProvider.family<Vehicle?, int>((ref, vehicleId) {
  return ref.watch(dbProvider).watchVehicle(vehicleId);
});

// Emits a fresh list of vehicles for a specific customer.
// Pass the customer's id as a parameter.
final vehiclesProvider =
    StreamProvider.family<List<Vehicle>, int>((ref, customerId) {
  return ref.watch(dbProvider).watchVehiclesForCustomer(customerId);
});

// ─── Customer lifetime stats ───────────────────────────────────────────────────

/// Aggregated financial history for one customer.
class CustomerStats {
  /// Sum of all closed invoice totals (in dollars).
  final double totalSpent;

  /// Number of closed repair orders (visits).
  final int visitCount;

  /// Service date of the most recent closed RO, or null if none.
  final DateTime? lastVisit;

  const CustomerStats({
    required this.totalSpent,
    required this.visitCount,
    required this.lastVisit,
  });
}

/// Computes lifetime stats for a customer from their closed ROs.
/// autoDispose so it refreshes when the screen is re-entered.
final customerStatsProvider =
    FutureProvider.autoDispose.family<CustomerStats, int>((ref, customerId) async {
  final db = ref.watch(dbProvider);

  // Get all ROs for this customer
  final allRos = await db.watchRepairOrdersForCustomer(customerId).first;
  final closed = allRos.where((r) => r.ro.status == 'closed').toList();

  if (closed.isEmpty) {
    return const CustomerStats(totalSpent: 0, visitCount: 0, lastVisit: null);
  }

  // Bulk-fetch all line items for this customer's closed ROs in one query.
  final estimateIds = closed
      .where((r) => r.ro.estimateId != null)
      .map((r) => r.ro.estimateId!)
      .toList();
  final allItems = await db.getLineItemsForEstimates(estimateIds);
  final itemsByEstimate = <int, List<dynamic>>{};
  for (final item in allItems) {
    itemsByEstimate.putIfAbsent(item.estimateId, () => []).add(item);
  }

  int totalCents = 0;
  for (final roDetail in closed) {
    final ro = roDetail.ro;
    if (ro.estimateId == null) continue;
    final items = itemsByEstimate[ro.estimateId!] ?? [];
    totalCents += items
        .where((i) => i.approvalStatus != 'declined')
        .fold<int>(0, (sum, i) => sum + (i.quantity * i.unitPrice).round());
  }

  // Most recent service date (or createdAt if no serviceDate)
  final dates = closed.map((r) => r.ro.serviceDate ?? r.ro.createdAt).toList()
    ..sort((a, b) => b.compareTo(a));

  return CustomerStats(
    totalSpent: fromCents(totalCents),
    visitCount: closed.length,
    lastVisit: dates.first,
  );
});

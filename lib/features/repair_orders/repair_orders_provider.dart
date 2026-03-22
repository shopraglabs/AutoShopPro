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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

export '../customers/customers_provider.dart' show dbProvider;

// Emits a fresh list of all estimates (with customer + vehicle data attached)
// every time anything in the estimates table changes.
final estimatesProvider =
    StreamProvider<List<EstimateWithDetails>>((ref) {
  return ref.watch(dbProvider).watchAllEstimates();
});

// Emits fresh line items for a specific estimate every time that estimate
// is edited.
final lineItemsProvider =
    StreamProvider.family<List<EstimateLineItem>, int>((ref, estimateId) {
  return ref.watch(dbProvider).watchLineItems(estimateId);
});

// Emits a single estimate (or null) by id, updating whenever it changes.
final estimateProvider =
    StreamProvider.family<Estimate?, int>((ref, estimateId) {
  return ref.watch(dbProvider).watchEstimate(estimateId);
});

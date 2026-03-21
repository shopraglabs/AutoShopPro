import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

export '../customers/customers_provider.dart' show dbProvider;

// Emits a fresh, sorted list of vendors every time the table changes.
final vendorsProvider = StreamProvider<List<Vendor>>((ref) {
  return ref.watch(dbProvider).watchAllVendors();
});

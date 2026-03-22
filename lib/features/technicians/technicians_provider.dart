import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

export '../customers/customers_provider.dart' show dbProvider;

// Emits a live-updating list of all technicians, sorted by name.
final techniciansProvider = StreamProvider<List<Technician>>((ref) {
  return ref.watch(dbProvider).watchAllTechnicians();
});

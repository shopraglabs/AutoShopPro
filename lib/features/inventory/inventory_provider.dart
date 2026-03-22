import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

// Provides a live stream of all inventory parts, sorted alphabetically.
final inventoryPartsProvider = StreamProvider<List<InventoryPart>>((ref) {
  final db = ref.watch(dbProvider);
  return db.watchAllParts();
});

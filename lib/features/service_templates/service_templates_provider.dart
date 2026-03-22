import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart' show dbProvider;

// Live stream of all service templates, alphabetical by name.
final serviceTemplatesProvider =
    StreamProvider<List<ServiceTemplate>>((ref) {
  return ref.watch(dbProvider).watchAllServiceTemplates();
});

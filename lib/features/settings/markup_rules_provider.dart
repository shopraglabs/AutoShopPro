import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

// Live stream of all markup rules, ordered by minCost ascending.
final markupRulesProvider = StreamProvider<List<MarkupRule>>((ref) {
  return ref.watch(dbProvider).watchAllMarkupRules();
});

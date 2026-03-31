import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart' show dbProvider;

// Global search screen. Searches customers, vehicles, estimates, and ROs
// simultaneously as the user types. Results are grouped by category.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  Timer? _debounce;

  // Search results
  List<Customer> _customers = [];
  List<Vehicle> _vehicles = [];
  List<EstimateWithDetails> _estimates = [];
  List<RepairOrderWithDetails> _ros = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onQueryChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _searchCtrl.text.trim();
    if (q == _query) return;
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _customers = [];
        _vehicles = [];
        _estimates = [];
        _ros = [];
        _searching = false;
      } else {
        _searching = true;
      }
    });
    if (q.isNotEmpty) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 200), () => _runSearch(q));
    }
  }

  Future<void> _runSearch(String q) async {
    final db = ref.read(dbProvider);
    final results = await Future.wait([
      db.searchCustomers(q),
      db.searchVehicles(q),
      db.searchEstimates(q),
      db.searchRepairOrders(q),
    ]);
    if (!mounted || _query != q) return; // stale result — discard
    setState(() {
      _customers = results[0] as List<Customer>;
      _vehicles = results[1] as List<Vehicle>;
      _estimates = results[2] as List<EstimateWithDetails>;
      _ros = results[3] as List<RepairOrderWithDetails>;
      _searching = false;
    });
  }

  bool get _hasResults =>
      _customers.isNotEmpty ||
      _vehicles.isNotEmpty ||
      _estimates.isNotEmpty ||
      _ros.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchCtrl,
                autofocus: true,
                placeholder: 'Search everything…',
              ),
            ),
            Container(height: 0.5, color: const Color(0xFFE5E5EA)),

            // ── Results ─────────────────────────────────────────────────────
            Expanded(
              child: _query.isEmpty
                  ? _emptyPrompt()
                  : _searching
                      ? const Center(child: CupertinoActivityIndicator())
                      : !_hasResults
                          ? _noResults()
                          : ListView(
                              children: [
                                if (_customers.isNotEmpty) ...[
                                  _sectionHeader('CUSTOMERS'),
                                  ..._customers.map((c) =>
                                      _CustomerResult(customer: c)),
                                  const SizedBox(height: 16),
                                ],
                                if (_vehicles.isNotEmpty) ...[
                                  _sectionHeader('VEHICLES'),
                                  ..._vehicles.map((v) =>
                                      _VehicleResult(vehicle: v)),
                                  const SizedBox(height: 16),
                                ],
                                if (_estimates.isNotEmpty) ...[
                                  _sectionHeader('ESTIMATES'),
                                  ..._estimates.map((e) =>
                                      _EstimateResult(detail: e)),
                                  const SizedBox(height: 16),
                                ],
                                if (_ros.isNotEmpty) ...[
                                  _sectionHeader('REPAIR ORDERS'),
                                  ..._ros.map((r) =>
                                      _RoResult(detail: r)),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPrompt() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.search, size: 48, color: Color(0xFFD1D1D6)),
            SizedBox(height: 12),
            Text('Search customers, vehicles,',
                style:
                    TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
            Text('estimates, and repair orders.',
                style:
                    TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
          ],
        ),
      );

  Widget _noResults() => Center(
        child: Text(
          'No results for "$_query"',
          style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
        ),
      );

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8E8E93),
            letterSpacing: 0.5,
          ),
        ),
      );
}

// ─── Result Row Widgets ───────────────────────────────────────────────────────

class _CustomerResult extends StatelessWidget {
  final Customer customer;
  const _CustomerResult({required this.customer});

  @override
  Widget build(BuildContext context) {
    return _ResultRow(
      icon: CupertinoIcons.person_fill,
      title: customer.name,
      subtitle: customer.phone ?? customer.email ?? '',
      onTap: () => context
          .push('/records/customers/${customer.id}'),
    );
  }
}

class _VehicleResult extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleResult({required this.vehicle});

  String get _title {
    final parts = [
      if (vehicle.year != null) vehicle.year.toString(),
      vehicle.make ?? '',
      vehicle.model ?? '',
    ].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? 'Vehicle' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return _ResultRow(
      icon: CupertinoIcons.car_fill,
      title: _title,
      subtitle: vehicle.licensePlate ?? vehicle.vin ?? '',
      onTap: () => context.push(
          '/records/customers/${vehicle.customerId}/vehicles/${vehicle.id}'),
    );
  }
}

class _EstimateResult extends StatelessWidget {
  final EstimateWithDetails detail;
  const _EstimateResult({required this.detail});

  @override
  Widget build(BuildContext context) {
    final estNum = 'EST-${detail.estimate.id.toString().padLeft(4, '0')}';
    final customer = detail.customer?.name ?? '';
    return _ResultRow(
      icon: CupertinoIcons.doc_text,
      title: estNum,
      subtitle: customer,
      onTap: () => context.push(
          '/records/estimates/${detail.estimate.id}'),
    );
  }
}

class _RoResult extends StatelessWidget {
  final RepairOrderWithDetails detail;
  const _RoResult({required this.detail});

  @override
  Widget build(BuildContext context) {
    final roNum = 'RO-${detail.ro.id.toString().padLeft(4, '0')}';
    final customer = detail.customer?.name ?? '';
    return _ResultRow(
      icon: CupertinoIcons.wrench_fill,
      title: roNum,
      subtitle: customer,
      onTap: () =>
          context.push('/records/ros/${detail.ro.id}'),
    );
  }
}

// ─── Generic Result Row ───────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResultRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF007AFF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF1C1C1E))),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF8E8E93))),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right,
                size: 16, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }
}

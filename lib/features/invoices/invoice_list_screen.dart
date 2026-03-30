import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../repair_orders/repair_orders_provider.dart';

// Formats an RO id as an invoice number: 42 → "INV-0042"
String _invNumber(int id) => 'INV-${id.toString().padLeft(4, '0')}';

// Formats a DateTime as e.g. "Jan 15, 2026".
// Returns "—" for corrupted years outside 1900–2100.
String _fmtDate(DateTime d) {
  if (d.year < 1900 || d.year > 2100) return '—';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

// Returns a short vehicle label like "2019 Honda Civic" or null.
String? _vehicleLabel(Vehicle? v) {
  if (v == null) return null;
  return [v.year?.toString(), v.make, v.model]
      .whereType<String>()
      .join(' ')
      .trim()
      .isNotEmpty
      ? [v.year?.toString(), v.make, v.model]
          .whereType<String>()
          .join(' ')
      : null;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

/// The Payments → Invoices screen.
/// Shows all closed repair orders as invoices, newest first.
/// Tapping a row opens the full RO detail screen.
class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(repairOrdersProvider);
    // Load totals for all closed ROs — null while loading (rows just show no amount)
    final totals = ref.watch(invoiceTotalsProvider).value;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Invoices'),
      ),
      child: SafeArea(
        child: allAsync.when(
        loading: () =>
            const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allRos) {
          // Only show closed ROs — these are the invoices.
          final invoices = allRos
              .where((r) => r.ro.status == 'closed')
              .toList();

          // Apply search filter
          final filtered = _query.isEmpty
              ? invoices
              : invoices.where((r) {
                  final q = _query.toLowerCase();
                  final num = _invNumber(r.ro.id).toLowerCase();
                  final customer = (r.customer?.name ?? '').toLowerCase();
                  final vehicle = (_vehicleLabel(r.vehicle) ?? '').toLowerCase();
                  return num.contains(q) ||
                      customer.contains(q) ||
                      vehicle.contains(q);
                }).toList();

          return CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: CupertinoSearchTextField(
                    placeholder: 'Search invoices…',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              // Empty state
              if (invoices.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 48,
                          color: Color(0xFFC7C7CC),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No Invoices Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        SizedBox(height: 6),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Close a repair order to generate an invoice.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No results',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Container(
                    color: CupertinoColors.white,
                    child: Column(
                      children: [
                        for (int i = 0; i < filtered.length; i++) ...[
                          _InvoiceRow(
                            details: filtered[i],
                            totalCents: totals?[filtered[i].ro.id],
                          ),
                          if (i < filtered.length - 1)
                            Container(
                              height: 0.5,
                              color: const Color(0xFFE5E5EA),
                              margin: const EdgeInsets.only(left: 16),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
      ),
    );
  }
}

// ─── Row widget ───────────────────────────────────────────────────────────────

class _InvoiceRow extends StatefulWidget {
  final RepairOrderWithDetails details;
  /// Total amount in cents — null while the totals provider is still loading.
  final int? totalCents;
  const _InvoiceRow({required this.details, this.totalCents});

  @override
  State<_InvoiceRow> createState() => _InvoiceRowState();
}

class _InvoiceRowState extends State<_InvoiceRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final ro = widget.details.ro;
    final customer = widget.details.customer;
    final vehicle = widget.details.vehicle;
    final date = ro.serviceDate ?? ro.createdAt;
    final vehicleLabel = _vehicleLabel(vehicle);

    // Format the total for display, or show nothing while loading
    final totalLabel = widget.totalCents != null
        ? formatMoney(widget.totalCents!)
        : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push('/payments/${ro.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hovered
              ? const Color(0xFFF0F0F5)
              : CupertinoColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Invoice icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.doc_text_fill,
                  size: 20,
                  color: Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 12),
              // Invoice number + customer + vehicle + total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _invNumber(ro.id),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const Spacer(),
                        if (totalLabel != null)
                          Text(
                            totalLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer?.name ?? 'Unknown Customer',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3C3C43),
                            ),
                          ),
                        ),
                        Text(
                          _fmtDate(date),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                    if (vehicleLabel != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        vehicleLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

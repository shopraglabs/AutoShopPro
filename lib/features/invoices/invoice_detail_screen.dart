import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';
import '../estimates/estimates_provider.dart';
import '../invoices/invoice_service.dart';
import '../repair_orders/repair_orders_provider.dart';

// Formats an RO id as an invoice number: 42 → "INV-0042"
String _invNumber(int id) => 'INV-${id.toString().padLeft(4, '0')}';

// Formats a DateTime as e.g. "Jan 15, 2026"
String _fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

// Formats a double as a dollar amount. Omits cents when zero.
String _money(double amount) {
  final hasCents = amount % 1 != 0;
  final str = hasCents ? amount.toStringAsFixed(2) : amount.toInt().toString();
  final parts = str.split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return hasCents ? '\$$dollars.${parts[1]}' : '\$$dollars';
}

String _qty(double q) =>
    q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);

// ─── Screen ───────────────────────────────────────────────────────────────────

/// A read-only invoice view for a closed repair order.
/// Reached from the Invoices list — shows customer info, vehicle, line items,
/// totals, and actions for generating the invoice PDF.
class InvoiceDetailScreen extends ConsumerWidget {
  final int roId;
  const InvoiceDetailScreen({super.key, required this.roId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roAsync = ref.watch(repairOrderProvider(roId));

    return roAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Invoice')),
        child: Center(child: Text('Error: $e')),
      ),
      data: (ro) {
        if (ro == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Invoice')),
            child: Center(child: Text('Invoice not found.')),
          );
        }

        // Watch line items from the linked estimate (if any)
        final lineItemsAsync = ro.estimateId != null
            ? ref.watch(lineItemsProvider(ro.estimateId!))
            : const AsyncValue.data(<EstimateLineItem>[]);

        // Watch estimate for tax rate + customer complaint
        final estimateAsync = ro.estimateId != null
            ? ref.watch(estimateProvider(ro.estimateId!))
            : const AsyncValue.data(null);
        final taxRate = estimateAsync.value?.taxRate ?? 0.0;
        final complaint = estimateAsync.value?.customerComplaint;

        // Watch customer
        final customerAsync = ref.watch(customerProvider(ro.customerId));

        // Watch vehicle (if linked)
        final vehicleAsync = ro.vehicleId != null
            ? ref.watch(vehicleProvider(ro.vehicleId!))
            : const AsyncValue.data(null);

        return _InvoiceDetailView(
          ro: ro,
          lineItemsAsync: lineItemsAsync,
          taxRate: taxRate,
          customerComplaint: complaint,
          customerAsync: customerAsync,
          vehicleAsync: vehicleAsync,
        );
      },
    );
  }
}

// ─── Detail view ─────────────────────────────────────────────────────────────

class _InvoiceDetailView extends ConsumerWidget {
  final RepairOrder ro;
  final AsyncValue<List<EstimateLineItem>> lineItemsAsync;
  final double taxRate;
  final String? customerComplaint;
  final AsyncValue<Customer?> customerAsync;
  final AsyncValue<Vehicle?> vehicleAsync;

  const _InvoiceDetailView({
    required this.ro,
    required this.lineItemsAsync,
    this.taxRate = 0.0,
    this.customerComplaint,
    required this.customerAsync,
    required this.vehicleAsync,
  });

  Future<void> _generateInvoice(
    BuildContext context,
    WidgetRef ref, {
    bool simple = false,
    Offset? position,
  }) async {
    final db = ref.read(dbProvider);
    final settings = await db.getOrCreateSettings();

    final customer = customerAsync.value;
    if (customer == null) return;

    final vehicle = vehicleAsync.value;

    final lineItems = (lineItemsAsync.value ?? [])
        .where((l) => l.approvalStatus != 'declined')
        .toList();
    final declinedItems = (lineItemsAsync.value ?? [])
        .where((l) => l.approvalStatus == 'declined')
        .toList();

    if (!context.mounted) return;
    await showInvoiceActions(
      context: context,
      ro: ro,
      customer: customer,
      vehicle: vehicle,
      lineItems: lineItems,
      declinedItems: declinedItems,
      taxRate: taxRate,
      shopName: settings.shopName,
      customerComplaint: customerComplaint,
      comment: ro.comment,
      simple: simple,
      position: position,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ro.serviceDate ?? ro.createdAt;
    final customer = customerAsync.value;
    final vehicle = vehicleAsync.value;
    final allItems = lineItemsAsync.value ?? [];
    final approved = allItems.where((i) => i.approvalStatus != 'declined').toList();
    final declined = allItems.where((i) => i.approvalStatus == 'declined').toList();

    // Group approved items by type
    final labor = approved.where((i) => i.type == 'labor').toList();
    final parts = approved.where((i) => i.type == 'part').toList();
    final other = approved.where((i) => i.type == 'other').toList();

    // Totals — stay in integer cents to avoid floating-point rounding errors.
    final subtotalCents = approved.fold(0, (s, i) => s + (i.quantity * i.unitPrice).round());
    final taxCents = (subtotalCents * taxRate / 100).round();
    final totalCents = subtotalCents + taxCents;
    final subtotal = fromCents(subtotalCents);
    final taxAmount = fromCents(taxCents);
    final total = fromCents(totalCents);

    // Gross Profit — only deduct items that have a known cost (unitCost > 0).
    // Labor without unitCost is treated as 100% margin; using unitPrice instead
    // would incorrectly zero out labor revenue from the GP calculation.
    final hasCostData = approved.any((i) => i.unitCost != null && i.unitCost! > 0);
    final totalCostCents = approved
        .where((i) => i.unitCost != null && i.unitCost! > 0)
        .fold(0, (s, i) => s + (i.quantity * i.unitCost!).round());
    final grossProfit = fromCents(subtotalCents - totalCostCents);
    final gpPct = subtotal > 0 ? (grossProfit / subtotal * 100) : 0.0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_invNumber(ro.id)),
      ),
      child: SafeArea(
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Invoice header ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF34C759).withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            CupertinoIcons.doc_text_fill,
                            size: 22,
                            color: Color(0xFF34C759),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _invNumber(ro.id),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            Text(
                              _fmtDate(date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _money(total),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Customer ──────────────────────────────────────────────
                  if (customer != null) ...[
                    _sectionHeader('CUSTOMER'),
                    Container(
                      color: CupertinoColors.white,
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Name',
                            value: customer.name,
                          ),
                          if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                            _divider(),
                            _InfoRow(label: 'Phone', value: customer.phone!),
                          ],
                          if (customer.email != null && customer.email!.isNotEmpty) ...[
                            _divider(),
                            _InfoRow(label: 'Email', value: customer.email!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Vehicle ───────────────────────────────────────────────
                  if (vehicle != null) ...[
                    _sectionHeader('VEHICLE'),
                    Container(
                      color: CupertinoColors.white,
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Vehicle',
                            value: [vehicle.year?.toString(), vehicle.make, vehicle.model]
                                .whereType<String>()
                                .join(' '),
                          ),
                          if (vehicle.licensePlate != null && vehicle.licensePlate!.isNotEmpty) ...[
                            _divider(),
                            _InfoRow(label: 'Plate', value: vehicle.licensePlate!),
                          ],
                          if (vehicle.vin != null && vehicle.vin!.isNotEmpty) ...[
                            _divider(),
                            _InfoRow(label: 'VIN', value: vehicle.vin!),
                          ],
                          if (vehicle.mileage != null && vehicle.mileage! > 0) ...[
                            _divider(),
                            _InfoRow(
                              label: 'Mileage',
                              value: vehicle.mileage!
                                  .toString()
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Customer complaint ────────────────────────────────────
                  if (customerComplaint != null && customerComplaint!.isNotEmpty) ...[
                    _sectionHeader('CUSTOMER CONCERN'),
                    Container(
                      width: double.infinity,
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        customerComplaint!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Line items ────────────────────────────────────────────
                  if (approved.isNotEmpty) ...[
                    _sectionHeader('SERVICES'),
                    Container(
                      color: CupertinoColors.white,
                      child: Column(
                        children: [
                          // Labor rows (with linked parts underneath)
                          for (int li = 0; li < labor.length; li++) ...[
                            _LaborRow(item: labor[li]),
                            // Linked parts under this labor line
                            ...parts
                                .where((p) => p.parentLaborId == labor[li].id)
                                .map((p) => _PartSubRow(item: p)),
                            if (li < labor.length - 1 ||
                                parts.any((p) => p.parentLaborId == null) ||
                                other.isNotEmpty)
                              _divider(),
                          ],
                          // Unlinked parts
                          ...(() {
                            final unlinked = parts
                                .where((p) => p.parentLaborId == null)
                                .toList();
                            return [
                              for (int pi = 0; pi < unlinked.length; pi++) ...[
                                _PartRow(item: unlinked[pi]),
                                if (pi < unlinked.length - 1 || other.isNotEmpty)
                                  _divider(),
                              ],
                            ];
                          })(),
                          // Other items
                          for (int oi = 0; oi < other.length; oi++) ...[
                            _OtherRow(item: other[oi]),
                            if (oi < other.length - 1) _divider(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Totals ────────────────────────────────────────────────
                  _sectionHeader('TOTALS'),
                  Container(
                    color: CupertinoColors.white,
                    child: Column(
                      children: [
                        _TotalsRow(label: 'Subtotal', value: _money(subtotal)),
                        _divider(),
                        _TotalsRow(
                          label: taxRate > 0
                              ? 'Tax (${taxRate.toStringAsFixed(taxRate % 1 == 0 ? 0 : 1)}%)'
                              : 'Tax',
                          value: _money(taxAmount),
                        ),
                        _divider(),
                        _TotalsRow(
                          label: 'Total',
                          value: _money(total),
                          bold: true,
                        ),
                        // Gross Profit row — only shown when cost data is present
                        if (hasCostData) ...[
                          _divider(),
                          _TotalsRow(
                            label: 'Gross Profit'
                                ' (${gpPct.toStringAsFixed(gpPct % 1 == 0 ? 0 : 1)}%)',
                            value: grossProfit < 0
                                ? '-${_money(grossProfit.abs())}'
                                : _money(grossProfit),
                            valueColor: grossProfit >= 0
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF3B30),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Declined items ────────────────────────────────────────
                  if (declined.isNotEmpty) ...[
                    _sectionHeader('DECLINED — NOT BILLED'),
                    Container(
                      color: CupertinoColors.white,
                      child: Column(
                        children: [
                          for (int di = 0; di < declined.length; di++) ...[
                            _DeclinedRow(item: declined[di]),
                            if (di < declined.length - 1) _divider(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Invoice comment ───────────────────────────────────────
                  if (ro.comment != null && ro.comment!.isNotEmpty) ...[
                    _sectionHeader('INVOICE COMMENT'),
                    Container(
                      width: double.infinity,
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        ro.comment!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Actions ───────────────────────────────────────────────
                  _sectionHeader('ACTIONS'),
                  Container(
                    color: CupertinoColors.white,
                    child: Column(
                      children: [
                        // Itemized Invoice PDF
                        _ActionRow(
                          icon: CupertinoIcons.doc_text,
                          label: 'Itemized Invoice PDF',
                          onTap: (position) => _generateInvoice(
                              context, ref, simple: false, position: position),
                        ),
                        _divider(),
                        // Simple Invoice PDF
                        _ActionRow(
                          icon: CupertinoIcons.doc,
                          label: 'Simple Invoice PDF',
                          onTap: (position) => _generateInvoice(
                              context, ref, simple: true, position: position),
                        ),
                        _divider(),
                        // View Repair Order
                        _ActionRow(
                          icon: CupertinoIcons.wrench,
                          label: 'View Repair Order',
                          onTap: (_) =>
                              context.push('/repair-orders/ros/${ro.id}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8E8E93),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 0.5,
        color: const Color(0xFFE5E5EA),
        margin: const EdgeInsets.only(left: 16),
      );
}

// ─── Info row (label + value) ─────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Labor row ────────────────────────────────────────────────────────────────

class _LaborRow extends StatelessWidget {
  final EstimateLineItem item;
  const _LaborRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.quantity * fromCents(item.unitPrice);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.laborName != null && item.laborName!.isNotEmpty)
                  Text(
                    item.laborName!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: item.laborName != null && item.laborName!.isNotEmpty
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF1C1C1E),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  '${_qty(item.quantity)} hrs × ${_money(fromCents(item.unitPrice))}/hr',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(lineTotal),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Part row ─────────────────────────────────────────────────────────────────

class _PartRow extends StatelessWidget {
  final EstimateLineItem item;
  const _PartRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.quantity * fromCents(item.unitPrice);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_qty(item.quantity)} × ${_money(fromCents(item.unitPrice))}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(lineTotal),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Part sub-row (linked under a labor line) ─────────────────────────────────

class _PartSubRow extends StatelessWidget {
  final EstimateLineItem item;
  const _PartSubRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.quantity * fromCents(item.unitPrice);
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.fromLTRB(32, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_qty(item.quantity)} × ${item.description}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3C3C43),
              ),
            ),
          ),
          Text(
            _money(lineTotal),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3C3C43),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Other row ────────────────────────────────────────────────────────────────

class _OtherRow extends StatelessWidget {
  final EstimateLineItem item;
  const _OtherRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.quantity * fromCents(item.unitPrice);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.laborName ?? item.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                if (item.laborName != null &&
                    item.laborName!.isNotEmpty &&
                    item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(lineTotal),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Declined row ─────────────────────────────────────────────────────────────

class _DeclinedRow extends StatelessWidget {
  final EstimateLineItem item;
  const _DeclinedRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.xmark_circle_fill,
            size: 16,
            color: Color(0xFFFF3B30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.laborName != null && item.laborName!.isNotEmpty
                  ? item.laborName!
                  : item.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Totals row ───────────────────────────────────────────────────────────────

class _TotalsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _TotalsRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF1C1C1E),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action row ───────────────────────────────────────────────────────────────

/// A standard list-row style action button (blue icon + label + chevron).
/// The onTap callback receives the tap position for context menu positioning on desktop.
class _ActionRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final void Function(Offset? position) onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapUp: (details) => widget.onTap(details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hovered
              ? const Color(0xFFF0F0F5)
              : CupertinoColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: const Color(0xFF007AFF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
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

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../estimates/estimates_provider.dart';
import '../invoices/invoice_service.dart';
import '../technicians/technicians_provider.dart';
import 'repair_orders_provider.dart';

String _roNumber(int id) => 'RO-${id.toString().padLeft(4, '0')}';

// Formats a DateTime as a readable date string, e.g. "Jan 20, 2026".
// Returns "—" for dates with obviously corrupted years (outside 1900–2100).
String _fmtDate(DateTime d) {
  if (d.year < 1900 || d.year > 2100) return '—';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

// Formats a double as a dollar amount. Omits cents when zero:
// 1234.0 → "$1,234"  |  1234.5 → "$1,234.50"
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

// ─── Status helpers ───────────────────────────────────────────────────────────

String _statusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Open';
    case 'closed':
      return 'Closed';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'open':
      return const Color(0xFF007AFF);
    case 'closed':
      return const Color(0xFF8E8E93);
    default:
      return const Color(0xFF8E8E93);
  }
}

// Returns the icon for the advancement button based on current status.
IconData _nextIcon(String status) {
  switch (status) {
    case 'open':
      return CupertinoIcons.lock_fill;
    default:
      return CupertinoIcons.chevron_right;
  }
}

// Returns the label and next status for the advancement button.
// Returns null when the RO is closed (no further advancement possible).
({String buttonLabel, String nextStatus})? _nextStep(String status) {
  switch (status) {
    case 'open':
      return (buttonLabel: 'Close Repair Order', nextStatus: 'closed');
    default:
      return null; // closed — nothing left to do
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RoDetailScreen extends ConsumerWidget {
  final int roId;
  const RoDetailScreen({super.key, required this.roId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roAsync = ref.watch(repairOrderProvider(roId));

    return roAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Repair Order')),
        child: Center(child: Text('Error: $e')),
      ),
      data: (ro) {
        if (ro == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Repair Order')),
            child: Center(child: Text('Repair order not found.')),
          );
        }
        // If this RO came from an estimate, stream those line items live.
        // If no estimate, show an empty list.
        final lineItemsAsync = ro.estimateId != null
            ? ref.watch(lineItemsProvider(ro.estimateId!))
            : const AsyncValue.data(<EstimateLineItem>[]);

        // Watch the estimate to get the tax rate (so RO totals match invoices).
        final estimateAsync = ro.estimateId != null
            ? ref.watch(estimateProvider(ro.estimateId!))
            : const AsyncValue.data(null);
        final taxRate = estimateAsync.value?.taxRate ?? 0.0;

        return _RoDetailView(
            ro: ro, lineItemsAsync: lineItemsAsync, taxRate: taxRate);
      },
    );
  }
}

// ─── Detail view ─────────────────────────────────────────────────────────────

class _RoDetailView extends ConsumerWidget {
  final RepairOrder ro;
  final AsyncValue<List<EstimateLineItem>> lineItemsAsync;
  final double taxRate;

  const _RoDetailView({
    required this.ro,
    required this.lineItemsAsync,
    this.taxRate = 0.0,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Delete repair order?'),
        content: const Text('This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).deleteRepairOrder(ro.id);
              if (context.mounted) context.go('/repair-orders/ros');
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCompleteAll(BuildContext context, WidgetRef ref) async {
    final items = (lineItemsAsync.value ?? [])
        .where((i) => i.approvalStatus != 'declined')
        .toList();
    final undone = items.where((i) => !(i.isDone ?? false)).toList();
    if (undone.isEmpty) return;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Complete All Services?'),
        content: Text(
            'Mark ${undone.length} item${undone.length == 1 ? '' : 's'} as done. Stock will be deducted for catalog parts.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Complete All'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = ref.read(dbProvider);
    // All line item updates and stock deductions in one atomic transaction.
    await db.transaction(() async {
      for (final item in undone) {
        await db.updateLineItem(item.copyWith(isDone: const Value(true)));
        if (item.type == 'part' && item.inventoryPartId != null) {
          final part = await db.getPart(item.inventoryPartId!);
          if (part != null) {
            // No floor clamp — negative stock is accurate (see _toggleDone).
            final newStock = part.stockQty - item.quantity.round();
            await db.updatePart(part.copyWith(stockQty: newStock));
          }
        }
      }
    });
  }

  Future<void> _generateInvoice(BuildContext context, WidgetRef ref,
      {bool simple = false, Offset? position}) async {
    final db = ref.read(dbProvider);
    final results = await Future.wait([
      db.getCustomer(ro.customerId),
      if (ro.vehicleId != null) db.getVehicle(ro.vehicleId!),
      if (ro.estimateId != null) db.getEstimate(ro.estimateId!),
      db.getOrCreateSettings(),
    ]);

    // Parse results in order — vehicle and estimate are only present when their IDs are set
    int idx = 0;
    final customer = results[idx++] as Customer?;
    if (customer == null) return;

    Vehicle? vehicle;
    if (ro.vehicleId != null) vehicle = results[idx++] as Vehicle?;

    Estimate? estimate;
    if (ro.estimateId != null) estimate = results[idx++] as Estimate?;

    final settings = results[idx] as ShopSetting;

    final lineItems = (lineItemsAsync.value ?? [])
        .where((l) => l.approvalStatus != 'declined')
        .toList();
    final declinedForInvoice = (lineItemsAsync.value ?? [])
        .where((l) => l.approvalStatus == 'declined')
        .toList();

    if (!context.mounted) return;
    await showInvoiceActions(
      context: context,
      ro: ro,
      customer: customer,
      vehicle: vehicle,
      lineItems: lineItems,
      declinedItems: declinedForInvoice,
      taxRate: estimate?.taxRate ?? 0.0,
      shopName: settings.shopName,
      customerComplaint: estimate?.customerComplaint,
      comment: ro.comment,
      simple: simple,
      position: position,
    );
  }

  Future<void> _advanceStatus(BuildContext context, WidgetRef ref, String nextStatus) async {
    final db = ref.read(dbProvider);

    // When closing, check for items that were never marked done.
    // Unchecked parts haven't had their stock deducted yet — we need to handle
    // them before closing so inventory stays accurate.
    if (nextStatus == 'closed') {
      final allItems = lineItemsAsync.value ?? [];
      final activeItems =
          allItems.where((l) => l.approvalStatus != 'declined').toList();
      final undone = activeItems
          .where((l) => l.type == 'part' && !(l.isDone ?? false))
          .toList();

      if (undone.isNotEmpty && context.mounted) {
        final confirmed = await showCupertinoDialog<bool>(
          context: context,
          builder: (dialogCtx) => CupertinoAlertDialog(
            title: const Text('Unchecked Items'),
            content: Text(
              '${undone.length} part${undone.length == 1 ? '' : 's'} not marked done. '
              'Mark them complete and deduct stock before closing?',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: const Text('Close Anyway'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(dialogCtx, true),
                child: const Text('Complete & Close'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await db.transaction(() async {
            for (final item in undone) {
              await db.updateLineItem(item.copyWith(isDone: const Value(true)));
              if (item.inventoryPartId != null) {
                final part = await db.getPart(item.inventoryPartId!);
                if (part != null) {
                  await db.updatePart(part.copyWith(
                      stockQty: part.stockQty - item.quantity.round()));
                }
              }
            }
          });
        }
      }
    }

    // When closing the RO, stamp serviceDate with today so the record reflects
    // when work was actually completed, not when it was first opened.
    final updatedRo = nextStatus == 'closed'
        ? ro.copyWith(status: nextStatus, serviceDate: Value(DateTime.now()))
        : ro.copyWith(status: nextStatus);
    await db.updateRepairOrder(updatedRo);
  }

  Future<void> _editComment(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: ro.comment ?? '');
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Invoice Comment'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'e.g. Warranty: 12 months / 12,000 miles',
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            contextMenuBuilder: (ctx, state) =>
                CupertinoAdaptiveTextSelectionToolbar.editableText(
                    editableTextState: state),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final text = controller.text.trim();
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).updateRepairOrder(
                    ro.copyWith(
                        comment: Value(text.isEmpty ? null : text)),
                  );
            },
            child: const Text('Save'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _pickServiceDate(BuildContext context, WidgetRef ref, RepairOrder ro) {
    final raw = ro.serviceDate ?? ro.createdAt;
    // Guard against corrupted imported dates which crash CupertinoDatePicker.
    final initial = (raw.year >= 1900 && raw.year <= 2100) ? raw : DateTime.now();
    DateTime picked = initial;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // Done button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () async {
                    await ref.read(dbProvider).updateRepairOrder(
                          ro.copyWith(serviceDate: Value(picked)),
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Done',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (d) => picked = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTechPicker(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, innerRef, _) {
          final techsAsync = innerRef.watch(techniciansProvider);
          final techs = techsAsync.value ?? [];
          return _TechPickerSheet(
            techs: techs,
            currentTechId: ro.technicianId,
            onSelect: (techId) async {
              await innerRef
                  .read(dbProvider)
                  .updateRepairOrder(ro.copyWith(technicianId: Value(techId)));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            onRemove: ro.technicianId != null
                ? () async {
                    await innerRef.read(dbProvider).updateRepairOrder(
                        ro.copyWith(technicianId: const Value(null)));
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                : null,
            onCreateNew: () {
              Navigator.pop(ctx);
              context.push('/repair-orders/technicians/new');
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Declined items are excluded from the repair order — only approved/pending work shows
    final lineItems = (lineItemsAsync.value ?? [])
        .where((l) => l.approvalStatus != 'declined')
        .toList();
    final declinedItems = (lineItemsAsync.value ?? [])
        .where((l) => l.approvalStatus == 'declined')
        .toList();
    final laborLines = lineItems.where((l) => l.type == 'labor').toList();
    final partLines = lineItems.where((l) => l.type == 'part').toList();
    final otherLines = lineItems.where((l) => l.type == 'other').toList();

    final subtotalCents =
        lineItems.fold<int>(0, (s, l) => s + (l.quantity * l.unitPrice).round());
    final taxCents = (subtotalCents * taxRate / 100).round();
    final totalCents = subtotalCents + taxCents;
    final subtotal = fromCents(subtotalCents);
    final tax = fromCents(taxCents);
    final total = fromCents(totalCents);

    final next = _nextStep(ro.status);
    final statusColor = _statusColor(ro.status);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_roNumber(ro.id)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _confirmDelete(context, ref),
          child: const Icon(
            CupertinoIcons.trash,
            size: 20,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // ── Status badge ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel(ro.status),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Service date (read-only — edit via Edit Record → estimate) ──
            Container(
              color: CupertinoColors.systemBackground,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.calendar,
                      size: 17, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 8),
                  const Text(
                    'Service Date',
                    style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.secondaryLabel),
                  ),
                  const Spacer(),
                  Text(
                    ro.serviceDate != null
                        ? _fmtDate(ro.serviceDate!)
                        : _fmtDate(ro.createdAt),
                    style: const TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.label,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Customer + Vehicle header ─────────────────────────────────
            _CustomerVehicleHeader(ro: ro),

            const SizedBox(height: 28),

            // ── Labor lines ───────────────────────────────────────────────
            if (laborLines.isNotEmpty) ...[
              _sectionHeader('LABOR'),
              _LineItemSection(
                  items: laborLines,
                  laborLines: const [],
                  canMark: ro.status != 'closed'),
              const SizedBox(height: 20),
            ],

            // ── Parts lines ───────────────────────────────────────────────
            if (partLines.isNotEmpty) ...[
              _sectionHeader('PARTS'),
              _LineItemSection(
                  items: partLines,
                  laborLines: laborLines,
                  canMark: ro.status != 'closed'),
              const SizedBox(height: 20),
            ],

            // ── Other lines ───────────────────────────────────────────────
            if (otherLines.isNotEmpty) ...[
              _sectionHeader('OTHER'),
              _LineItemSection(
                  items: otherLines,
                  laborLines: const [],
                  canMark: ro.status != 'closed'),
              const SizedBox(height: 20),
            ],

            // ── Empty state ───────────────────────────────────────────────
            if (lineItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items on this repair order.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),

            // ── Totals ────────────────────────────────────────────────────
            if (lineItems.isNotEmpty) ...[
              _sectionHeader('TOTALS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: _money(subtotal)),
                    if (taxRate > 0) ...[
                      Container(height: 0.5, color: const Color(0xFFE5E5EA)),
                      _TotalRow(
                          label:
                              'Tax (${taxRate % 1 == 0 ? taxRate.toInt() : taxRate.toStringAsFixed(1)}%)',
                          value: _money(tax)),
                    ],
                    Container(height: 0.5, color: const Color(0xFFE5E5EA)),
                    _TotalRow(
                        label: 'Total',
                        value: _money(total),
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── Declined items ────────────────────────────────────────────
            if (declinedItems.isNotEmpty) ...[
              _sectionHeader('DECLINED'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    for (int i = 0; i < declinedItems.length; i++) ...[
                      _DeclinedItemRow(item: declinedItems[i]),
                      if (i < declinedItems.length - 1)
                        Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 16),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── Invoice Comment ───────────────────────────────────────────
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'INVOICE COMMENT',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () => _editComment(context, ref),
                    child: Text(
                      ro.comment != null && ro.comment!.isNotEmpty
                          ? 'Edit'
                          : 'Add',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF007AFF)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: CupertinoColors.white,
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ro.comment != null && ro.comment!.isNotEmpty
                  ? Text(
                      ro.comment!,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF1C1C1E)),
                    )
                  : const Text(
                      'No comment — tap Add to add one.',
                      style: TextStyle(
                          fontSize: 15, color: Color(0xFF8E8E93)),
                    ),
            ),
            const SizedBox(height: 28),

            // ── Actions ───────────────────────────────────────────────────
            if (ro.status != 'closed') ...[
              _sectionHeader('ACTIONS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    // Edit Repair Order — opens the linked estimate to edit line items
                    if (ro.estimateId != null) ...[
                      GestureDetector(
                        onTap: () => context
                            .push('/repair-orders/estimates/${ro.estimateId}'),
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.pencil,
                                  size: 18, color: Color(0xFF007AFF)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Edit Repair Order',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF007AFF))),
                              ),
                              Icon(CupertinoIcons.chevron_right,
                                  size: 16, color: Color(0xFFC7C7CC)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 46)),
                    ],
                    // Assign Technician
                    GestureDetector(
                      onTap: () => _showTechPicker(context, ref),
                      child: Container(
                        color: CupertinoColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.person_crop_circle_badge_checkmark,
                                size: 18, color: Color(0xFF007AFF)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ro.technicianId != null
                                    ? 'Change Technician'
                                    : 'Assign Technician',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF007AFF)),
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_right,
                                size: 16, color: Color(0xFFC7C7CC)),
                          ],
                        ),
                      ),
                    ),
                    // Complete All — shown when there are undone line items
                    if ((lineItemsAsync.value ?? []).any((i) => !(i.isDone ?? false))) ...[
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 46)),
                      GestureDetector(
                        onTap: () => _confirmCompleteAll(context, ref),
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.checkmark_circle_fill,
                                  size: 18, color: Color(0xFF34C759)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Complete All Services',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF34C759))),
                              ),
                              Icon(CupertinoIcons.chevron_right,
                                  size: 16, color: Color(0xFFC7C7CC)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Status advancement button
                    if (next != null) ...[
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 46)),
                      GestureDetector(
                        onTap: () => _advanceStatus(context, ref, next.nextStatus),
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(_nextIcon(ro.status),
                                  size: 18,
                                  color: const Color(0xFF007AFF)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(next.buttonLabel,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF007AFF))),
                              ),
                              const Icon(CupertinoIcons.chevron_right,
                                  size: 16, color: Color(0xFFC7C7CC)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (ro.status == 'closed') ...[
              _sectionHeader('ACTIONS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    // View Invoice — opens the standalone invoice detail screen
                    GestureDetector(
                      onTap: () => context.push('/payments/${ro.id}'),
                      child: Container(
                        color: CupertinoColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.doc_text_fill,
                                size: 18, color: Color(0xFF34C759)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('View Invoice',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF))),
                            ),
                            Icon(CupertinoIcons.chevron_right,
                                size: 16, color: Color(0xFFC7C7CC)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 0.5,
                        color: const Color(0xFFE5E5EA),
                        margin: const EdgeInsets.only(left: 46)),
                    // Edit Record — opens the linked estimate to edit line items
                    if (ro.estimateId != null) ...[
                      GestureDetector(
                        onTap: () => context
                            .push('/repair-orders/estimates/${ro.estimateId}'),
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.pencil,
                                  size: 18, color: Color(0xFF007AFF)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Edit Record',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF007AFF))),
                              ),
                              Icon(CupertinoIcons.chevron_right,
                                  size: 16, color: Color(0xFFC7C7CC)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 46)),
                    ],
                    // Itemized Invoice
                    GestureDetector(
                      onTap: () => _generateInvoice(context, ref, simple: false),
                      onSecondaryTapUp: (d) => _generateInvoice(context, ref, simple: false, position: d.globalPosition),
                      child: Container(
                        color: CupertinoColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.doc_richtext,
                                size: 18, color: Color(0xFF007AFF)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Itemized Invoice',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF))),
                            ),
                            Icon(CupertinoIcons.chevron_right,
                                size: 16, color: Color(0xFFC7C7CC)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 0.5,
                        color: const Color(0xFFE5E5EA),
                        margin: const EdgeInsets.only(left: 46)),
                    // Simple Invoice
                    GestureDetector(
                      onTap: () => _generateInvoice(context, ref, simple: true),
                      onSecondaryTapUp: (d) => _generateInvoice(context, ref, simple: true, position: d.globalPosition),
                      child: Container(
                        color: CupertinoColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.doc_plaintext,
                                size: 18, color: Color(0xFF007AFF)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Simple Invoice',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF))),
                            ),
                            Icon(CupertinoIcons.chevron_right,
                                size: 16, color: Color(0xFFC7C7CC)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton(
                  onPressed: () => _confirmDelete(context, ref),
                  child: const Text(
                    'Delete Repair Order',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      );
}

// ─── Customer + Vehicle Header ────────────────────────────────────────────────
class _CustomerVehicleHeader extends ConsumerWidget {
  final RepairOrder ro;
  const _CustomerVehicleHeader({required this.ro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: Future.wait([
        db.getCustomer(ro.customerId),
        if (ro.vehicleId != null) db.getVehicle(ro.vehicleId!),
        if (ro.estimateId != null) db.getEstimate(ro.estimateId!),
      ]),
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final customer = results.isNotEmpty ? results[0] as Customer? : null;

        // vehicle is the second result only when vehicleId was not null
        Vehicle? vehicle;
        Estimate? estimate;
        if (ro.vehicleId != null && results.length >= 2) {
          vehicle = results[1] as Vehicle?;
          if (ro.estimateId != null && results.length >= 3) {
            estimate = results[2] as Estimate?;
          }
        } else if (ro.vehicleId == null && ro.estimateId != null &&
            results.length >= 2) {
          estimate = results[1] as Estimate?;
        }

        final vehicleLabel = vehicle != null
            ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
                .whereType<String>()
                .join(' ')
            : null;

        return Container(
          color: CupertinoColors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.person_fill,
                      size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 6),
                  Text(
                    customer?.name ?? 'Customer #${ro.customerId}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              if (vehicleLabel != null && vehicleLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.car_fill,
                        size: 15, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 6),
                    Text(vehicleLabel,
                        style: const TextStyle(
                            fontSize: 15, color: Color(0xFF8E8E93))),
                    if (vehicle?.licensePlate != null &&
                        vehicle!.licensePlate!.isNotEmpty &&
                        vehicle.licensePlate!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${vehicle.licensePlate}',
                        style: const TextStyle(
                            fontSize: 15, color: Color(0xFFAEAEB2)),
                      ),
                    ],
                  ],
                ),
              ],
              // Customer complaint from the linked estimate
              if (estimate?.customerComplaint != null &&
                  estimate!.customerComplaint!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(CupertinoIcons.chat_bubble_text_fill,
                        size: 14, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        estimate.customerComplaint!,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1C1C1E)),
                      ),
                    ),
                  ],
                ),
              ],
              if (ro.note != null && ro.note!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ro.note!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              // Assigned technician
              if (ro.technicianId != null) ...[
                const SizedBox(height: 8),
                _TechnicianLabel(technicianId: ro.technicianId!),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Technician Label ─────────────────────────────────────────────────────────
// Shown in the RO header when a technician is assigned.
class _TechnicianLabel extends ConsumerWidget {
  final int technicianId;
  const _TechnicianLabel({required this.technicianId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(dbProvider).getTechnician(technicianId),
      builder: (context, snap) {
        final tech = snap.data;
        if (tech == null) return const SizedBox.shrink();
        return Row(
          children: [
            const Icon(CupertinoIcons.wrench_fill,
                size: 13, color: Color(0xFF8E8E93)),
            const SizedBox(width: 5),
            Text(
              tech.name,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
            ),
            if (tech.specialty != null && tech.specialty!.isNotEmpty) ...[
              Text(
                ' · ${tech.specialty}',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFAEAEB2)),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Technician Picker Sheet ──────────────────────────────────────────────────
// A bottom sheet for assigning a technician to a repair order.
class _TechPickerSheet extends StatefulWidget {
  final List<Technician> techs;
  final int? currentTechId;
  final void Function(int techId) onSelect;
  final VoidCallback? onRemove;
  final VoidCallback onCreateNew;

  const _TechPickerSheet({
    required this.techs,
    required this.currentTechId,
    required this.onSelect,
    required this.onRemove,
    required this.onCreateNew,
  });

  @override
  State<_TechPickerSheet> createState() => _TechPickerSheetState();
}

class _TechPickerSheetState extends State<_TechPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<Technician> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.techs;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.techs
          : widget.techs
              .where((t) =>
                  t.name.toLowerCase().contains(q) ||
                  (t.specialty?.toLowerCase().contains(q) ?? false))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    'Assign Technician',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchCtrl,
                autofocus: true,
                placeholder: 'Search',
              ),
            ),
            Container(height: 0.5, color: const Color(0xFFE5E5EA)),
            // New technician row
            GestureDetector(
              onTap: widget.onCreateNew,
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.add_circled,
                        size: 22, color: Color(0xFF007AFF)),
                    SizedBox(width: 12),
                    Text('New Technician',
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF007AFF))),
                  ],
                ),
              ),
            ),
            if (_filtered.isNotEmpty)
              Container(height: 0.5, color: const Color(0xFFE5E5EA)),
            // Technician rows
            if (_filtered.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 60),
                  ),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => widget.onSelect(_filtered[i].id),
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5E5EA),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _filtered[i].name.isNotEmpty
                                    ? _filtered[i].name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3A3A3C),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _filtered[i].name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1C1C1E)),
                                ),
                                if (_filtered[i].specialty != null &&
                                    _filtered[i].specialty!.isNotEmpty)
                                  Text(
                                    _filtered[i].specialty!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF8E8E93)),
                                  ),
                              ],
                            ),
                          ),
                          if (_filtered[i].id == widget.currentTechId)
                            const Icon(CupertinoIcons.checkmark,
                                size: 16, color: Color(0xFF007AFF)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (_searchCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No technicians match "${_searchCtrl.text}"',
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF8E8E93)),
                  textAlign: TextAlign.center,
                ),
              ),
            // Remove technician (only when one is assigned)
            if (widget.onRemove != null) ...[
              Container(height: 0.5, color: const Color(0xFFE5E5EA)),
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: const Center(
                    child: Text(
                      'Remove Technician',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Declined Item Row ────────────────────────────────────────────────────────
// Shows a single declined line item in gray with strikethrough — not interactive.
class _DeclinedItemRow extends StatelessWidget {
  final EstimateLineItem item;
  const _DeclinedItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = (item.type == 'labor' || item.type == 'other') &&
            item.laborName != null
        ? item.laborName!
        : item.description;
    final price = _money(item.quantity * fromCents(item.unitPrice));

    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(CupertinoIcons.xmark_circle_fill,
              size: 16, color: Color(0xFFFF3B30)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8E8E93),
                decoration: TextDecoration.lineThrough,
                decorationColor: Color(0xFF8E8E93),
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              decoration: TextDecoration.lineThrough,
              decorationColor: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Line Item Section (read-only on RO) ─────────────────────────────────────
// Groups parts by their linked labor line when assignments exist.
// canMark: true when the RO is not closed — rows show a checkmark toggle.
class _LineItemSection extends ConsumerWidget {
  final List<EstimateLineItem> items;
  final List<EstimateLineItem> laborLines;
  final bool canMark;
  const _LineItemSection(
      {required this.items,
      required this.laborLines,
      required this.canMark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyAssigned =
        laborLines.isNotEmpty && items.any((p) => p.parentLaborId != null);

    if (!hasAnyAssigned) {
      return _buildGroup(context, ref, items);
    }

    final groups = <({String? label, List<EstimateLineItem> parts})>[];
    for (final labor in laborLines) {
      final linked = items.where((p) => p.parentLaborId == labor.id).toList();
      if (linked.isNotEmpty) {
        groups.add((label: labor.description, parts: linked));
      }
    }
    final unassigned = items.where((p) => p.parentLaborId == null).toList();
    if (unassigned.isNotEmpty) {
      groups.add((label: null, parts: unassigned));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int g = 0; g < groups.length; g++) ...[
          if (g > 0) const SizedBox(height: 12),
          if (groups[g].label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.arrow_turn_down_right,
                      size: 11, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 4),
                  Text(
                    groups[g].label!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          _buildGroup(context, ref, groups[g].parts,
              indented: groups[g].label != null),
        ],
      ],
    );
  }

  Widget _buildGroup(
      BuildContext context, WidgetRef ref, List<EstimateLineItem> groupItems,
      {bool indented = false}) {
    return Padding(
      padding: EdgeInsets.only(left: indented ? 20.0 : 0.0),
      child: Container(
        color: CupertinoColors.white,
        child: Column(
          children: [
            for (int i = 0; i < groupItems.length; i++) ...[
              _LineItemRow(
                  item: groupItems[i],
                  laborLines: laborLines,
                  canMark: canMark,
                  ref: ref),
              if (i < groupItems.length - 1)
                Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final EstimateLineItem item;
  final List<EstimateLineItem> laborLines;
  final bool canMark;
  final WidgetRef ref;
  const _LineItemRow({
    required this.item,
    required this.laborLines,
    required this.canMark,
    required this.ref,
  });

  Future<void> _toggleDone() async {
    final wasDone = item.isDone ?? false;
    final nowDone = !wasDone;
    final db = ref.read(dbProvider);

    // Wrap both writes in a transaction so a crash between them can't leave
    // the line item marked done but the stock not deducted (or vice versa).
    await db.transaction(() async {
      await db.updateLineItem(item.copyWith(isDone: Value(nowDone)));

      // Adjust inventory stock when a parts line item is checked/unchecked.
      // Only parts linked to the catalog (inventoryPartId != null) are tracked.
      // No floor clamp — negative stock is accurate (ordered more than on-hand).
      // check+uncheck must be a no-op; clamping at 0 would break that symmetry.
      if (item.type == 'part' && item.inventoryPartId != null) {
        final part = await db.getPart(item.inventoryPartId!);
        if (part != null) {
          final qty = item.quantity.round();
          final newStock = nowDone ? part.stockQty - qty : part.stockQty + qty;
          await db.updatePart(part.copyWith(stockQty: newStock));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = item.isDone ?? false;
    final lineTotal = item.quantity * fromCents(item.unitPrice);
    final qtyLabel = item.type == 'labor'
        ? '${_qty(item.quantity)} hr @ \$${fromCents(item.unitPrice).toStringAsFixed(2)}/hr'
        : item.type == 'other'
            ? '\$${fromCents(item.unitPrice).toStringAsFixed(2)}'
            : '${_qty(item.quantity)} × \$${fromCents(item.unitPrice).toStringAsFixed(2)}';

    final textColor =
        done ? const Color(0xFFAAAAAA) : const Color(0xFF1C1C1E);
    final subColor =
        done ? const Color(0xFFCCCCCC) : const Color(0xFF8E8E93);
    final decoration = done ? TextDecoration.lineThrough : null;

    return GestureDetector(
      onTap: canMark ? _toggleDone : null,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkmark circle — only shown when canMark
            if (canMark) ...[
              Icon(
                done
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                size: 22,
                color: done
                    ? const Color(0xFF34C759)
                    : const Color(0xFFC7C7CC),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.type == 'labor' || item.type == 'other') &&
                            item.laborName != null
                        ? item.laborName!
                        : item.description,
                    style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        decoration: decoration,
                        decorationColor: textColor),
                  ),
                  const SizedBox(height: 2),
                  if (item.type == 'part') ...[
                    if (item.vendorId != null)
                      FutureBuilder(
                        future:
                            ref.read(dbProvider).getVendor(item.vendorId!),
                        builder: (context, snap) {
                          final vendorName = snap.data?.name;
                          final label = vendorName != null
                              ? '$qtyLabel · $vendorName'
                              : qtyLabel;
                          return Text(label,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: subColor,
                                  decoration: decoration,
                                  decorationColor: subColor));
                        },
                      )
                    else
                      Text(qtyLabel,
                          style: TextStyle(
                              fontSize: 13,
                              color: subColor,
                              decoration: decoration,
                              decorationColor: subColor)),
                    if (item.unitCost != null)
                      Text(
                        'Cost \$${fromCents(item.unitCost!).toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: subColor,
                            decoration: decoration,
                            decorationColor: subColor),
                      ),
                  ] else ...[
                    if (item.laborName != null)
                      Text(item.description,
                          style: TextStyle(
                              fontSize: 13,
                              color: subColor,
                              decoration: decoration,
                              decorationColor: subColor)),
                    Text(qtyLabel,
                        style: TextStyle(
                            fontSize: 13,
                            color: subColor,
                            decoration: decoration,
                            decorationColor: subColor)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _money(lineTotal),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
                decoration: decoration,
                decorationColor: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Total Row ────────────────────────────────────────────────────────────────
class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 16 : 15,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF1C1C1E),
              )),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 16 : 15,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF1C1C1E),
              )),
        ],
      ),
    );
  }
}

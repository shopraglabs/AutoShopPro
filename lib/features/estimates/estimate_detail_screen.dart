import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../../widgets/context_menu.dart';
import 'estimates_provider.dart';
import '../invoices/invoice_service.dart';
import '../repair_orders/repair_orders_provider.dart';
import '../service_templates/service_templates_provider.dart';

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

String _estimateNumber(int id) => 'EST-${id.toString().padLeft(4, '0')}';

class EstimateDetailScreen extends ConsumerWidget {
  final int estimateId;
  const EstimateDetailScreen({super.key, required this.estimateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimateAsync = ref.watch(estimateProvider(estimateId));
    final lineItemsAsync = ref.watch(lineItemsProvider(estimateId));

    return estimateAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Estimate')),
        child: Center(child: Text('Error: $e')),
      ),
      data: (estimate) {
        if (estimate == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Estimate')),
            child: Center(child: Text('Estimate not found.')),
          );
        }
        return _EstimateDetailView(
          estimate: estimate,
          lineItemsAsync: lineItemsAsync,
        );
      },
    );
  }
}

class _EstimateDetailView extends ConsumerWidget {
  final Estimate estimate;
  final AsyncValue<List<EstimateLineItem>> lineItemsAsync;

  const _EstimateDetailView({
    required this.estimate,
    required this.lineItemsAsync,
  });

  // Opens the template picker. When a template is chosen, creates a labor
  // line item pre-filled with the template's description, hours, and rate.
  Future<void> _applyTemplate(BuildContext context, WidgetRef ref) async {
    final templates = ref.read(serviceTemplatesProvider).value ?? [];
    if (templates.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (d) => CupertinoAlertDialog(
          title: const Text('No Templates'),
          content: const Text(
              'Go to Settings → Service Templates to create some first.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(d),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final picked = await showCupertinoModalPopup<ServiceTemplate>(
      context: context,
      builder: (_) => _TemplatePickerSheet(templates: templates),
    );
    if (picked == null || !context.mounted) return;
    final db = ref.read(dbProvider);
    // defaultRate and defaultLaborRate are now int cents — copy directly to unitPrice
    final rate = picked.defaultRate ??
        (await db.getOrCreateSettings()).defaultLaborRate;
    // Insert the labor line and capture its new id so parts can link to it.
    final laborId = await db.insertLineItem(EstimateLineItemsCompanion.insert(
      estimateId: estimate.id,
      type: 'labor',
      laborName: Value(picked.name),
      description: picked.laborDescription,
      quantity: Value(picked.defaultHours),
      unitPrice: rate,  // int cents → int cents
      approvalStatus: const Value('approved'),
    ));

    // If the template has linked parts, show the parts picker sheet so the
    // user can choose which ones to add and set quantities.
    final linkedParts = await db.getTemplatePartsForTemplate(picked.id);
    if (linkedParts.isEmpty || !context.mounted) return;

    // Fetch the InventoryPart for each link to get description + sell price.
    final partOptions = <({InventoryPart part})>[];
    for (final link in linkedParts) {
      final part = await db.getPart(link.inventoryPartId);
      if (part != null) partOptions.add((part: part));
    }
    if (partOptions.isEmpty || !context.mounted) return;

    final selected = await showCupertinoModalPopup<List<({int partId, double qty})>>(
      context: context,
      builder: (_) => _TemplatePartsSheet(
        templateName: picked.name,
        parts: partOptions.map((o) => o.part).toList(),
      ),
    );

    if (selected == null || !context.mounted) return;
    for (final s in selected) {
      final part = partOptions.firstWhere((o) => o.part.id == s.partId).part;
      await db.insertLineItem(EstimateLineItemsCompanion.insert(
        estimateId: estimate.id,
        type: 'part',
        description: part.description,
        quantity: Value(s.qty),
        unitPrice: part.sellPrice,    // int cents → int cents
        unitCost: Value(part.cost),   // int cents → int cents
        inventoryPartId: Value(part.id),
        parentLaborId: Value(laborId),
        approvalStatus: const Value('approved'),
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Delete estimate?'),
        content: const Text('All line items on this estimate will also be deleted. This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).deleteEstimate(estimate.id);
              if (context.mounted) context.go('/repair-orders/estimates');
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

  Future<void> _editComplaint(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
        text: estimate.customerComplaint ?? '');
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Customer Concern'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Enter customer concern…',
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
              await ref.read(dbProvider).updateEstimate(
                    estimate.copyWith(
                        customerComplaint: Value(text.isEmpty ? null : text)),
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

  void _pickEstimateDate(BuildContext context, WidgetRef ref) {
    final raw = estimate.estimateDate ?? estimate.createdAt;
    // Guard against corrupted imported dates (e.g. year 58023) which crash
    // CupertinoDatePicker when initialDateTime > maximumDate.
    final initial = (raw.year >= 1900 && raw.year <= 2100) ? raw : DateTime.now();
    DateTime picked = initial;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () async {
                    await ref.read(dbProvider).updateEstimate(
                          estimate.copyWith(estimateDate: Value(picked)),
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Opens a date picker that saves to the linked RO's serviceDate.
  void _pickServiceDate(BuildContext context, WidgetRef ref, RepairOrder ro) {
    final raw = ro.serviceDate ?? ro.createdAt;
    final initial = (raw.year >= 1900 && raw.year <= 2100) ? raw : DateTime.now();
    DateTime picked = initial;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
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
                  child: const Text('Done'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                maximumDate: DateTime.now().add(const Duration(days: 365 * 2)),
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printEstimate(BuildContext context, WidgetRef ref, {Offset? position}) async {
    final db = ref.read(dbProvider);
    final results = await Future.wait([
      db.getCustomer(estimate.customerId),
      if (estimate.vehicleId != null) db.getVehicle(estimate.vehicleId!),
      db.getOrCreateSettings(),
    ]);
    int idx = 0;
    final customer = results[idx++] as Customer?;
    if (customer == null) return;
    Vehicle? vehicle;
    if (estimate.vehicleId != null) vehicle = results[idx++] as Vehicle?;
    final settings = results[idx] as ShopSetting;
    if (!context.mounted) return;
    await showEstimateActions(
      context: context,
      estimate: estimate,
      customer: customer,
      vehicle: vehicle,
      lineItems: lineItemsAsync.value ?? [],
      shopName: settings.shopName,
      position: position,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch here so the stream is active before the user taps Apply Template.
    // Without this, ref.read() in _applyTemplate finds no data on first tap.
    ref.watch(serviceTemplatesProvider);

    final lineItems = lineItemsAsync.value ?? [];
    final laborLines =
        lineItems.where((l) => l.type == 'labor').toList();
    final partLines =
        lineItems.where((l) => l.type == 'part').toList();
    final otherLines =
        lineItems.where((l) => l.type == 'other').toList();

    // Declined items are excluded from the payable total
    final declinedItems =
        lineItems.where((l) => l.approvalStatus == 'declined').toList();
    final activeItems =
        lineItems.where((l) => l.approvalStatus != 'declined').toList();
    // unitPrice is int cents — convert to dollars before multiplying by quantity
    final subtotal = activeItems.fold(
        0.0, (s, l) => s + l.quantity * fromCents(l.unitPrice));
    final declinedTotal = declinedItems.fold(
        0.0, (s, l) => s + l.quantity * fromCents(l.unitPrice));
    final tax = subtotal * (estimate.taxRate / 100);
    final total = subtotal + tax;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_estimateNumber(estimate.id)),
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

            // ── Customer + Vehicle header ──────────────────────────────────
            _CustomerVehicleHeader(estimate: estimate),

            const SizedBox(height: 16),

            // ── Estimate date ──────────────────────────────────────────────
            GestureDetector(
              onTap: () => _pickEstimateDate(context, ref),
              child: Container(
                color: CupertinoColors.systemBackground,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        size: 17, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 8),
                    const Text(
                      'Estimate Date',
                      style: TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.secondaryLabel),
                    ),
                    const Spacer(),
                    Text(
                      () {
                        final d = estimate.estimateDate ?? estimate.createdAt;
                        if (d.year < 1900 || d.year > 2100) return '—';
                        return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
                      }(),
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 14, color: Color(0xFFC7C7CC)),
                  ],
                ),
              ),
            ),

            // ── Service date (shown + editable when a linked RO exists) ───
            Builder(builder: (context) {
              final roAsync = ref.watch(roForEstimateProvider(estimate.id));
              return roAsync.when(
                data: (ro) {
                  if (ro == null) return const SizedBox.shrink();
                  final d = ro.serviceDate ?? ro.createdAt;
                  final label = (d.year >= 1900 && d.year <= 2100)
                      ? '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}'
                      : '—';
                  return Column(
                    children: [
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 42)),
                      GestureDetector(
                        onTap: () => _pickServiceDate(context, ref, ro),
                        child: Container(
                          color: CupertinoColors.systemBackground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.calendar_badge_plus,
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
                                label,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF007AFF),
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              const Icon(CupertinoIcons.chevron_right,
                                  size: 14, color: Color(0xFFC7C7CC)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),

            const SizedBox(height: 8),

            // ── Convert to RO / View RO banner ────────────────────────────
            _RoBanner(estimate: estimate),

            // ── Customer concern ──────────────────────────────────────────
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'CUSTOMER CONCERN',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _editComplaint(context, ref),
                      child: Text(
                        estimate.customerComplaint == null ||
                                estimate.customerComplaint!.trim().isEmpty
                            ? 'Add'
                            : 'Edit',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.all(16),
              child: estimate.customerComplaint == null ||
                      estimate.customerComplaint!.trim().isEmpty
                  ? const Text(
                      'No customer concern entered.',
                      style: TextStyle(fontSize: 15, color: Color(0xFFAEAEB2)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in estimate.customerComplaint!
                            .split('\n')
                            .where((s) => s.trim().isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF1C1C1E))),
                                Expanded(
                                  child: Text(
                                    line.trim(),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF1C1C1E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // ── Labor lines ───────────────────────────────────────────────
            if (laborLines.isNotEmpty) ...[
              _sectionHeader('LABOR'),
              for (final labor in laborLines) ...[
                Container(
                  color: CupertinoColors.white,
                  child: _LineItemRow(
                    item: labor,
                    laborLines: const [],
                    onDelete: (id) => ref.read(dbProvider).deleteLineItem(id),
                  ),
                ),
                // Indented "Add Part" row — pre-links the new part to this labor line
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: _ActionRow(
                    icon: CupertinoIcons.cube_box_fill,
                    label: 'Add Part',
                    onTap: () => context.push(
                      '/repair-orders/estimates/${estimate.id}/line-items/part?parentLaborId=${labor.id}',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 14),
            ],

            // ── Parts lines ───────────────────────────────────────────────
            if (partLines.isNotEmpty) ...[
              _sectionHeader('PARTS'),
              _LineItemSection(
                items: partLines,
                laborLines: laborLines,
                onDelete: (id) => ref.read(dbProvider).deleteLineItem(id),
              ),
              const SizedBox(height: 20),
            ],

            // ── Other lines ───────────────────────────────────────────────
            if (otherLines.isNotEmpty) ...[
              _sectionHeader('OTHER'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    for (int i = 0; i < otherLines.length; i++) ...[
                      _LineItemRow(
                        item: otherLines[i],
                        laborLines: const [],
                        onDelete: (id) =>
                            ref.read(dbProvider).deleteLineItem(id),
                      ),
                      if (i < otherLines.length - 1)
                        Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 16),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Empty state ───────────────────────────────────────────────
            if (lineItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items yet.\nAdd labor, parts, or other items below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),

            // ── Add items ─────────────────────────────────────────────────
            _sectionHeader('ADD ITEMS'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _ActionRow(
                    icon: CupertinoIcons.wrench_fill,
                    label: 'Add Labor',
                    onTap: () => context.push(
                        '/repair-orders/estimates/${estimate.id}/line-items/labor'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 46),
                  ),
                  _ActionRow(
                    icon: CupertinoIcons.cube_box_fill,
                    label: 'Add Part',
                    onTap: () => context.push(
                        '/repair-orders/estimates/${estimate.id}/line-items/part'),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 46),
                  ),
                  _ActionRow(
                    icon: CupertinoIcons.ellipsis_circle_fill,
                    label: 'Add Other',
                    onTap: () => context.push(
                        '/repair-orders/estimates/${estimate.id}/line-items/other'),
                  ),
                ],
              ),
            ),

            // ── Totals ────────────────────────────────────────────────────
            if (lineItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionHeader('TOTALS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: _money(subtotal)),
                    if (estimate.taxRate > 0)
                      _TotalRow(
                        label:
                            'Tax (${estimate.taxRate.toStringAsFixed(1)}%)',
                        value: _money(tax),
                      ),
                    // Declined items footnote — shown in red when any items declined
                    if (declinedItems.isNotEmpty)
                      _TotalRow(
                        label:
                            '${declinedItems.length} item${declinedItems.length == 1 ? '' : 's'} declined',
                        value: '−${_money(declinedTotal)}',
                        color: CupertinoColors.destructiveRed,
                      ),
                    Container(
                        height: 0.5, color: const Color(0xFFE5E5EA)),
                    _TotalRow(
                      label: 'Total',
                      value: _money(total),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],

            // ── Actions ───────────────────────────────────────────────────
            const SizedBox(height: 20),
            _sectionHeader('ACTIONS'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _ActionRow(
                    icon: CupertinoIcons.doc_text_fill,
                    label: 'Save / Print / Email',
                    onTap: () => _printEstimate(context, ref),
                    onSecondaryTapUp: (pos) => _printEstimate(context, ref, position: pos),
                  ),
                  _ConvertRow(estimate: estimate),
                ],
              ),
            ),

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
  final Estimate estimate;
  const _CustomerVehicleHeader({required this.estimate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: Future.wait([
        db.getCustomer(estimate.customerId),
        if (estimate.vehicleId != null) db.getVehicle(estimate.vehicleId!),
      ]),
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final customer = results.isNotEmpty ? results[0] as Customer? : null;
        final vehicle = results.length > 1 ? results[1] as Vehicle? : null;

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
                  const Icon(
                    CupertinoIcons.person_fill,
                    size: 16,
                    color: Color(0xFF8E8E93),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    customer?.name ?? 'Customer #${estimate.customerId}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              if (vehicleLabel != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.car_fill,
                      size: 15,
                      color: Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehicleLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    if (vehicle?.licensePlate != null &&
                        vehicle!.licensePlate!.isNotEmpty) ...[
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
              // Internal note — shown subtly below complaint
              if (estimate.note != null && estimate.note!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  estimate.note!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Line Item Section ────────────────────────────────────────────────────────
// Shows a group of line items (all labor, or all parts) with swipe-to-delete.
// When laborLines is non-empty and parts have parentLaborId set, parts are
// grouped by their linked labor line with small sub-headers between groups.
class _LineItemSection extends StatelessWidget {
  final List<EstimateLineItem> items;
  final List<EstimateLineItem> laborLines;
  final Future<int> Function(int id) onDelete;

  const _LineItemSection({
    required this.items,
    required this.laborLines,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Only group when this is the parts section AND at least one part is linked
    final hasAnyAssigned =
        laborLines.isNotEmpty && items.any((p) => p.parentLaborId != null);

    if (!hasAnyAssigned) {
      // Flat list — used for the labor section and unlinked parts sections
      return _buildGroup(items);
    }

    // Build groups: labor-linked first (in labor order), then unassigned
    final groups = <({String? label, List<EstimateLineItem> parts})>[];
    for (final labor in laborLines) {
      final linked = items.where((p) => p.parentLaborId == labor.id).toList();
      if (linked.isNotEmpty) {
        groups.add((label: labor.description, parts: linked));
      }
    }
    final unassigned =
        items.where((p) => p.parentLaborId == null).toList();
    if (unassigned.isNotEmpty) {
      // null label = no sub-header (unassigned parts shown at the bottom)
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
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          _buildGroup(groups[g].parts,
              indented: groups[g].label != null),
        ],
      ],
    );
  }

  // Renders a flat white card of rows with dividers between them.
  // [indented] adds left padding to show these parts belong to a labor line.
  Widget _buildGroup(List<EstimateLineItem> groupItems, {bool indented = false}) {
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
                onDelete: onDelete),
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

class _LineItemRow extends ConsumerWidget {
  final EstimateLineItem item;
  final List<EstimateLineItem> laborLines;
  final Future<int> Function(int id) onDelete;

  const _LineItemRow({
    required this.item,
    required this.laborLines,
    required this.onDelete,
  });

  // Opens the approval picker for this line item.
  // On desktop: shows an inline context menu at the tap position.
  // On mobile: shows a bottom action sheet.
  void _showApprovalSheet(BuildContext context, WidgetRef ref, [Offset? position]) {
    final current = item.approvalStatus;
    final db = ref.read(dbProvider);

    if ((Platform.isMacOS || Platform.isWindows) && position != null) {
      showContextMenu(
        context: context,
        position: position,
        items: [
          if (current != 'approved')
            ContextMenuAction(
              label: 'Approve',
              icon: CupertinoIcons.checkmark_circle,
              onTap: () => db.updateLineItem(
                  item.copyWith(approvalStatus: const Value('approved'))),
            ),
          if (current != 'declined')
            ContextMenuAction(
              label: 'Decline',
              icon: CupertinoIcons.xmark_circle,
              isDestructive: true,
              onTap: () => db.updateLineItem(
                  item.copyWith(approvalStatus: const Value('declined'))),
            ),
          if (current != null)
            ContextMenuAction(
              label: 'Reset to Pending',
              icon: CupertinoIcons.arrow_counterclockwise,
              onTap: () => db.updateLineItem(
                  item.copyWith(approvalStatus: const Value(null))),
            ),
        ],
      );
    } else {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (sheetCtx) => CupertinoActionSheet(
          title: Text(item.description),
          message: const Text('Set customer approval status for this item'),
          actions: [
            if (current != 'approved')
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(sheetCtx);
                  await db.updateLineItem(
                      item.copyWith(approvalStatus: const Value('approved')));
                },
                child: const Text('Approve'),
              ),
            if (current != 'declined')
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.pop(sheetCtx);
                  await db.updateLineItem(
                      item.copyWith(approvalStatus: const Value('declined')));
                },
                child: const Text('Decline'),
              ),
            if (current != null)
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(sheetCtx);
                  await db.updateLineItem(
                      item.copyWith(approvalStatus: const Value(null)));
                },
                child: const Text('Reset to Pending'),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(sheetCtx),
            child: const Text('Cancel'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // unitPrice is int cents — convert to dollars for display and calculation
    final unitPriceDollars = fromCents(item.unitPrice);
    final lineTotal = item.quantity * unitPriceDollars;
    final qtyLabel = item.type == 'labor'
        ? '${_qty(item.quantity)} hr @ \$${unitPriceDollars.toStringAsFixed(2)}/hr'
        : item.type == 'other'
            ? '\$${unitPriceDollars.toStringAsFixed(2)}'
            : '${_qty(item.quantity)} × \$${unitPriceDollars.toStringAsFixed(2)}';

    final isDeclined = item.approvalStatus == 'declined';
    final isApproved = item.approvalStatus == 'approved';

    // Approval badge: gray circle = pending, green check = approved, red X = declined
    final approvalIcon = isApproved
        ? CupertinoIcons.checkmark_circle_fill
        : isDeclined
            ? CupertinoIcons.xmark_circle_fill
            : CupertinoIcons.circle;
    final approvalColor = isApproved
        ? const Color(0xFF34C759)
        : isDeclined
            ? CupertinoColors.destructiveRed
            : const Color(0xFFC7C7CC);

    // Declined items are visually muted with strikethrough
    final textColor =
        isDeclined ? const Color(0xFFAEAEB2) : const Color(0xFF1C1C1E);
    final subColor =
        isDeclined ? const Color(0xFFD1D1D6) : const Color(0xFF8E8E93);
    final decoration =
        isDeclined ? TextDecoration.lineThrough : TextDecoration.none;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.trash, color: CupertinoColors.white),
      ),
      onDismissed: (_) => onDelete(item.id),
      child: GestureDetector(
        onTap: () => context.push(
            '/repair-orders/estimates/${item.estimateId}/line-items/${item.id}/edit'),
        onSecondaryTapUp: (details) => showContextMenu(
          context: context,
          position: details.globalPosition,
          items: [
            ContextMenuAction(
              label: 'Edit',
              icon: CupertinoIcons.pencil,
              onTap: () => context.push(
                  '/repair-orders/estimates/${item.estimateId}/line-items/${item.id}/edit'),
            ),
            contextMenuDivider,
            ContextMenuAction(
              label: 'Delete',
              icon: CupertinoIcons.trash,
              isDestructive: true,
              onTap: () => onDelete(item.id),
            ),
          ],
        ),
        child: Container(
          color: CupertinoColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Approval badge ──────────────────────────────────────────
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showApprovalSheet(context, ref),
                onSecondaryTapUp: (d) => _showApprovalSheet(context, ref, d.globalPosition),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 1),
                  child: Icon(approvalIcon, size: 20, color: approvalColor),
                ),
              ),
              // ── Description + details ───────────────────────────────────
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
                        decorationColor: textColor,
                      ),
                    ),
                    if (item.type == 'part' &&
                        item.partNumber != null &&
                        item.partNumber!.isNotEmpty)
                      Text(
                        item.partNumber!,
                        style: TextStyle(fontSize: 12, color: subColor),
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
                                    fontSize: 13, color: subColor));
                          },
                        )
                      else
                        Text(qtyLabel,
                            style: TextStyle(fontSize: 13, color: subColor)),
                      if (item.unitCost != null)
                        Text(
                          // unitCost is int cents — convert to dollars for display
                          'Cost \$${fromCents(item.unitCost!).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDeclined
                                  ? const Color(0xFFD1D1D6)
                                  : const Color(0xFFAAAAAA)),
                        ),
                    ] else ...[
                      if (item.laborName != null)
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 13, color: subColor),
                        ),
                      Text(
                        qtyLabel,
                        style: TextStyle(fontSize: 13, color: subColor),
                      ),
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
              const SizedBox(width: 6),
              const Icon(CupertinoIcons.chevron_right,
                  size: 16, color: Color(0xFFC7C7CC)),
            ],
          ),
        ),
      ),
    );
  }

  // Strips trailing ".0" for whole numbers: 1.0 → "1", 2.5 → "2.5"
  String _qty(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);
}

// ─── RO Banner ────────────────────────────────────────────────────────────────
// Shows a "View Repair Order" row when an RO exists for this estimate.
// When no RO exists, shows nothing (Convert button lives in the ACTIONS section).
class _RoBanner extends ConsumerWidget {
  final Estimate estimate;
  const _RoBanner({required this.estimate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roAsync = ref.watch(roForEstimateProvider(estimate.id));

    return roAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (ro) {
        if (ro == null) return const SizedBox.shrink();

        // RO exists — show a "View RO" row in the same style
        final roNumber = 'RO-${ro.id.toString().padLeft(4, '0')}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeaderStatic('REPAIR ORDER'),
            GestureDetector(
              onTap: () => context.push('/repair-orders/ros/${ro.id}'),
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.doc_text_fill,
                        size: 18, color: const Color(0xFF34C759)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'View Repair Order',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF34C759)),
                          ),
                          Text(
                            roNumber,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 16, color: Color(0xFFC7C7CC)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Convert Row ──────────────────────────────────────────────────────────────
// Shows "Convert to Repair Order" only when no RO exists for this estimate.
// Placed inside the ACTIONS section at the bottom of the estimate detail page.
class _ConvertRow extends ConsumerWidget {
  final Estimate estimate;
  const _ConvertRow({required this.estimate});

  Future<void> _convert(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    await db.updateEstimate(estimate.copyWith(status: 'approved'));
    final roId = await db.insertRepairOrder(RepairOrdersCompanion(
      estimateId: Value(estimate.id),
      customerId: Value(estimate.customerId),
      vehicleId: Value(estimate.vehicleId),
      note: Value(estimate.note),
      serviceDate: Value(estimate.createdAt),
    ));
    if (context.mounted) context.push('/repair-orders/ros/$roId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roAsync = ref.watch(roForEstimateProvider(estimate.id));
    return roAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (ro) {
        if (ro != null) return const SizedBox.shrink();
        return Column(
          children: [
            Container(height: 0.5, color: const Color(0xFFE5E5EA)),
            Container(
              color: CupertinoColors.white,
              child: _ActionRow(
                icon: CupertinoIcons.arrow_right_square_fill,
                label: 'Convert to Repair Order',
                onTap: () => _convert(context, ref),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Action Row ───────────────────────────────────────────────────────────────
// Standard action button style: blue icon + blue label + gray chevron.
// Matches the "New Estimate" row on the vehicle detail screen.
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final ValueChanged<Offset>? onTapUp;
  final ValueChanged<Offset>? onSecondaryTapUp;

  const _ActionRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.onTapUp,
    this.onSecondaryTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapUp == null ? onTap : null,
      onTapUp: onTapUp != null ? (d) => onTapUp!(d.globalPosition) : null,
      onSecondaryTapUp: onSecondaryTapUp != null ? (d) => onSecondaryTapUp!(d.globalPosition) : null,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF007AFF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
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
    );
  }
}

// A static (non-instance) version of _sectionHeader for use inside
// ConsumerWidgets that don't have access to the _EstimateDetailView instance.
Widget _sectionHeaderStatic(String label) => Padding(
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

// ─── Total Row ────────────────────────────────────────────────────────────────
class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  // Optional override color — used for the declined footnote row
  final Color? color;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? const Color(0xFF1C1C1E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 15,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 15,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Template Picker Sheet ────────────────────────────────────────────────────
// Shows a searchable list of service templates. Tapping one returns the
// template so the caller can apply it to the estimate.
class _TemplatePickerSheet extends StatefulWidget {
  final List<ServiceTemplate> templates;
  const _TemplatePickerSheet({required this.templates});

  @override
  State<_TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<_TemplatePickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<ServiceTemplate> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.templates;
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
          ? widget.templates
          : widget.templates
              .where((t) =>
                  t.name.toLowerCase().contains(q) ||
                  t.laborDescription.toLowerCase().contains(q))
              .toList();
    });
  }

  String _fmtHours(double h) =>
      h % 1 == 0 ? h.toInt().toString() : h.toStringAsFixed(1);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Apply Template',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E))),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: CupertinoSearchTextField(
              controller: _searchCtrl,
              autofocus: true,
              placeholder: 'Search templates',
            ),
          ),
          Container(height: 0.5, color: const Color(0xFFE5E5EA)),
          if (_filtered.isNotEmpty)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16),
                ),
                itemBuilder: (context, i) {
                  final t = _filtered[i];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, t),
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF1C1C1E))),
                          Text(
                            '${_fmtHours(t.defaultHours)} hr · ${t.laborDescription}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _searchCtrl.text.isNotEmpty
                    ? 'No templates match "${_searchCtrl.text}"'
                    : 'No templates saved yet.',
                style: const TextStyle(
                    fontSize: 15, color: Color(0xFF8E8E93)),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Template Parts Sheet ─────────────────────────────────────────────────────
// Shown after applying a service template. Lets the user pick which linked
// parts to add and set the quantity for each before they land on the estimate.
class _TemplatePartsSheet extends StatefulWidget {
  final String templateName;
  final List<InventoryPart> parts;

  const _TemplatePartsSheet({
    required this.templateName,
    required this.parts,
  });

  @override
  State<_TemplatePartsSheet> createState() => _TemplatePartsSheetState();
}

class _TemplatePartsSheetState extends State<_TemplatePartsSheet> {
  late final List<bool> _included;
  late final List<TextEditingController> _qtyCtrls;

  @override
  void initState() {
    super.initState();
    _included = List.filled(widget.parts.length, false);
    _qtyCtrls = List.generate(
      widget.parts.length,
      (_) => TextEditingController(text: '1'),
    );
  }

  @override
  void dispose() {
    for (final c in _qtyCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _confirm() {
    final result = <({int partId, double qty})>[];
    for (int i = 0; i < widget.parts.length; i++) {
      if (!_included[i]) continue;
      final qty = double.tryParse(_qtyCtrls[i].text) ?? 1.0;
      result.add((partId: widget.parts[i].id, qty: qty));
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _included.where((v) => v).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC7C7CC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Parts',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        widget.templateName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(
                      context, <({int partId, double qty})>[]),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF8E8E93)),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Select the parts to add and set quantities.',
              style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: widget.parts.length,
              separatorBuilder: (_, __) => Container(
                height: 0.5,
                color: const Color(0xFFE5E5EA),
                margin: const EdgeInsets.only(left: 16),
              ),
              itemBuilder: (_, i) {
                final part = widget.parts[i];
                return Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _included[i] = !_included[i]),
                        child: Icon(
                          _included[i]
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.circle,
                          size: 24,
                          color: _included[i]
                              ? const Color(0xFF007AFF)
                              : const Color(0xFFC7C7CC),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: _included[i]
                                    ? const Color(0xFF1C1C1E)
                                    : const Color(0xFFAEAEB2),
                              ),
                            ),
                            if (part.category != null &&
                                part.category != 'Part')
                              Text(
                                part.category!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_included[i])
                        SizedBox(
                          width: 56,
                          child: CupertinoTextField(
                            controller: _qtyCtrls[i],
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            textAlign: TextAlign.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 7),
                            onTap: () => _qtyCtrls[i].selection =
                                TextSelection(
                              baseOffset: 0,
                              extentOffset: _qtyCtrls[i].text.length,
                            ),
                            contextMenuBuilder:
                                (context, editableTextState) =>
                                    CupertinoAdaptiveTextSelectionToolbar
                                        .editableText(
                              editableTextState: editableTextState,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(height: 0.5, color: const Color(0xFFE5E5EA)),
          SafeArea(
            child: GestureDetector(
              onTap: selectedCount > 0 ? _confirm : null,
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      size: 18,
                      color: selectedCount > 0
                          ? const Color(0xFF007AFF)
                          : const Color(0xFFC7C7CC),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedCount > 0
                            ? 'Add $selectedCount Part${selectedCount == 1 ? '' : 's'}'
                            : 'No Parts Selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedCount > 0
                              ? const Color(0xFF007AFF)
                              : const Color(0xFFC7C7CC),
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: selectedCount > 0
                          ? const Color(0xFFC7C7CC)
                          : const Color(0xFFE5E5EA),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

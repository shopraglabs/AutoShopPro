import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import 'estimates_provider.dart';
import '../vendors/vendors_provider.dart' show vendorsProvider;
import '../inventory/inventory_provider.dart';
import '../service_templates/service_templates_provider.dart';
import '../settings/markup_rules_provider.dart';

// The form for adding a labor or parts line to an estimate.
// type: 'labor' | 'part'
class LineItemFormScreen extends ConsumerStatefulWidget {
  final int estimateId;
  final String type; // 'labor' or 'part'
  final EstimateLineItem? lineItem; // non-null = editing existing
  final int? parentLaborId; // pre-links this part to a labor line

  const LineItemFormScreen({
    super.key,
    required this.estimateId,
    required this.type,
    this.lineItem,
    this.parentLaborId,
  });

  @override
  ConsumerState<LineItemFormScreen> createState() =>
      _LineItemFormScreenState();
}

class _LineItemFormScreenState extends ConsumerState<LineItemFormScreen> {
  // Shared fields (labor + parts)
  late final TextEditingController _description;
  late final TextEditingController _quantity;

  // Labor-only fields
  late final TextEditingController _laborName;
  late final TextEditingController _laborRate;
  late final TextEditingController _laborTotal;

  // Parts-only fields
  late final TextEditingController _partNumber;
  late final TextEditingController _unitCost;
  late final TextEditingController _markupPercent;
  late final TextEditingController _markupDollar;
  late final TextEditingController _unitList;

  bool _saving = false;
  int? _vendorId;
  String? _vendorName;
  int? _parentLaborId;
  String? _parentLaborDesc;
  int? _catalogPartId;
  String? _catalogPartName;
  String? _catalogTemplateName;

  // Linked parts loaded from the selected service template.
  // Each entry has the inventory part and a qty controller (default 1).
  List<({InventoryPart part, TextEditingController qtyController})>
      _linkedTemplateParts = [];
  // Whether the linked parts dropdown is expanded
  bool _showLinkedParts = false;

  // Guard flag: prevents markup sync from triggering infinite listener loops
  bool _syncingMarkup = false;
  // Guard flag: prevents labor total sync from triggering infinite loops
  bool _syncingLabor = false;

  bool get _isLabor => widget.type == 'labor';
  bool get _isOther => widget.type == 'other';
  bool get _isEditing => widget.lineItem != null;

  // Formats a double cleanly: 2.0 → "2", 2.5 → "2.5"
  String _qtyStr(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);

  @override
  void initState() {
    super.initState();
    final li = widget.lineItem;

    _description = TextEditingController(text: li?.description ?? '');
    _quantity = TextEditingController(
        text: li != null ? _qtyStr(li.quantity) : '1');
    _laborName = TextEditingController(
        text: li?.laborName ?? '');
    _laborRate = TextEditingController();
    _laborTotal = TextEditingController();
    _partNumber = TextEditingController(text: li?.partNumber ?? '');
    _unitCost = TextEditingController();
    _markupPercent = TextEditingController();
    _markupDollar = TextEditingController();
    _unitList = TextEditingController();

    if (_isLabor) {
      _quantity.addListener(_onLaborHoursOrRateChanged);
      _laborRate.addListener(_onLaborHoursOrRateChanged);
      _laborTotal.addListener(_onLaborTotalChanged);
      if (li != null) {
        // unitPrice is stored as int cents — convert to dollars for display
        final rateDollars = fromCents(li.unitPrice);
        _laborRate.text = rateDollars.toStringAsFixed(2);
        // Pre-fill total from existing hours × rate (both in dollars)
        final tot = li.quantity * rateDollars;
        _laborTotal.text = tot % 1 == 0
            ? tot.toInt().toString()
            : tot.toStringAsFixed(2);
      } else {
        _loadDefaultLaborRate();
      }
    } else if (_isOther) {
      // Other: just pre-fill name/desc/cost/list if editing
      if (li != null) {
        // unitPrice/unitCost are int cents — convert to dollars for display
        _unitList.text = fromCents(li.unitPrice).toStringAsFixed(2);
        if (li.unitCost != null) {
          _unitCost.text = fromCents(li.unitCost!).toStringAsFixed(2);
        }
      }
    } else {
      // Parts: wire up the auto-sync listeners
      _unitCost.addListener(_onCostChanged);
      _markupPercent.addListener(_onMarkupPercentChanged);
      _markupDollar.addListener(_onMarkupDollarChanged);
      _unitList.addListener(_onListChanged);

      if (li != null) {
        // unitPrice/unitCost are int cents — convert to dollars for display
        final listDollars = fromCents(li.unitPrice);
        _unitList.text = listDollars.toStringAsFixed(2);
        if (li.unitCost != null) {
          final costDollars = fromCents(li.unitCost!);
          _unitCost.text = costDollars.toStringAsFixed(2);
          // Derive markup % and $ from stored cost and list price (dollar values)
          if (costDollars > 0) {
            final pct = (listDollars - costDollars) / costDollars * 100;
            final dollar = listDollars - costDollars;
            _markupPercent.text = pct.toStringAsFixed(1);
            _markupDollar.text = dollar.toStringAsFixed(2);
          }
        }
        _vendorId = li.vendorId;
        _parentLaborId = li.parentLaborId;
        if (li.vendorId != null) _loadVendorName(li.vendorId!);
        if (li.parentLaborId != null) _loadLaborDesc(li.parentLaborId!);
      } else {
        _loadDefaultMarkup();
        // Pre-link to a labor line when opened from "Add Part" under a labor row
        if (widget.parentLaborId != null) {
          _parentLaborId = widget.parentLaborId;
          _loadLaborDesc(widget.parentLaborId!);
        }
      }
    }
  }

  Future<void> _loadDefaultLaborRate() async {
    final settings = await ref.read(dbProvider).getOrCreateSettings();
    if (mounted && _laborRate.text.isEmpty) {
      // defaultLaborRate is stored as int cents — convert to dollars for display
      _laborRate.text = fromCents(settings.defaultLaborRate).toStringAsFixed(2);
    }
  }

  Future<void> _loadDefaultMarkup() async {
    final settings = await ref.read(dbProvider).getOrCreateSettings();
    if (mounted && _markupPercent.text.isEmpty) {
      _markupPercent.text =
          settings.defaultPartsMarkup.toStringAsFixed(1);
    }
  }

  Future<void> _loadVendorName(int vendorId) async {
    final vendor = await ref.read(dbProvider).getVendor(vendorId);
    if (mounted && vendor != null) {
      setState(() => _vendorName = vendor.name);
    }
  }

  Future<void> _loadLaborDesc(int laborId) async {
    final item = await ref.read(dbProvider).getLineItem(laborId);
    if (mounted && item != null) {
      setState(() => _parentLaborDesc = item.description);
    }
  }

  // ── Labor total sync logic ───────────────────────────────────────────────

  // Hours or Rate changed → recalculate Total.
  void _onLaborHoursOrRateChanged() {
    if (_syncingLabor) return;
    final hrs = double.tryParse(_quantity.text);
    final rate = double.tryParse(_laborRate.text);
    if (hrs == null || rate == null || hrs <= 0) return;
    final tot = hrs * rate;
    final totStr = tot % 1 == 0
        ? tot.toInt().toString()
        : tot.toStringAsFixed(2);
    if (_laborTotal.text != totStr) {
      _syncingLabor = true;
      _laborTotal.text = totStr;
      _syncingLabor = false;
    }
  }

  // Total changed → back-calculate Hours (rate stays fixed).
  void _onLaborTotalChanged() {
    if (_syncingLabor) return;
    final rate = double.tryParse(_laborRate.text);
    final tot = double.tryParse(_laborTotal.text);
    if (rate == null || tot == null || rate <= 0) return;
    final hrs = tot / rate;
    final hrsStr = hrs % 1 == 0
        ? hrs.toInt().toString()
        : hrs.toStringAsFixed(2);
    if (_quantity.text != hrsStr) {
      _syncingLabor = true;
      _quantity.text = hrsStr;
      _syncingLabor = false;
    }
  }

  // ── Markup sync logic ────────────────────────────────────────────────────

  // Called when Unit Cost changes → apply matching markup tier, then recalc.
  void _onCostChanged() {
    _applyMarkupTier();
    _recalcFromCostAndPercent();
  }

  void _onMarkupPercentChanged() => _recalcFromCostAndPercent();

  // Looks up the markup rules for the current cost and sets the markup %
  // if a matching tier is found. Uses the syncingMarkup guard so setting
  // the percent field doesn't trigger an infinite listener loop.
  void _applyMarkupTier() {
    final costDollars = double.tryParse(_unitCost.text);
    if (costDollars == null) return;
    // Convert text-field dollars to cents for comparison with int-cents rules
    final costCents = toCents(costDollars);
    final rules = ref.read(markupRulesProvider).value ?? [];
    for (final rule in rules) {
      final withinMax =
          rule.maxCost == null || costCents < rule.maxCost!;
      if (costCents >= rule.minCost && withinMax) {
        final newPct = rule.markupPercent.toStringAsFixed(1);
        if (_markupPercent.text != newPct) {
          _syncingMarkup = true;
          _markupPercent.text = newPct;
          _syncingMarkup = false;
        }
        return;
      }
    }
  }

  void _recalcFromCostAndPercent() {
    if (_syncingMarkup) return;
    final cost = double.tryParse(_unitCost.text);
    final pct = double.tryParse(_markupPercent.text);
    if (cost == null || pct == null) return;
    _syncingMarkup = true;
    final dollar = cost * pct / 100;
    final list = cost + dollar;
    _markupDollar.text = dollar.toStringAsFixed(2);
    _unitList.text = list.toStringAsFixed(2);
    _syncingMarkup = false;
  }

  // Called when Markup $ changes → recalculate Markup % and List
  void _onMarkupDollarChanged() {
    if (_syncingMarkup) return;
    final cost = double.tryParse(_unitCost.text);
    final dollar = double.tryParse(_markupDollar.text);
    if (cost == null || dollar == null) return;
    _syncingMarkup = true;
    final pct = cost > 0 ? dollar / cost * 100 : 0.0;
    final list = cost + dollar;
    _markupPercent.text = pct.toStringAsFixed(1);
    _unitList.text = list.toStringAsFixed(2);
    _syncingMarkup = false;
  }

  // Called when Unit List changes directly → back-calculate Markup $ and %
  void _onListChanged() {
    if (_syncingMarkup) return;
    final cost = double.tryParse(_unitCost.text);
    final list = double.tryParse(_unitList.text);
    if (cost == null || list == null) return;
    _syncingMarkup = true;
    final dollar = list - cost;
    final pct = cost > 0 ? dollar / cost * 100 : 0.0;
    _markupDollar.text = dollar.toStringAsFixed(2);
    _markupPercent.text = pct.toStringAsFixed(1);
    _syncingMarkup = false;
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickVendor() async {
    final vendors = ref.read(vendorsProvider).value ?? [];
    final picked = await showCupertinoModalPopup<Vendor>(
      context: context,
      builder: (_) => _VendorPickerSheet(
        vendors: vendors,
        onCreateNew: () => context.push('/repair-orders/vendors/new'),
      ),
    );
    if (picked != null) {
      setState(() {
        _vendorId = picked.id;
        _vendorName = picked.name;
      });
    }
  }

  Future<void> _pickLaborLine() async {
    // Get all line items for this estimate, filter to labor only
    final all =
        ref.read(lineItemsProvider(widget.estimateId)).value ?? [];
    final laborLines = all.where((l) => l.type == 'labor').toList();

    if (laborLines.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('No labor lines'),
          content: const Text(
              'Add a labor line to this estimate first, then you can link parts to it.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final picked = await showCupertinoModalPopup<EstimateLineItem>(
      context: context,
      builder: (_) => _LaborPickerSheet(laborLines: laborLines),
    );
    if (picked != null) {
      setState(() {
        _parentLaborId = picked.id;
        _parentLaborDesc = picked.description;
      });
    }
  }

  void _clearLaborLink() {
    setState(() {
      _parentLaborId = null;
      _parentLaborDesc = null;
    });
  }

  Future<void> _pickFromCatalog() async {
    final parts = ref.read(inventoryPartsProvider).value ?? [];
    final picked = await showCupertinoModalPopup<InventoryPart>(
      context: context,
      builder: (_) => _CatalogPickerSheet(
        parts: parts,
        onAddNew: () => context.push('/parts/new'),
      ),
    );
    if (picked != null) {
      // Temporarily remove listeners to prevent feedback loops during fill
      _unitCost.removeListener(_onCostChanged);
      _markupPercent.removeListener(_onMarkupPercentChanged);
      _markupDollar.removeListener(_onMarkupDollarChanged);
      _unitList.removeListener(_onListChanged);

      _description.text = picked.description;
      if (picked.partNumber != null && picked.partNumber!.isNotEmpty) {
        _partNumber.text = picked.partNumber!;
      }
      // cost/sellPrice are int cents — convert to dollars for display
      final costDollars = fromCents(picked.cost);
      final sellDollars = fromCents(picked.sellPrice);
      _unitCost.text = costDollars.toStringAsFixed(2);
      _unitList.text = sellDollars.toStringAsFixed(2);
      // Derive markup from cost and sell price (dollar values)
      if (picked.cost > 0) {
        final dollar = sellDollars - costDollars;
        final pct = dollar / costDollars * 100;
        _markupDollar.text = dollar.toStringAsFixed(2);
        _markupPercent.text = pct.toStringAsFixed(1);
      }

      _unitCost.addListener(_onCostChanged);
      _markupPercent.addListener(_onMarkupPercentChanged);
      _markupDollar.addListener(_onMarkupDollarChanged);
      _unitList.addListener(_onListChanged);

      setState(() {
        _catalogPartId = picked.id;
        _catalogPartName = picked.description;
      });
    }
  }

  void _clearCatalogLink() {
    setState(() {
      _catalogPartId = null;
      _catalogPartName = null;
    });
  }

  Future<void> _pickFromLaborCatalog() async {
    final templates = ref.read(serviceTemplatesProvider).value ?? [];
    final picked = await showCupertinoModalPopup<ServiceTemplate>(
      context: context,
      builder: (_) => _LaborCatalogPickerSheet(
        templates: templates,
        onAddNew: () => context.push('/settings/service-templates/new'),
      ),
    );
    if (picked != null) {
      // Auto-fill name, description, hours, and rate from the template
      _laborName.text = picked.name;
      _description.text = picked.laborDescription;
      _quantity.text = picked.defaultHours % 1 == 0
          ? picked.defaultHours.toInt().toString()
          : picked.defaultHours.toStringAsFixed(1);
      if (picked.defaultRate != null) {
        // defaultRate is stored as int cents — convert to dollars for display
        _laborRate.text = fromCents(picked.defaultRate!).toStringAsFixed(2);
      }
      setState(() => _catalogTemplateName = picked.name);

      // Load any parts linked to this template so they can be added with qtys
      final db = ref.read(dbProvider);
      final links = await db.getTemplatePartsForTemplate(picked.id);
      // Dispose old qty controllers before replacing the list
      for (final e in _linkedTemplateParts) e.qtyController.dispose();
      final entries =
          <({InventoryPart part, TextEditingController qtyController})>[];
      for (final link in links) {
        final part = await db.getPart(link.inventoryPartId);
        if (part != null) {
          entries.add((
            part: part,
            qtyController: TextEditingController(text: '1'),
          ));
        }
      }
      if (mounted) setState(() {
        _linkedTemplateParts = entries;
        _showLinkedParts = entries.isNotEmpty;
      });
    }
  }

  void _clearLaborCatalogLink() {
    for (final e in _linkedTemplateParts) e.qtyController.dispose();
    setState(() {
      _catalogTemplateName = null;
      _linkedTemplateParts = [];
      _showLinkedParts = false;
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final desc = _description.text.trim();
    final qty = double.tryParse(_quantity.text.replaceAll(',', ''));

    // 'other' type uses name instead of description for required check
    if (_isOther) {
      final name = _laborName.text.trim();
      if (name.isEmpty) {
        _showError('Please enter a name.');
        return;
      }
      final listPrice =
          double.tryParse(_unitList.text.replaceAll(',', '')) ?? 0.0;
      final costDollars =
          double.tryParse(_unitCost.text.replaceAll(',', ''));
      setState(() => _saving = true);
      final db = ref.read(dbProvider);
      // Convert dollar amounts to int cents before saving
      if (_isEditing) {
        await db.updateLineItem(widget.lineItem!.copyWith(
          description: desc.isEmpty ? name : desc,
          laborName: Value(name),
          quantity: 1.0,
          unitPrice: toCents(listPrice),
          unitCost: Value(costDollars != null ? toCents(costDollars) : null),
        ));
      } else {
        await db.insertLineItem(EstimateLineItemsCompanion.insert(
          estimateId: widget.estimateId,
          type: 'other',
          description: desc.isEmpty ? name : desc,
          laborName: Value(name),
          quantity: const Value(1.0),
          unitPrice: toCents(listPrice),
          unitCost: Value(costDollars != null ? toCents(costDollars) : null),
          approvalStatus: const Value('approved'),
        ));
      }
      if (mounted) context.pop();
      return;
    }

    if (desc.isEmpty) {
      _showError('Please enter a description.');
      return;
    }
    if (qty == null || qty <= 0) {
      _showError(_isLabor
          ? 'Please enter a valid number of hours.'
          : 'Please enter a valid quantity.');
      return;
    }

    double? priceDollars;
    double? unitCostDollars;

    if (_isLabor) {
      priceDollars = double.tryParse(_laborRate.text.replaceAll(',', ''));
      if (priceDollars == null || priceDollars < 0) {
        _showError('Please enter a valid rate.');
        return;
      }
    } else {
      priceDollars = double.tryParse(_unitList.text.replaceAll(',', ''));
      unitCostDollars = double.tryParse(_unitCost.text.replaceAll(',', ''));
      if (priceDollars == null || priceDollars < 0) {
        _showError('Please enter a valid unit list price.');
        return;
      }
    }

    setState(() => _saving = true);
    final db = ref.read(dbProvider);

    final laborNameVal = _laborName.text.trim();
    final partNumberVal = _partNumber.text.trim();

    // Convert dollar amounts to int cents before saving to the database
    final unitPriceCents = toCents(priceDollars);
    final unitCostCents =
        unitCostDollars != null ? toCents(unitCostDollars) : null;

    if (_isEditing) {
      final existing = widget.lineItem!;
      await db.updateLineItem(existing.copyWith(
        description: desc,
        quantity: qty,
        unitPrice: unitPriceCents,
        unitCost: Value(unitCostCents),
        vendorId: Value(_vendorId),
        parentLaborId: Value(_parentLaborId),
        inventoryPartId: Value(_catalogPartId ?? existing.inventoryPartId),
        laborName: Value(laborNameVal.isEmpty ? null : laborNameVal),
        partNumber: Value(partNumberVal.isEmpty ? null : partNumberVal),
      ));
    } else {
      final newId = await db.insertLineItem(EstimateLineItemsCompanion.insert(
        estimateId: widget.estimateId,
        type: widget.type,
        description: desc,
        quantity: Value(qty),
        unitPrice: unitPriceCents,
        unitCost: Value(unitCostCents),
        vendorId: Value(_vendorId),
        parentLaborId: Value(_parentLaborId),
        inventoryPartId: Value(_catalogPartId),
        laborName: Value(laborNameVal.isEmpty ? null : laborNameVal),
        partNumber: Value(partNumberVal.isEmpty ? null : partNumberVal),
        approvalStatus: const Value('approved'),
      ));
      // Insert linked template parts, each tied to the new labor line.
      // part.sellPrice and part.cost are already int cents — copy directly.
      if (_isLabor) {
        for (final entry in _linkedTemplateParts) {
          final q = double.tryParse(
                  entry.qtyController.text.replaceAll(',', '')) ??
              1.0;
          if (q > 0) {
            await db.insertLineItem(EstimateLineItemsCompanion.insert(
              estimateId: widget.estimateId,
              type: 'part',
              description: entry.part.description,
              quantity: Value(q),
              unitPrice: entry.part.sellPrice,   // int cents → int cents
              unitCost: Value(entry.part.cost),  // int cents → int cents
              inventoryPartId: Value(entry.part.id),
              parentLaborId: Value(newId),
              approvalStatus: const Value('approved'),
            ));
          }
        }
      }
    }
    if (mounted) context.pop();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Missing info'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    _laborName.dispose();
    _laborRate.dispose();
    _laborTotal.dispose();
    _partNumber.dispose();
    _unitCost.dispose();
    _markupPercent.dispose();
    _markupDollar.dispose();
    _unitList.dispose();
    for (final e in _linkedTemplateParts) e.qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers so streams are active before the user taps a picker,
    // and so markup rules are available for auto-fill when cost is typed.
    ref.watch(vendorsProvider);
    ref.watch(inventoryPartsProvider);
    ref.watch(markupRulesProvider);
    ref.watch(serviceTemplatesProvider);

    final title = _isEditing
        ? (_isLabor ? 'Edit Labor' : _isOther ? 'Edit Other' : 'Edit Part')
        : (_isLabor ? 'Add Labor' : _isOther ? 'Add Other' : 'Add Part');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        trailing: _saving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _save,
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 28),
            _sectionHeader(_isLabor ? 'LABOR' : _isOther ? 'OTHER' : 'PART'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  if (_isOther) ...[
                    // ── Other: Name (required) ───────────────────────────────
                    _Field(
                      label: 'Name',
                      controller: _laborName,
                      placeholder: 'e.g. Sublet, Shop Supplies',
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                    ),
                    _divider(),
                    // ── Other: Description (optional) ────────────────────────
                    _Field(
                      label: 'Description',
                      controller: _description,
                      placeholder: 'Optional details',
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    _divider(),
                    // ── Other: Cost ──────────────────────────────────────────
                    _Field(
                      label: 'Cost',
                      controller: _unitCost,
                      placeholder: '0',
                      prefix: '\$',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      selectAllOnTap: true,
                    ),
                    _divider(),
                    // ── Other: List Price ────────────────────────────────────
                    _Field(
                      label: 'List Price',
                      controller: _unitList,
                      placeholder: '0',
                      prefix: '\$',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      selectAllOnTap: true,
                    ),
                  ] else if (_isLabor) ...[
                    // ── Labor: Name (shown first for labor) ──────────
                    _Field(
                      label: 'Labor Name',
                      controller: _laborName,
                      placeholder: 'e.g. Oil Change',
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                    ),
                    _divider(),
                  ],
                  // ── Shared: Description ──────────────────────────────
                  _Field(
                    label: _isLabor ? 'Labor Description' : 'Description',
                    controller: _description,
                    placeholder: _isLabor
                        ? 'e.g. Brake pad replacement'
                        : 'e.g. Brake Pads (front)',
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: !_isLabor,
                  ),
                  _divider(),
                  // ── Shared: Qty / Hours ──────────────────────────────
                  _Field(
                    label: _isLabor ? 'Hours' : 'Qty',
                    controller: _quantity,
                    placeholder: _isLabor ? '2.5' : '1',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                    selectAllOnTap: true,
                  ),
                  _divider(),

                  if (_isLabor) ...[
                    // ── Labor: From Catalog picker ───────────────────
                    _CatalogPickerRow(
                      label: 'Operation',
                      placeholder: 'Pick from service templates',
                      selectedName: _catalogTemplateName,
                      onTap: () => _pickFromLaborCatalog(),
                      onClear: _catalogTemplateName != null
                          ? _clearLaborCatalogLink
                          : null,
                    ),
                    _divider(),
                    // ── Labor: Rate/hr ───────────────────────────────
                    _Field(
                      label: 'Rate/hr',
                      controller: _laborRate,
                      placeholder: '120',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      selectAllOnTap: true,
                    ),
                    _divider(),
                    // ── Labor: Total ─────────────────────────────────
                    _Field(
                      label: 'Total',
                      controller: _laborTotal,
                      placeholder: '—',
                      prefix: '\$',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      selectAllOnTap: true,
                    ),
                  ] else ...[
                    // ── Parts: Part number ───────────────────────────
                    _Field(
                      label: 'Part #',
                      controller: _partNumber,
                      placeholder: 'e.g. ACDelco 41-993',
                      textCapitalization: TextCapitalization.characters,
                    ),
                    _divider(),
                    // ── Parts: From Catalog picker ───────────────────
                    _CatalogPickerRow(
                      label: 'Catalog',
                      placeholder: 'Pick from inventory',
                      selectedName: _catalogPartName,
                      onTap: () => _pickFromCatalog(),
                      onClear: _catalogPartName != null
                          ? _clearCatalogLink
                          : null,
                    ),
                    _divider(),
                    // ── Parts: Unit Cost ─────────────────────────────
                    _Field(
                      label: 'Unit Cost',
                      controller: _unitCost,
                      placeholder: '10',
                      prefix: '\$',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      selectAllOnTap: true,
                    ),
                    _divider(),
                    // ── Parts: Markup % and Markup $ (side-by-side) ──
                    _MarkupRow(
                      percentController: _markupPercent,
                      dollarController: _markupDollar,
                    ),
                    _divider(),
                    // ── Parts: Unit List ─────────────────────────────
                    _Field(
                      label: 'Unit List',
                      controller: _unitList,
                      placeholder: '13',
                      prefix: '\$',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      selectAllOnTap: true,
                    ),
                    _divider(),
                    // ── Parts: Vendor picker ─────────────────────────
                    _VendorPickerRow(
                      selectedName: _vendorName,
                      onTap: () => _pickVendor(),
                    ),
                    _divider(),
                    // ── Parts: Labor association picker ──────────────
                    _LaborPickerRow(
                      selectedDesc: _parentLaborDesc,
                      onTap: () => _pickLaborLine(),
                      onClear: _parentLaborDesc != null
                          ? _clearLaborLink
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            // ── Linked template parts dropdown (labor mode only) ──────────
            if (_isLabor && _linkedTemplateParts.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionHeader('LINKED PARTS'),
              Container(
                color: CupertinoColors.white,
                child: Column(
                  children: [
                    // Tappable header row — tap to expand/collapse
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showLinkedParts = !_showLinkedParts),
                      child: Container(
                        color: CupertinoColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.cube_box_fill,
                                size: 18, color: Color(0xFF007AFF)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_linkedTemplateParts.length} linked part${_linkedTemplateParts.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF007AFF)),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _showLinkedParts ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(CupertinoIcons.chevron_right,
                                  size: 16, color: Color(0xFFC7C7CC)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expandable part rows
                    if (_showLinkedParts) ...[
                      Container(
                        height: 0.5,
                        color: const Color(0xFFE5E5EA),
                        margin: const EdgeInsets.only(left: 16),
                      ),
                      for (int i = 0;
                          i < _linkedTemplateParts.length;
                          i++) ...[
                        _LinkedPartQtyRow(
                          part: _linkedTemplateParts[i].part,
                          qtyController:
                              _linkedTemplateParts[i].qtyController,
                        ),
                        if (i < _linkedTemplateParts.length - 1)
                          Container(
                            height: 0.5,
                            color: const Color(0xFFE5E5EA),
                            margin: const EdgeInsets.only(left: 16),
                          ),
                      ],
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            // Live preview of the line total
            _LinePreview(
              isLabor: _isLabor,
              quantityController: _quantity,
              priceController: _isLabor ? _laborRate : _unitList,
              linkedParts: _isLabor
                  ? _linkedTemplateParts
                      .map((e) => (
                            sellPrice: fromCents(e.part.sellPrice),
                            qtyController: e.qtyController,
                          ))
                      .toList()
                  : null,
            ),
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

  Widget _divider() => Container(
        height: 0.5,
        color: const Color(0xFFE5E5EA),
        margin: const EdgeInsets.only(left: 96),
      );
}

// ─── Linked Part Qty Row ──────────────────────────────────────────────────────
// Shows a single template-linked part with its description and an editable qty.
class _LinkedPartQtyRow extends StatelessWidget {
  final InventoryPart part;
  final TextEditingController qtyController;

  const _LinkedPartQtyRow({
    required this.part,
    required this.qtyController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(CupertinoIcons.cube_box,
              size: 16, color: Color(0xFF8E8E93)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.description,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF1C1C1E)),
                ),
                if (part.partNumber != null && part.partNumber!.isNotEmpty)
                  Text(
                    part.partNumber!,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: CupertinoTextField.borderless(
              controller: qtyController,
              placeholder: '1',
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
              onTap: () => qtyController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: qtyController.text.length,
              ),
              contextMenuBuilder: (context, editableTextState) =>
                  CupertinoAdaptiveTextSelectionToolbar.editableText(
                editableTextState: editableTextState,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text('qty',
              style:
                  TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }
}

// ─── Field ────────────────────────────────────────────────────────────────────
// A single labeled text field row.
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final String? prefix;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  /// When true, tapping the field selects all text (good for numeric fields
  /// so the user can immediately type a replacement value).
  final bool selectAllOnTap;

  const _Field({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.prefix,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofocus = false,
    this.selectAllOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF1C1C1E)),
            ),
          ),
          if (prefix != null)
            Text(prefix!,
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF8E8E93))),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormatters,
              autofocus: autofocus,
              onTap: selectAllOnTap
                  ? () => controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controller.text.length,
                      )
                  : null,
              contextMenuBuilder: (context, editableTextState) {
                return CupertinoAdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF1C1C1E)),
              placeholderStyle: const TextStyle(
                  fontSize: 16, color: Color(0xFFC7C7CC)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Markup Row ───────────────────────────────────────────────────────────────
// Two side-by-side text fields for markup % and markup $.
// Editing one auto-updates the other (logic lives in the parent state).
class _MarkupRow extends StatelessWidget {
  final TextEditingController percentController;
  final TextEditingController dollarController;

  const _MarkupRow({
    required this.percentController,
    required this.dollarController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 96,
            child: Text('Markup',
                style: TextStyle(fontSize: 16, color: Color(0xFF1C1C1E))),
          ),
          // Percent field
          Expanded(
            child: CupertinoTextField.borderless(
              controller: percentController,
              placeholder: '30.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onTap: () => percentController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: percentController.text.length,
              ),
              contextMenuBuilder: (context, editableTextState) {
                return CupertinoAdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
              placeholderStyle:
                  const TextStyle(fontSize: 16, color: Color(0xFFC7C7CC)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              suffix: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text('%',
                    style: TextStyle(
                        fontSize: 15, color: Color(0xFF8E8E93))),
              ),
            ),
          ),
          Container(
              width: 0.5,
              height: 30,
              color: const Color(0xFFE5E5EA),
              margin: const EdgeInsets.symmetric(horizontal: 8)),
          // Dollar field
          Expanded(
            child: CupertinoTextField.borderless(
              controller: dollarController,
              placeholder: '3',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onTap: () => dollarController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: dollarController.text.length,
              ),
              contextMenuBuilder: (context, editableTextState) {
                return CupertinoAdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
              placeholderStyle:
                  const TextStyle(fontSize: 16, color: Color(0xFFC7C7CC)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              prefix: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text('\$',
                    style: TextStyle(
                        fontSize: 15, color: Color(0xFF8E8E93))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Line Preview ─────────────────────────────────────────────────────────────
// Shows a live "Line total: $X.XX" preview that updates as the user types.
class _LinePreview extends StatefulWidget {
  final bool isLabor;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  // Linked template parts (labor only). Each entry has a sell price and a
  // qty controller so the preview updates live as the user edits qtys.
  final List<({double sellPrice, TextEditingController qtyController})>?
      linkedParts;

  const _LinePreview({
    required this.isLabor,
    required this.quantityController,
    required this.priceController,
    this.linkedParts,
  });

  @override
  State<_LinePreview> createState() => _LinePreviewState();
}

class _LinePreviewState extends State<_LinePreview> {
  @override
  void initState() {
    super.initState();
    widget.quantityController.addListener(_rebuild);
    widget.priceController.addListener(_rebuild);
    _addPartListeners(widget.linkedParts);
  }

  @override
  void didUpdateWidget(_LinePreview old) {
    super.didUpdateWidget(old);
    // Re-wire listeners when the linked parts list changes
    if (old.linkedParts != widget.linkedParts) {
      _removePartListeners(old.linkedParts);
      _addPartListeners(widget.linkedParts);
    }
  }

  @override
  void dispose() {
    widget.quantityController.removeListener(_rebuild);
    widget.priceController.removeListener(_rebuild);
    _removePartListeners(widget.linkedParts);
    super.dispose();
  }

  void _addPartListeners(
      List<({double sellPrice, TextEditingController qtyController})>? parts) {
    for (final p in parts ?? []) p.qtyController.addListener(_rebuild);
  }

  void _removePartListeners(
      List<({double sellPrice, TextEditingController qtyController})>? parts) {
    for (final p in parts ?? []) p.qtyController.removeListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final qty =
        double.tryParse(widget.quantityController.text.replaceAll(',', ''));
    final price =
        double.tryParse(widget.priceController.text.replaceAll(',', ''));

    if (qty == null || price == null || qty <= 0) {
      return const SizedBox.shrink();
    }

    final laborTotal = qty * price;
    final label = widget.isLabor
        ? '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} hr × \$${price.toStringAsFixed(2)}/hr'
        : '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} × \$${price.toStringAsFixed(2)} list';

    // Calculate parts subtotal from linked template parts (if any)
    final parts = widget.linkedParts ?? [];
    double partsTotal = 0;
    for (final p in parts) {
      final q =
          double.tryParse(p.qtyController.text.replaceAll(',', '')) ?? 1.0;
      partsTotal += q * p.sellPrice;
    }
    final hasLinkedParts = parts.isNotEmpty && partsTotal > 0;

    final subTextStyle =
        const TextStyle(fontSize: 13, color: Color(0xFF8E8E93));
    final totalStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1C1C1E),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: hasLinkedParts
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Labor line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: subTextStyle),
                    Text('\$${laborTotal.toStringAsFixed(2)}',
                        style: subTextStyle),
                  ],
                ),
                const SizedBox(height: 2),
                // Parts line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('parts', style: subTextStyle),
                    Text('\$${partsTotal.toStringAsFixed(2)}',
                        style: subTextStyle),
                  ],
                ),
                const SizedBox(height: 4),
                // Total line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('total', style: subTextStyle),
                    Text(
                      '= \$${(laborTotal + partsTotal).toStringAsFixed(2)}',
                      style: totalStyle,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: subTextStyle),
                Text(
                  '= \$${laborTotal.toStringAsFixed(2)}',
                  style: totalStyle,
                ),
              ],
            ),
    );
  }
}

// ─── Vendor Picker Row ────────────────────────────────────────────────────────
class _VendorPickerRow extends StatelessWidget {
  final String? selectedName;
  final VoidCallback onTap;

  const _VendorPickerRow({required this.selectedName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            const SizedBox(
              width: 96,
              child: Text('Vendor',
                  style: TextStyle(fontSize: 16, color: Color(0xFF1C1C1E))),
            ),
            Expanded(
              child: Text(
                selectedName ?? 'Optional',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedName != null
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFC7C7CC),
                ),
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

// ─── Labor Picker Row ─────────────────────────────────────────────────────────
class _LaborPickerRow extends StatelessWidget {
  final String? selectedDesc;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _LaborPickerRow({
    required this.selectedDesc,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            const SizedBox(
              width: 96,
              child: Text('Labor',
                  style: TextStyle(fontSize: 16, color: Color(0xFF1C1C1E))),
            ),
            Expanded(
              child: Text(
                selectedDesc ?? 'Optional',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDesc != null
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFC7C7CC),
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(CupertinoIcons.xmark_circle_fill,
                      size: 18, color: Color(0xFFC7C7CC)),
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

// ─── Vendor Picker Sheet ──────────────────────────────────────────────────────
class _VendorPickerSheet extends StatefulWidget {
  final List<Vendor> vendors;
  final VoidCallback? onCreateNew;
  const _VendorPickerSheet({required this.vendors, this.onCreateNew});

  @override
  State<_VendorPickerSheet> createState() => _VendorPickerSheetState();
}

class _VendorPickerSheetState extends State<_VendorPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<Vendor> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.vendors;
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
          ? widget.vendors
          : widget.vendors
              .where((v) =>
                  v.name.toLowerCase().contains(q) ||
                  (v.contactName?.toLowerCase().contains(q) ?? false) ||
                  (v.accountNumber?.toLowerCase().contains(q) ?? false))
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Select Vendor',
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
              placeholder: 'Search',
            ),
          ),
          Container(height: 0.5, color: const Color(0xFFE5E5EA)),
          // ── "+ Add Vendor" row ─────────────────────────────────────────
          if (widget.onCreateNew != null) ...[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onCreateNew!();
              },
              child: Container(
                color: CupertinoColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.plus_circle_fill,
                        size: 18, color: Color(0xFF007AFF)),
                    SizedBox(width: 10),
                    Text('Add Vendor',
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF007AFF))),
                  ],
                ),
              ),
            ),
            if (_filtered.isNotEmpty)
              Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16)),
          ],
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
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => Navigator.pop(context, _filtered[i]),
                  child: Container(
                    color: CupertinoColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_filtered[i].name,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF1C1C1E))),
                        if (_filtered[i].contactName != null)
                          Text(_filtered[i].contactName!,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF8E8E93))),
                        if (_filtered[i].accountNumber != null)
                          Text('Acct: ${_filtered[i].accountNumber}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF8E8E93))),
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
                'No vendors match "${_searchCtrl.text}"',
                style:
                    const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Labor Picker Sheet ───────────────────────────────────────────────────────
class _LaborPickerSheet extends StatefulWidget {
  final List<EstimateLineItem> laborLines;
  const _LaborPickerSheet({required this.laborLines});

  @override
  State<_LaborPickerSheet> createState() => _LaborPickerSheetState();
}

class _LaborPickerSheetState extends State<_LaborPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<EstimateLineItem> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.laborLines;
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
          ? widget.laborLines
          : widget.laborLines
              .where((l) => l.description.toLowerCase().contains(q))
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Link to Labor',
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
              placeholder: 'Search',
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
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => Navigator.pop(context, _filtered[i]),
                  child: Container(
                    color: CupertinoColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.wrench_fill,
                            size: 16, color: Color(0xFF8E8E93)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_filtered[i].description,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF1C1C1E))),
                        ),
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
                'No labor lines match "${_searchCtrl.text}"',
                style:
                    const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Catalog Picker Row ───────────────────────────────────────────────────────
class _CatalogPickerRow extends StatelessWidget {
  final String? selectedName;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String label;
  final String placeholder;

  const _CatalogPickerRow({
    required this.selectedName,
    required this.onTap,
    this.onClear,
    this.label = 'Catalog',
    this.placeholder = 'Pick from inventory',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(label,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E))),
            ),
            Expanded(
              child: Text(
                selectedName ?? placeholder,
                style: TextStyle(
                  fontSize: 16,
                  color: selectedName != null
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFC7C7CC),
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(CupertinoIcons.xmark_circle_fill,
                      size: 18, color: Color(0xFFC7C7CC)),
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

// ─── Catalog Picker Sheet ─────────────────────────────────────────────────────
class _CatalogPickerSheet extends StatefulWidget {
  final List<InventoryPart> parts;
  final VoidCallback? onAddNew;
  const _CatalogPickerSheet({required this.parts, this.onAddNew});

  @override
  State<_CatalogPickerSheet> createState() => _CatalogPickerSheetState();
}

class _CatalogPickerSheetState extends State<_CatalogPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? widget.parts
        : widget.parts
            .where((p) =>
                p.description.toLowerCase().contains(_search.toLowerCase()) ||
                (p.partNumber?.toLowerCase().contains(_search.toLowerCase()) ??
                    false))
            .toList();

    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Pick from Catalog',
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
              placeholder: 'Search parts…',
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Container(height: 0.5, color: const Color(0xFFE5E5EA)),
          if (widget.onAddNew != null) ...[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onAddNew!();
              },
              child: Container(
                color: CupertinoColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.plus_circle_fill,
                        size: 18, color: Color(0xFF007AFF)),
                    SizedBox(width: 10),
                    Text('Add to Inventory',
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF007AFF))),
                  ],
                ),
              ),
            ),
            if (filtered.isNotEmpty)
              Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16)),
          ],
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _search.isEmpty
                    ? 'No parts in inventory yet.'
                    : 'No parts match "$_search".',
                style: const TextStyle(
                    fontSize: 15, color: CupertinoColors.secondaryLabel),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16),
                ),
                itemBuilder: (context, i) {
                  final part = filtered[i];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, part),
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(part.description,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1C1C1E))),
                                if (part.partNumber != null &&
                                    part.partNumber!.isNotEmpty)
                                  Text(part.partNumber!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8E8E93))),
                              ],
                            ),
                          ),
                          Text(
                            '\$${part.sellPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Labor Catalog Picker Sheet ───────────────────────────────────────────────
// Lets the user pick a service template to auto-fill the labor form.
class _LaborCatalogPickerSheet extends StatefulWidget {
  final List<ServiceTemplate> templates;
  final VoidCallback? onAddNew;
  const _LaborCatalogPickerSheet({required this.templates, this.onAddNew});

  @override
  State<_LaborCatalogPickerSheet> createState() =>
      _LaborCatalogPickerSheetState();
}

class _LaborCatalogPickerSheetState extends State<_LaborCatalogPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? widget.templates
        : widget.templates
            .where((t) =>
                t.name.toLowerCase().contains(_search.toLowerCase()) ||
                t.laborDescription.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Pick Operation',
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
              placeholder: 'Search templates…',
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Container(height: 0.5, color: const Color(0xFFE5E5EA)),
          if (widget.onAddNew != null) ...[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onAddNew!();
              },
              child: Container(
                color: CupertinoColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.plus_circle_fill,
                        size: 18, color: Color(0xFF007AFF)),
                    SizedBox(width: 10),
                    Text('New Service Template',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF007AFF))),
                  ],
                ),
              ),
            ),
            if (filtered.isNotEmpty)
              Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16)),
          ],
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _search.isEmpty
                    ? 'No service templates yet.'
                    : 'No templates match "$_search".',
                style: const TextStyle(
                    fontSize: 15, color: CupertinoColors.secondaryLabel),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16),
                ),
                itemBuilder: (context, i) {
                  final t = filtered[i];
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1C1C1E))),
                          const SizedBox(height: 2),
                          Text(t.laborDescription,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF8E8E93))),
                          const SizedBox(height: 2),
                          Text(
                            () {
                              final hrs = t.defaultHours % 1 == 0
                                  ? '${t.defaultHours.toInt()}'
                                  : t.defaultHours.toStringAsFixed(1);
                              if (t.defaultRate != null) {
                                final total = t.defaultHours * t.defaultRate!;
                                return '$hrs hr  ·  \$${t.defaultRate!.toStringAsFixed(2)}/hr  =  \$${total.toStringAsFixed(2)}';
                              }
                              return '$hrs hr';
                            }(),
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

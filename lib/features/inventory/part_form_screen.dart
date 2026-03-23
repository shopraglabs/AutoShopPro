import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';
import '../settings/markup_rules_provider.dart';

const _kCategories = ['Part', 'Fluid', 'Filter', 'Chemical'];

class PartFormScreen extends ConsumerStatefulWidget {
  // If provided, we are editing an existing part. If null, we are creating one.
  final InventoryPart? part;
  const PartFormScreen({super.key, this.part});

  @override
  ConsumerState<PartFormScreen> createState() => _PartFormScreenState();
}

class _PartFormScreenState extends ConsumerState<PartFormScreen> {
  late final TextEditingController _partNumberCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _markupPercentCtrl;
  late final TextEditingController _sellPriceCtrl;
  late final TextEditingController _stockQtyCtrl;
  late final TextEditingController _lowStockCtrl;
  late String _category;

  bool _saving = false;
  // Guard flag: prevents markup sync from triggering infinite listener loops.
  bool _syncing = false;

  bool get _isEditing => widget.part != null;

  @override
  void initState() {
    super.initState();
    final p = widget.part;
    _partNumberCtrl = TextEditingController(text: p?.partNumber ?? '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _costCtrl = TextEditingController(
        text: p != null ? p.cost.toStringAsFixed(2) : '');
    _markupPercentCtrl = TextEditingController();
    _sellPriceCtrl = TextEditingController(
        text: p != null ? p.sellPrice.toStringAsFixed(2) : '');
    _stockQtyCtrl =
        TextEditingController(text: p != null ? '${p.stockQty}' : '0');
    _lowStockCtrl = TextEditingController(
        text: p != null ? '${p.lowStockThreshold}' : '2');
    _category = p?.category ?? 'Part';

    // Derive markup % from existing cost/sell price when editing.
    if (p != null && p.cost > 0) {
      final pct = (p.sellPrice - p.cost) / p.cost * 100;
      _markupPercentCtrl.text = pct.toStringAsFixed(1);
    }

    // Wire up listeners after all controllers are initialized.
    _costCtrl.addListener(_onCostChanged);
    _markupPercentCtrl.addListener(_onMarkupPercentChanged);
    _sellPriceCtrl.addListener(_onSellPriceChanged);

    // For new parts, load the default markup % from settings.
    if (!_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDefaultMarkup());
    }
  }

  @override
  void dispose() {
    _partNumberCtrl.dispose();
    _descriptionCtrl.dispose();
    _costCtrl.dispose();
    _markupPercentCtrl.dispose();
    _sellPriceCtrl.dispose();
    _stockQtyCtrl.dispose();
    _lowStockCtrl.dispose();
    super.dispose();
  }

  // Loads the shop's default markup % into the field when creating a new part.
  Future<void> _loadDefaultMarkup() async {
    final settings = await ref.read(dbProvider).getOrCreateSettings();
    if (mounted && _markupPercentCtrl.text.isEmpty) {
      _markupPercentCtrl.text =
          settings.defaultPartsMarkup.toStringAsFixed(1);
    }
  }

  // ── Markup sync logic ──────────────────────────────────────────────────────

  // Called when Cost changes → auto-apply matching markup tier, then recalc.
  void _onCostChanged() {
    _applyMarkupTier();
    _recalcSellPrice();
  }

  // Called when Markup % changes → recalculate Sell Price.
  void _onMarkupPercentChanged() => _recalcSellPrice();

  // Called when Sell Price is edited directly → back-calculate Markup %.
  void _onSellPriceChanged() {
    if (_syncing) return;
    final cost = double.tryParse(_costCtrl.text);
    final sell = double.tryParse(_sellPriceCtrl.text);
    if (cost == null || sell == null || cost <= 0) return;
    _syncing = true;
    final pct = (sell - cost) / cost * 100;
    _markupPercentCtrl.text = pct.toStringAsFixed(1);
    _syncing = false;
  }

  // Looks up the markup rules for the current cost and sets Markup %
  // if a matching tier is found.
  void _applyMarkupTier() {
    final cost = double.tryParse(_costCtrl.text);
    if (cost == null) return;
    final rules = ref.read(markupRulesProvider).value ?? [];
    for (final rule in rules) {
      final withinMax = rule.maxCost == null || cost < rule.maxCost!;
      if (cost >= rule.minCost && withinMax) {
        final newPct = rule.markupPercent.toStringAsFixed(1);
        if (_markupPercentCtrl.text != newPct) {
          _syncing = true;
          _markupPercentCtrl.text = newPct;
          _syncing = false;
        }
        return;
      }
    }
  }

  // Recalculates Sell Price from Cost × (1 + Markup% / 100).
  void _recalcSellPrice() {
    if (_syncing) return;
    final cost = double.tryParse(_costCtrl.text);
    final pct = double.tryParse(_markupPercentCtrl.text);
    if (cost == null || pct == null) return;
    _syncing = true;
    final sell = cost * (1 + pct / 100);
    _sellPriceCtrl.text = sell.toStringAsFixed(2);
    _syncing = false;
  }

  // ── Category picker ────────────────────────────────────────────────────────

  Future<void> _pickCategory() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => CupertinoActionSheet(
        title: const Text('Category'),
        actions: _kCategories
            .map((cat) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() => _category = cat);
                    Navigator.pop(sheetCtx);
                  },
                  child: Text(cat),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetCtx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // ── Save / Delete ──────────────────────────────────────────────────────────

  Future<void> _save() async {
    final description = _descriptionCtrl.text.trim();
    if (description.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Description required'),
          content: const Text('Please enter a description for this part.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final db = ref.read(dbProvider);

    final cost = double.tryParse(_costCtrl.text) ?? 0.0;
    final sellPrice = double.tryParse(_sellPriceCtrl.text) ?? 0.0;
    final stockQty = int.tryParse(_stockQtyCtrl.text) ?? 0;
    final lowStock = int.tryParse(_lowStockCtrl.text) ?? 2;
    final partNumber = _partNumberCtrl.text.trim();

    if (_isEditing) {
      await db.updatePart(widget.part!.copyWith(
        partNumber: Value(partNumber.isEmpty ? null : partNumber),
        description: description,
        category: Value(_category),
        cost: cost,
        sellPrice: sellPrice,
        stockQty: stockQty,
        lowStockThreshold: lowStock,
      ));
    } else {
      await db.insertPart(InventoryPartsCompanion(
        partNumber: Value(partNumber.isEmpty ? null : partNumber),
        description: Value(description),
        category: Value(_category),
        cost: Value(cost),
        sellPrice: Value(sellPrice),
        stockQty: Value(stockQty),
        lowStockThreshold: Value(lowStock),
      ));
    }

    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Delete Part'),
        content: const Text(
            'This will permanently remove this part from inventory.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(dbProvider).deletePart(widget.part!.id);
      if (mounted) context.pop();
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _field({
    required String label,
    required TextEditingController controller,
    String placeholder = '',
    TextInputType keyboardType = TextInputType.text,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          color: CupertinoColors.systemBackground,
          child: CupertinoTextField.borderless(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            autofocus: autofocus,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            ),
            contextMenuBuilder: (context, editableTextState) =>
                CupertinoAdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                ),
          ),
        ),
        Container(height: 0.5, color: const Color(0xFFE5E5EA)),
      ],
    );
  }

  // Inline markup row: Cost | Markup % | Sell Price — three fields side by side.
  Widget _markupRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            'PRICING',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          color: CupertinoColors.systemBackground,
          child: Row(
            children: [
              // Cost
              Expanded(
                child: _markupCell(
                  label: 'Cost',
                  controller: _costCtrl,
                  placeholder: '0',
                  borderRight: true,
                ),
              ),
              // Markup %
              Expanded(
                child: _markupCell(
                  label: 'Markup %',
                  controller: _markupPercentCtrl,
                  placeholder: '0',
                  borderRight: true,
                ),
              ),
              // Sell Price
              Expanded(
                child: _markupCell(
                  label: 'Sell Price',
                  controller: _sellPriceCtrl,
                  placeholder: '0',
                  borderRight: false,
                ),
              ),
            ],
          ),
        ),
        Container(height: 0.5, color: const Color(0xFFE5E5EA)),
      ],
    );
  }

  Widget _markupCell({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required bool borderRight,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: borderRight
            ? const Border(
                right: BorderSide(color: Color(0xFFE5E5EA), width: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ),
          CupertinoTextField.borderless(
            controller: controller,
            placeholder: placeholder,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            onTap: () => controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            ),
            contextMenuBuilder: (context, editableTextState) =>
                CupertinoAdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch markup rules so the provider is live when cost is typed.
    ref.watch(markupRulesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Part' : 'New Part'),
        trailing: _saving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _save,
                child: const Text('Save'),
              ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _field(
              label: 'Description',
              controller: _descriptionCtrl,
              placeholder: 'e.g. Front Brake Pads',
              autofocus: !_isEditing,
            ),
            _field(
              label: 'Part Number',
              controller: _partNumberCtrl,
              placeholder: 'e.g. BP-4502',
            ),
            // ── Category picker ───────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickCategory,
                  child: Container(
                    color: CupertinoColors.systemBackground,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _category,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF1C1C1E)),
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_up_chevron_down,
                            size: 16, color: Color(0xFFC7C7CC)),
                      ],
                    ),
                  ),
                ),
                Container(height: 0.5, color: const Color(0xFFE5E5EA)),
              ],
            ),
            // ── Pricing: Cost | Markup % | Sell Price ─────────────────────
            _markupRow(),
            _field(
              label: 'Stock Quantity',
              controller: _stockQtyCtrl,
              placeholder: '0',
              keyboardType: TextInputType.number,
            ),
            _field(
              label: 'Low Stock Alert Threshold',
              controller: _lowStockCtrl,
              placeholder: '2',
              keyboardType: TextInputType.number,
            ),

            if (_isEditing) ...[
              const SizedBox(height: 32),
              Center(
                child: CupertinoButton(
                  onPressed: _delete,
                  child: const Text(
                    'Delete Part',
                    style:
                        TextStyle(color: CupertinoColors.destructiveRed),
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
}

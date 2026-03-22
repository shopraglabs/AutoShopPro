import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

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
  late final TextEditingController _sellPriceCtrl;
  late final TextEditingController _stockQtyCtrl;
  late final TextEditingController _lowStockCtrl;

  bool _saving = false;

  bool get _isEditing => widget.part != null;

  @override
  void initState() {
    super.initState();
    final p = widget.part;
    _partNumberCtrl = TextEditingController(text: p?.partNumber ?? '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _costCtrl = TextEditingController(
        text: p != null ? p.cost.toStringAsFixed(2) : '');
    _sellPriceCtrl = TextEditingController(
        text: p != null ? p.sellPrice.toStringAsFixed(2) : '');
    _stockQtyCtrl =
        TextEditingController(text: p != null ? '${p.stockQty}' : '0');
    _lowStockCtrl = TextEditingController(
        text: p != null ? '${p.lowStockThreshold}' : '2');
  }

  @override
  void dispose() {
    _partNumberCtrl.dispose();
    _descriptionCtrl.dispose();
    _costCtrl.dispose();
    _sellPriceCtrl.dispose();
    _stockQtyCtrl.dispose();
    _lowStockCtrl.dispose();
    super.dispose();
  }

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
        cost: cost,
        sellPrice: sellPrice,
        stockQty: stockQty,
        lowStockThreshold: lowStock,
      ));
    } else {
      await db.insertPart(InventoryPartsCompanion(
        partNumber: Value(partNumber.isEmpty ? null : partNumber),
        description: Value(description),
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

  @override
  Widget build(BuildContext context) {
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
            _field(
              label: 'Cost (what you paid)',
              controller: _costCtrl,
              placeholder: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            _field(
              label: 'Sell Price (what you charge)',
              controller: _sellPriceCtrl,
              placeholder: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
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

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'estimates_provider.dart';
import '../vendors/vendors_provider.dart' show vendorsProvider;

// The form for adding a labor or parts line to an estimate.
// type: 'labor' | 'part'
class LineItemFormScreen extends ConsumerStatefulWidget {
  final int estimateId;
  final String type; // 'labor' or 'part'
  final EstimateLineItem? lineItem; // non-null = editing existing

  const LineItemFormScreen({
    super.key,
    required this.estimateId,
    required this.type,
    this.lineItem,
  });

  @override
  ConsumerState<LineItemFormScreen> createState() =>
      _LineItemFormScreenState();
}

class _LineItemFormScreenState extends ConsumerState<LineItemFormScreen> {
  late final TextEditingController _description;
  late final TextEditingController _quantity;
  late final TextEditingController _unitPrice;
  bool _saving = false;
  int? _vendorId;
  String? _vendorName;

  bool get _isLabor => widget.type == 'labor';
  bool get _isEditing => widget.lineItem != null;

  // Formats a double cleanly: 2.0 → "2", 2.5 → "2.5"
  String _qtyStr(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);

  @override
  void initState() {
    super.initState();
    final li = widget.lineItem;
    if (li != null) {
      // Pre-fill all fields from the existing line item
      _description = TextEditingController(text: li.description);
      _quantity = TextEditingController(text: _qtyStr(li.quantity));
      _unitPrice = TextEditingController(
          text: li.unitPrice.toStringAsFixed(2));
      _vendorId = li.vendorId;
      if (li.vendorId != null) _loadVendorName(li.vendorId!);
    } else {
      _description = TextEditingController();
      _quantity = TextEditingController(text: '1');
      _unitPrice = TextEditingController();
      if (_isLabor) _loadDefaultLaborRate();
    }
  }

  Future<void> _loadVendorName(int vendorId) async {
    final vendor = await ref.read(dbProvider).getVendor(vendorId);
    if (mounted && vendor != null) {
      setState(() => _vendorName = vendor.name);
    }
  }

  Future<void> _pickVendor() async {
    final vendors = ref.read(vendorsProvider).value ?? [];
    if (vendors.isEmpty) {
      // No vendors yet — take them straight to the new vendor form.
      context.push('/repair-orders/vendors/new');
      return;
    }
    final picked = await showCupertinoModalPopup<Vendor>(
      context: context,
      builder: (_) => _VendorPickerSheet(vendors: vendors),
    );
    if (picked != null) {
      setState(() {
        _vendorId = picked.id;
        _vendorName = picked.name;
      });
    }
  }

  Future<void> _loadDefaultLaborRate() async {
    final db = ref.read(dbProvider);
    final settings = await db.getOrCreateSettings();
    if (mounted && _unitPrice.text.isEmpty) {
      _unitPrice.text = settings.defaultLaborRate.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final desc = _description.text.trim();
    final qty = double.tryParse(_quantity.text.replaceAll(',', ''));
    final price = double.tryParse(_unitPrice.text.replaceAll(',', ''));

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
    if (price == null || price < 0) {
      _showError('Please enter a valid price.');
      return;
    }

    setState(() => _saving = true);
    final db = ref.read(dbProvider);
    if (_isEditing) {
      await db.updateLineItem(widget.lineItem!.copyWith(
        description: desc,
        quantity: qty,
        unitPrice: price,
        vendorId: Value(_vendorId),
      ));
    } else {
      await db.insertLineItem(EstimateLineItemsCompanion.insert(
        estimateId: widget.estimateId,
        type: widget.type,
        description: desc,
        quantity: Value(qty),
        unitPrice: price,
        vendorId: Value(_vendorId),
      ));
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
  Widget build(BuildContext context) {
    final title = _isEditing
        ? (_isLabor ? 'Edit Labor' : 'Edit Part')
        : (_isLabor ? 'Add Labor' : 'Add Part');

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
            // Section label changes based on type
            _sectionHeader(_isLabor ? 'LABOR' : 'PART'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _Field(
                    label: 'Description',
                    controller: _description,
                    placeholder: _isLabor
                        ? 'e.g. Brake pad replacement'
                        : 'e.g. Brake Pads (front)',
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                  ),
                  _divider(),
                  _Field(
                    label: _isLabor ? 'Hours' : 'Qty',
                    controller: _quantity,
                    placeholder: _isLabor ? '2.5' : '1',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  _divider(),
                  _Field(
                    label: _isLabor ? 'Rate/hr' : 'Unit \$',
                    controller: _unitPrice,
                    placeholder: _isLabor ? '120.00' : '45.00',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  // Vendor picker — parts only
                  if (!_isLabor) ...[
                    _divider(),
                    _VendorPickerRow(
                      selectedName: _vendorName,
                      onTap: () => _pickVendor(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Live preview of the line total
            _LinePreview(
              isLabor: _isLabor,
              quantityController: _quantity,
              priceController: _unitPrice,
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

// A single labeled text field row.
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const _Field({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofocus = false,
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
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormatters,
              autofocus: autofocus,
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

// Shows a live "Line total: $X.XX" preview that updates as the user types.
class _LinePreview extends StatefulWidget {
  final bool isLabor;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  const _LinePreview({
    required this.isLabor,
    required this.quantityController,
    required this.priceController,
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
  }

  @override
  void dispose() {
    widget.quantityController.removeListener(_rebuild);
    widget.priceController.removeListener(_rebuild);
    super.dispose();
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

    final lineTotal = qty * price;
    final label = widget.isLabor
        ? '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} hr × \$${price.toStringAsFixed(2)}/hr'
        : '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} × \$${price.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          Text(
            '= \$${lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
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

// ─── Vendor Picker Sheet ──────────────────────────────────────────────────────
class _VendorPickerSheet extends StatelessWidget {
  final List<Vendor> vendors;
  const _VendorPickerSheet({required this.vendors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
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
          Container(height: 0.5, color: const Color(0xFFE5E5EA)),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: vendors.length,
              separatorBuilder: (_, __) => Container(
                height: 0.5,
                color: const Color(0xFFE5E5EA),
                margin: const EdgeInsets.only(left: 16),
              ),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => Navigator.pop(context, vendors[i]),
                child: Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendors[i].name,
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF1C1C1E))),
                      if (vendors[i].contactName != null)
                        Text(vendors[i].contactName!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8E8E93))),
                      if (vendors[i].accountNumber != null)
                        Text('Acct: ${vendors[i].accountNumber}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF8E8E93))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

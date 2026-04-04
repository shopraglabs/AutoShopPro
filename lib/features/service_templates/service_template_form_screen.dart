import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart' show dbProvider;

// Form screen for creating or editing a service template.
class ServiceTemplateFormScreen extends ConsumerStatefulWidget {
  final ServiceTemplate? template; // non-null = editing existing

  const ServiceTemplateFormScreen({super.key, this.template});

  @override
  ConsumerState<ServiceTemplateFormScreen> createState() =>
      _ServiceTemplateFormScreenState();
}

// A linked part row — held in local state until Save is tapped.
// qtyController holds the default quantity for this part in the template.
typedef _LinkedPart = ({
  int inventoryPartId,
  String description,
  String? partNumber,
  String? category,
  TextEditingController qtyController,
});

class _ServiceTemplateFormScreenState
    extends ConsumerState<ServiceTemplateFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _laborDesc;
  late final TextEditingController _hours;
  late final TextEditingController _rate;
  late final TextEditingController _total;
  bool _saving = false;
  int? _defaultRate; // stored as int cents, same as DB
  bool _syncing = false;

  // Linked parts — managed locally, written to DB on Save.
  final List<_LinkedPart> _linkedParts = [];

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _name = TextEditingController(text: t?.name ?? '');
    _laborDesc = TextEditingController(text: t?.laborDescription ?? '');
    _hours = TextEditingController(
        text: t != null ? _fmtNum(t.defaultHours) : '1');
    // defaultRate is int cents — convert to dollars for display
    _rate = TextEditingController(
        text: t?.defaultRate != null
            ? fromCents(t!.defaultRate!).toStringAsFixed(2)
            : '');
    _total = TextEditingController();

    if (t != null && t.defaultRate != null) {
      final rateDollars = fromCents(t.defaultRate!);
      final tot = t.defaultHours * rateDollars;
      _total.text = tot % 1 == 0 ? tot.toInt().toString() : tot.toStringAsFixed(2);
    }

    _hours.addListener(_onHoursOrRateChanged);
    _rate.addListener(_onHoursOrRateChanged);
    _total.addListener(_onTotalChanged);
    _loadDefaultRate();

    // Load existing linked parts when editing.
    if (_isEditing) _loadLinkedParts();
  }

  Future<void> _loadDefaultRate() async {
    final settings = await ref.read(dbProvider).getOrCreateSettings();
    if (!mounted) return;
    setState(() => _defaultRate = settings.defaultLaborRate); // int cents
    if (_rate.text.isEmpty) {
      // Convert int cents to dollars for display
      _rate.text = fromCents(settings.defaultLaborRate).toStringAsFixed(2);
    }
  }

  Future<void> _loadLinkedParts() async {
    final db = ref.read(dbProvider);
    final links = await db.getTemplatePartsForTemplate(widget.template!.id);
    final rows = <_LinkedPart>[];
    for (final link in links) {
      final part = await db.getPart(link.inventoryPartId);
      if (part != null) {
        // Show qty as integer if it's a whole number, e.g. "5" not "5.0"
        final qtyText = link.quantity % 1 == 0
            ? link.quantity.toInt().toString()
            : link.quantity.toStringAsFixed(1);
        rows.add((
          inventoryPartId: link.inventoryPartId,
          description: part.description,
          partNumber: part.partNumber,
          category: part.category,
          qtyController: TextEditingController(text: qtyText),
        ));
      }
    }
    if (mounted) setState(() { _linkedParts.addAll(rows); });
  }

  @override
  void dispose() {
    _name.dispose();
    _laborDesc.dispose();
    _hours.dispose();
    _rate.dispose();
    _total.dispose();
    for (final p in _linkedParts) p.qtyController.dispose();
    super.dispose();
  }

  String _fmtNum(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  void _onHoursOrRateChanged() {
    if (_syncing) return;
    final hrs = double.tryParse(_hours.text);
    final rate = double.tryParse(_rate.text);
    if (hrs == null || rate == null || hrs <= 0) return;
    final tot = hrs * rate;
    final totStr = tot % 1 == 0 ? tot.toInt().toString() : tot.toStringAsFixed(2);
    if (_total.text != totStr) {
      _syncing = true;
      _total.text = totStr;
      _syncing = false;
    }
  }

  void _onTotalChanged() {
    if (_syncing) return;
    final hrs = double.tryParse(_hours.text);
    final tot = double.tryParse(_total.text);
    if (hrs == null || tot == null || hrs <= 0) return;
    final rate = tot / hrs;
    final rateStr = rate.toStringAsFixed(2);
    if (_rate.text != rateStr) {
      _syncing = true;
      _rate.text = rateStr;
      _syncing = false;
    }
  }

  // Shows inventory picker, then adds the chosen part to the linked list.
  Future<void> _addLinkedPart() async {
    final db = ref.read(dbProvider);
    final allParts = await db.watchAllParts().first;
    if (!mounted) return;

    final picked = await showCupertinoModalPopup<InventoryPart>(
      context: context,
      builder: (_) => _PartPickerSheet(
        parts: allParts,
        alreadyLinked: _linkedParts.map((l) => l.inventoryPartId).toSet(),
        onCreateNew: () => context.push('/parts/new'),
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _linkedParts.add((
        inventoryPartId: picked.id,
        description: picked.description,
        partNumber: picked.partNumber,
        category: picked.category,
        qtyController: TextEditingController(text: '1'),
      ));
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final laborDesc = _laborDesc.text.trim();
    final hours = double.tryParse(_hours.text);

    if (name.isEmpty) { _err('Please enter a template name.'); return; }
    if (laborDesc.isEmpty) { _err('Please enter a labor line description.'); return; }
    if (hours == null || hours <= 0) { _err('Please enter a valid number of hours.'); return; }

    // Rate is entered as dollars — convert to int cents for the DB
    final rateDollars = double.tryParse(_rate.text);
    final rateCents = rateDollars != null ? toCents(rateDollars) : null;
    setState(() => _saving = true);
    final db = ref.read(dbProvider);

    try {
      int templateId;
      if (_isEditing) {
        await db.updateServiceTemplate(widget.template!.copyWith(
          name: name,
          laborDescription: laborDesc,
          defaultHours: hours,
          defaultRate: Value(rateCents),
        ));
        templateId = widget.template!.id;
        // Replace all linked parts.
        await db.deleteAllTemplatePartsForTemplate(templateId);
      } else {
        templateId = await db.insertServiceTemplate(ServiceTemplatesCompanion.insert(
          name: name,
          laborDescription: laborDesc,
          defaultHours: Value(hours),
          defaultRate: Value(rateCents),
        ));
      }

      // Write linked parts with their default quantities.
      for (final p in _linkedParts) {
        final qty = double.tryParse(p.qtyController.text.replaceAll(',', '')) ?? 1.0;
        await db.insertTemplatePart(ServiceTemplatePartsCompanion(
          templateId: Value(templateId),
          inventoryPartId: Value(p.inventoryPartId),
          quantity: Value(qty > 0 ? qty : 1.0),
        ));
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _err('Could not save template. Please try again.');
      }
    }
  }

  void _err(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (d) => CupertinoAlertDialog(
        title: const Text('Missing info'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(d),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Template' : 'New Template'),
        trailing: _saving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _save,
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            // ── Template ──────────────────────────────────────────────────
            _sectionHeader('TEMPLATE'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _field(label: 'Name', controller: _name, placeholder: 'e.g. Oil Change'),
                  _divider(),
                  _field(label: 'Labor Line', controller: _laborDesc,
                      placeholder: 'e.g. Oil and Filter Change'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Defaults ──────────────────────────────────────────────────
            _sectionHeader('DEFAULTS'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _field(
                    label: 'Hours',
                    controller: _hours,
                    placeholder: '1.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  ),
                  _divider(),
                  _field(
                    label: 'Rate/hr',
                    controller: _rate,
                    placeholder: '0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    prefix: '\$',
                  ),
                  _divider(),
                  _field(
                    label: 'Total',
                    controller: _total,
                    placeholder: '—',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    prefix: '\$',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: const Text(
                'Leave Rate blank to use the shop default labor rate.',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
            ),
            const SizedBox(height: 20),
            // ── Linked Parts ──────────────────────────────────────────────
            _sectionHeader('LINKED PARTS'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  for (int i = 0; i < _linkedParts.length; i++) ...[
                    _LinkedPartRow(
                      part: _linkedParts[i],
                      onRemove: () => setState(() {
                        _linkedParts[i].qtyController.dispose();
                        _linkedParts.removeAt(i);
                      }),
                    ),
                    Container(
                      height: 0.5,
                      color: const Color(0xFFE5E5EA),
                      margin: const EdgeInsets.only(left: 16),
                    ),
                  ],
                  // Add Part row
                  GestureDetector(
                    onTap: _addLinkedPart,
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.plus_circle_fill,
                              size: 18, color: Color(0xFF007AFF)),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Add Part or Fluid',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF007AFF))),
                          ),
                          const Icon(CupertinoIcons.chevron_right,
                              size: 16, color: Color(0xFFC7C7CC)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: const Text(
                'Linked parts appear as options when this template is applied to an estimate. Set a default quantity here — it can be adjusted at that time.',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            )),
      );

  Widget _divider() => Container(
        height: 0.5,
        color: const Color(0xFFE5E5EA),
        margin: const EdgeInsets.only(left: 110),
      );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
  }) {
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E))),
          ),
          if (prefix != null)
            Text(prefix,
                style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93))),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onTap: keyboardType != null
                  ? () => controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controller.text.length,
                      )
                  : null,
              contextMenuBuilder: (context, editableTextState) =>
                  CupertinoAdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState),
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
              placeholderStyle:
                  const TextStyle(fontSize: 16, color: Color(0xFFC7C7CC)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Linked Part Row ──────────────────────────────────────────────────────────
class _LinkedPartRow extends StatelessWidget {
  final _LinkedPart part;
  final VoidCallback onRemove;

  const _LinkedPartRow({required this.part, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Minus button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: onRemove,
            child: const Icon(CupertinoIcons.minus_circle_fill,
                size: 20, color: CupertinoColors.destructiveRed),
          ),
          const SizedBox(width: 10),
          // Description + part number / category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.description,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF1C1C1E))),
                if (part.partNumber?.isNotEmpty == true ||
                    part.category != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (part.partNumber?.isNotEmpty == true)
                        part.partNumber!,
                      if (part.category != null) part.category!,
                    ].join(' · '),
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF8E8E93)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Default qty field
          SizedBox(
            width: 52,
            child: CupertinoTextField(
              controller: part.qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              placeholder: 'Qty',
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              style: const TextStyle(fontSize: 14),
              onTap: () => part.qtyController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: part.qtyController.text.length,
              ),
              contextMenuBuilder: (ctx, state) =>
                  CupertinoAdaptiveTextSelectionToolbar.editableText(
                editableTextState: state,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Part Picker Sheet ────────────────────────────────────────────────────────
class _PartPickerSheet extends StatefulWidget {
  final List<InventoryPart> parts;
  final Set<int> alreadyLinked;
  final VoidCallback? onCreateNew;

  const _PartPickerSheet({
    required this.parts,
    required this.alreadyLinked,
    this.onCreateNew,
  });

  @override
  State<_PartPickerSheet> createState() => _PartPickerSheetState();
}

class _PartPickerSheetState extends State<_PartPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.parts
        .where((p) =>
            !widget.alreadyLinked.contains(p.id) &&
            (p.description.toLowerCase().contains(_search.toLowerCase()) ||
                (p.partNumber?.toLowerCase().contains(_search.toLowerCase()) ??
                    false)))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Handle bar
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Part or Fluid',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E))),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: CupertinoSearchTextField(
              autofocus: true,
              placeholder: 'Search inventory…',
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.isEmpty ? 1 : filtered.length + 1,
              separatorBuilder: (_, __) => Container(
                height: 0.5,
                color: const Color(0xFFE5E5EA),
                margin: const EdgeInsets.only(left: 16),
              ),
              itemBuilder: (_, i) {
                // First row: create new part
                if (i == 0) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onCreateNew?.call();
                    },
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.plus_circle_fill,
                              size: 18, color: Color(0xFF007AFF)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('New Part or Fluid',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF007AFF))),
                          ),
                          Icon(CupertinoIcons.chevron_right,
                              size: 16, color: Color(0xFFC7C7CC)),
                        ],
                      ),
                    ),
                  );
                }
                if (filtered.isEmpty) return const SizedBox.shrink();
                final p = filtered[i - 1];
                      final cat = p.category;
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, p),
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.description,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1C1C1E))),
                                    if (p.partNumber?.isNotEmpty == true)
                                      Text(p.partNumber!,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF8E8E93))),
                                  ],
                                ),
                              ),
                              if (cat != null && cat != 'Part') ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF)
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(cat,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF007AFF),
                                          fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(width: 8),
                              ],
                              const Icon(CupertinoIcons.chevron_right,
                                  size: 16, color: Color(0xFFC7C7CC)),
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

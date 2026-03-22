import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart' show dbProvider;

// Form screen for creating or editing a service template.
// A template has a name (e.g. "Oil Change"), a labor description
// (e.g. "Oil and Filter Change"), default hours, and an optional rate.
class ServiceTemplateFormScreen extends ConsumerStatefulWidget {
  final ServiceTemplate? template; // non-null = editing existing

  const ServiceTemplateFormScreen({super.key, this.template});

  @override
  ConsumerState<ServiceTemplateFormScreen> createState() =>
      _ServiceTemplateFormScreenState();
}

class _ServiceTemplateFormScreenState
    extends ConsumerState<ServiceTemplateFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _laborDesc;
  late final TextEditingController _hours;
  late final TextEditingController _rate;
  bool _saving = false;
  double? _defaultRate; // loaded from shop settings, shown as placeholder

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _name = TextEditingController(text: t?.name ?? '');
    _laborDesc = TextEditingController(text: t?.laborDescription ?? '');
    _hours = TextEditingController(
        text: t != null ? _fmtNum(t.defaultHours) : '1');
    _rate = TextEditingController(
        text: t?.defaultRate != null
            ? t!.defaultRate!.toStringAsFixed(2)
            : '');
    _loadDefaultRate();
  }

  Future<void> _loadDefaultRate() async {
    final settings = await ref.read(dbProvider).getOrCreateSettings();
    if (mounted) setState(() => _defaultRate = settings.defaultLaborRate);
  }

  @override
  void dispose() {
    _name.dispose();
    _laborDesc.dispose();
    _hours.dispose();
    _rate.dispose();
    super.dispose();
  }

  String _fmtNum(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  Future<void> _save() async {
    final name = _name.text.trim();
    final laborDesc = _laborDesc.text.trim();
    final hours = double.tryParse(_hours.text);

    if (name.isEmpty) {
      _err('Please enter a template name.');
      return;
    }
    if (laborDesc.isEmpty) {
      _err('Please enter a labor line description.');
      return;
    }
    if (hours == null || hours <= 0) {
      _err('Please enter a valid number of hours.');
      return;
    }

    final rate = double.tryParse(_rate.text);
    setState(() => _saving = true);
    final db = ref.read(dbProvider);

    if (_isEditing) {
      await db.updateServiceTemplate(widget.template!.copyWith(
        name: name,
        laborDescription: laborDesc,
        defaultHours: hours,
        defaultRate: Value(rate),
      ));
    } else {
      await db.insertServiceTemplate(ServiceTemplatesCompanion.insert(
        name: name,
        laborDescription: laborDesc,
        defaultHours: Value(hours),
        defaultRate: Value(rate),
      ));
    }
    if (mounted) Navigator.pop(context);
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
            // ── Template Name ─────────────────────────────────────────────
            _sectionHeader('TEMPLATE'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _field(
                    label: 'Name',
                    controller: _name,
                    placeholder: 'e.g. Oil Change',
                  ),
                  _divider(),
                  _field(
                    label: 'Labor Line',
                    controller: _laborDesc,
                    placeholder: 'e.g. Oil and Filter Change',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Defaults ─────────────────────────────────────────────────
            _sectionHeader('DEFAULTS'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _field(
                    label: 'Hours',
                    controller: _hours,
                    placeholder: '1.0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  _divider(),
                  _field(
                    label: 'Rate/hr',
                    controller: _rate,
                    placeholder: _defaultRate != null
                        ? _defaultRate!.toStringAsFixed(2)
                        : '…',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')),
                    ],
                    prefix: '\$',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                'Leave Rate blank to use the shop default labor rate.',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF8E8E93)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
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
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF1C1C1E))),
          ),
          if (prefix != null)
            Text(prefix,
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF8E8E93))),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              contextMenuBuilder: (context, editableTextState) =>
                  CupertinoAdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState),
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

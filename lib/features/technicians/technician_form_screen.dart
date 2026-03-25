import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'technicians_provider.dart';

class TechnicianFormScreen extends ConsumerStatefulWidget {
  final Technician? technician; // null = new, non-null = editing

  const TechnicianFormScreen({super.key, this.technician});

  @override
  ConsumerState<TechnicianFormScreen> createState() =>
      _TechnicianFormScreenState();
}

class _TechnicianFormScreenState extends ConsumerState<TechnicianFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _specialty;
  late final TextEditingController _phone;
  bool _saving = false;

  bool get _isEditing => widget.technician != null;

  @override
  void initState() {
    super.initState();
    final t = widget.technician;
    _name = TextEditingController(text: t?.name ?? '');
    _specialty = TextEditingController(text: t?.specialty ?? '');
    _phone = TextEditingController(text: t?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _confirmArchive(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text('Archive ${widget.technician!.name}?'),
        content: const Text(
            'Archived technicians are hidden from lists and pickers but existing repair orders that reference them are preserved.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref
                  .read(dbProvider)
                  .archiveTechnician(widget.technician!.id);
              if (mounted) context.pop();
            },
            child: const Text('Archive'),
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

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Name required'),
          content: const Text('Please enter the technician\'s name.'),
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
    setState(() => _saving = true);
    final db = ref.read(dbProvider);
    String? blankToNull(String s) => s.trim().isEmpty ? null : s.trim();

    if (_isEditing) {
      await db.updateTechnician(widget.technician!.copyWith(
        name: _name.text.trim(),
        specialty: Value(blankToNull(_specialty.text)),
        phone: Value(blankToNull(_phone.text)),
      ));
    } else {
      await db.insertTechnician(TechniciansCompanion.insert(
        name: _name.text.trim(),
        specialty: Value(blankToNull(_specialty.text)),
        phone: Value(blankToNull(_phone.text)),
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Technician' : 'New Technician'),
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
            _sectionHeader('TECHNICIAN'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _field(
                    label: 'Name',
                    controller: _name,
                    placeholder: 'e.g. Mike Johnson',
                    capitalization: TextCapitalization.words,
                    autofocus: true,
                  ),
                  _divider(),
                  _field(
                    label: 'Specialty',
                    controller: _specialty,
                    placeholder: 'e.g. Brakes, Engine, Electrical',
                    capitalization: TextCapitalization.words,
                  ),
                  _divider(),
                  _field(
                    label: 'Phone',
                    controller: _phone,
                    placeholder: '(555) 867-5309',
                    keyboard: TextInputType.phone,
                    formatters: [_PhoneFormatter()],
                  ),
                ],
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 36),
              Center(
                child: CupertinoButton(
                  onPressed: () => _confirmArchive(context),
                  child: const Text(
                    'Archive Technician',
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    bool autofocus = false,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF1C1C1E))),
            ),
            Expanded(
              child: CupertinoTextField.borderless(
                controller: controller,
                placeholder: placeholder,
                keyboardType: keyboard,
                textCapitalization: capitalization,
                inputFormatters: formatters,
                autofocus: autofocus,
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF1C1C1E)),
                placeholderStyle: const TextStyle(
                    fontSize: 16, color: Color(0xFFC7C7CC)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                contextMenuBuilder: (context, editableTextState) =>
                    CupertinoAdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState,
                    ),
              ),
            ),
          ],
        ),
      );
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 10; i++) {
      if (i == 0) buf.write('(');
      if (i == 3) buf.write(') ');
      if (i == 6) buf.write('-');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

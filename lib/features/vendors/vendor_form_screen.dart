import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'vendors_provider.dart';

class VendorFormScreen extends ConsumerStatefulWidget {
  final Vendor? vendor; // null = new, non-null = editing

  const VendorFormScreen({super.key, this.vendor});

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _contactName;
  late final TextEditingController _phone;
  late final TextEditingController _accountNumber;
  bool _saving = false;

  bool get _isEditing => widget.vendor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vendor;
    _name = TextEditingController(text: v?.name ?? '');
    _contactName = TextEditingController(text: v?.contactName ?? '');
    _phone = TextEditingController(text: v?.phone ?? '');
    _accountNumber = TextEditingController(text: v?.accountNumber ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _contactName.dispose();
    _phone.dispose();
    _accountNumber.dispose();
    super.dispose();
  }

  Future<void> _confirmArchive(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text('Archive ${widget.vendor!.name}?'),
        content: const Text(
            'Archived vendors are hidden from lists and pickers but existing records that reference them are preserved.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).archiveVendor(widget.vendor!.id);
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
          content: const Text('Please enter the vendor name.'),
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
      await db.updateVendor(widget.vendor!.copyWith(
        name: _name.text.trim(),
        contactName: Value(blankToNull(_contactName.text)),
        phone: Value(blankToNull(_phone.text)),
        accountNumber: Value(blankToNull(_accountNumber.text)),
      ));
    } else {
      await db.insertVendor(VendorsCompanion.insert(
        name: _name.text.trim(),
        contactName: Value(blankToNull(_contactName.text)),
        phone: Value(blankToNull(_phone.text)),
        accountNumber: Value(blankToNull(_accountNumber.text)),
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Vendor' : 'New Vendor'),
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
            _sectionHeader('VENDOR'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  _field(
                    label: 'Name',
                    controller: _name,
                    placeholder: 'e.g. NAPA Auto Parts',
                    capitalization: TextCapitalization.words,
                    autofocus: true,
                  ),
                  _divider(),
                  _field(
                    label: 'Contact',
                    controller: _contactName,
                    placeholder: 'e.g. John Smith',
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
                  _divider(),
                  _field(
                    label: 'Account #',
                    controller: _accountNumber,
                    placeholder: 'Your account number',
                    formatters: [_UpperCaseFormatter()],
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
                    'Archive Vendor',
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

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
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

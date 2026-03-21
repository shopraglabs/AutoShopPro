import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'customers_provider.dart';

// The form used for both "New Customer" and "Edit Customer".
// Pass a Customer object to edit an existing one, or leave it null to create
// a brand-new customer.
class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  bool _saving = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();

    if (name.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Name required'),
          content: const Text('Please enter the customer\'s name.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
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
      await db.updateCustomer(widget.customer!.copyWith(
        name: name,
        phone: Value(blankToNull(_phone.text)),
        email: Value(blankToNull(_email.text)),
      ));
    } else {
      final newId = await db.insertCustomer(CustomersCompanion.insert(
        name: name,
        phone: Value(blankToNull(_phone.text)),
        email: Value(blankToNull(_email.text)),
      ));
      if (mounted) context.go('/repair-orders/customers/$newId');
      return;
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Customer' : 'New Customer'),
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
            _FormSection(
              label: 'CONTACT INFO',
              children: [
                _FormField(
                  label: 'Name',
                  controller: _name,
                  placeholder: 'Full name',
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [_CapitalizeWordsFormatter()],
                  autofocus: true,
                ),
                _FormField(
                  label: 'Phone',
                  controller: _phone,
                  placeholder: '(555) 867-5309',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_PhoneFormatter()],
                ),
                _FormField(
                  label: 'Email',
                  controller: _email,
                  placeholder: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FormSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
        ),
        Container(
          color: CupertinoColors.white,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 104),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const _FormField({
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
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
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
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
              placeholderStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFFC7C7CC),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Capitalizes the first letter of every word as the user types.
class _CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final buf = StringBuffer();
    bool capNext = true;
    for (final ch in text.characters) {
      if (ch == ' ') {
        capNext = true;
        buf.write(ch);
      } else if (capNext) {
        buf.write(ch.toUpperCase());
        capNext = false;
      } else {
        buf.write(ch);
      }
    }
    return newValue.copyWith(text: buf.toString());
  }
}

// Formats a phone number as (XXX) XXX-XXXX while the user types.
// Strips any non-digit characters first, then rebuilds the formatted string.
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

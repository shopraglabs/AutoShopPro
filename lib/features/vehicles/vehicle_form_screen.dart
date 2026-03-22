import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';
import 'vin_service.dart';

// Formats an integer mileage value as "45,000" for display in the field.
String _formatMileage(int? mileage) {
  if (mileage == null) return '';
  return mileage.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

// Formats a raw plate string: "ABC1234" → "ABC 1234".
// Only adds the space when the plate is purely letters then digits.
// Other formats (e.g. "1ABC234") are returned uppercased and unchanged.
String _formatPlate(String? plate) {
  if (plate == null || plate.isEmpty) return '';
  final raw = plate.replaceAll(' ', '').toUpperCase();
  final match = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(raw);
  if (match != null) return '${match.group(1)} ${match.group(2)}';
  return raw;
}

// The form used for both "New Vehicle" and "Edit Vehicle".
class VehicleFormScreen extends ConsumerStatefulWidget {
  final int customerId;
  final Vehicle? vehicle;

  const VehicleFormScreen({
    super.key,
    required this.customerId,
    this.vehicle,
  });

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  late final TextEditingController _year;
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _vin;
  late final TextEditingController _mileage;
  late final TextEditingController _plate;
  bool _saving = false;
  bool _decoding = false;
  String? _vinMessage; // shown below the DETAILS section

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _year = TextEditingController(text: v?.year?.toString() ?? '');
    _make = TextEditingController(text: v?.make ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _vin = TextEditingController(text: v?.vin ?? '');
    // Pre-fill mileage and plate with their formatted versions
    _mileage = TextEditingController(text: _formatMileage(v?.mileage));
    _plate = TextEditingController(text: _formatPlate(v?.licensePlate));

    _vin.addListener(_onVinChanged);
  }

  void _onVinChanged() {
    final vin = _vin.text.trim();
    if (vin.length == 17 && !_decoding) {
      _decodeVin(vin);
    }
  }

  Future<void> _decodeVin(String vin) async {
    setState(() {
      _decoding = true;
      _vinMessage = null;
    });
    final result = await VinService.decode(vin);
    if (!mounted) return;
    if (result != null) {
      // Only fill a field if it's currently empty — don't overwrite user input
      if (_year.text.trim().isEmpty && result.year != null) {
        _year.text = result.year!;
      }
      if (_make.text.trim().isEmpty && result.make != null) {
        _make.text = _toTitleCase(result.make!);
      }
      if (_model.text.trim().isEmpty && result.model != null) {
        _model.text = _toTitleCase(result.model!);
      }
      setState(() {
        _decoding = false;
        _vinMessage = null;
      });
    } else {
      setState(() {
        _decoding = false;
        _vinMessage = 'VIN not recognized — enter details manually';
      });
    }
  }

  String _toTitleCase(String s) {
    return s.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  void dispose() {
    _vin.removeListener(_onVinChanged);
    _year.dispose();
    _make.dispose();
    _model.dispose();
    _vin.dispose();
    _mileage.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_make.text.trim().isEmpty && _model.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Vehicle info required'),
          content: const Text('Please enter at least a make or model.'),
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
    // Strip commas before parsing so "45,000" → 45000
    int? parseInt(String s) =>
        int.tryParse(s.replaceAll(',', '').trim());
    // If no plate was entered, record "NO PLATE" so it's explicit — not just empty
    final plateValue = _plate.text.trim().isEmpty ? 'NO PLATE' : _plate.text.trim();

    if (_isEditing) {
      await db.updateVehicle(widget.vehicle!.copyWith(
        year: Value(parseInt(_year.text)),
        make: Value(blankToNull(_make.text)),
        model: Value(blankToNull(_model.text)),
        vin: Value(blankToNull(_vin.text)),
        mileage: Value(parseInt(_mileage.text)),
        licensePlate: Value(plateValue),
      ));
    } else {
      await db.insertVehicle(VehiclesCompanion.insert(
        customerId: widget.customerId,
        year: Value(parseInt(_year.text)),
        make: Value(blankToNull(_make.text)),
        model: Value(blankToNull(_model.text)),
        vin: Value(blankToNull(_vin.text)),
        mileage: Value(parseInt(_mileage.text)),
        licensePlate: Value(plateValue),
      ));
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Vehicle' : 'New Vehicle'),
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
              label: 'VEHICLE',
              children: [
                _FormField(
                  label: 'Year',
                  controller: _year,
                  placeholder: '2018',
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                _FormField(
                  label: 'Make',
                  controller: _make,
                  placeholder: 'Toyota',
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [_CapitalizeWordsFormatter()],
                ),
                _FormField(
                  label: 'Model',
                  controller: _model,
                  placeholder: 'Camry',
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [_CapitalizeWordsFormatter()],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSection(
              label: 'DETAILS',
              children: [
                _FormField(
                  label: 'VIN',
                  controller: _vin,
                  placeholder: '1HGBH41JXMN109186',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_UpperCaseFormatter()],
                  trailing: _decoding
                      ? const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: CupertinoActivityIndicator(radius: 8),
                        )
                      : null,
                ),
                _FormField(
                  label: 'Mileage',
                  controller: _mileage,
                  placeholder: '45,000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_MileageFormatter()],
                ),
                _FormField(
                  label: 'Plate',
                  controller: _plate,
                  placeholder: 'ABC 1234',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_PlateFormatter()],
                ),
              ],
            ),
            if (_vinMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _vinMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
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
  final Widget? trailing;

  const _FormField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofocus = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 72,
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
          if (trailing != null) trailing!,
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

// Forces every character to uppercase (used for VIN).
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

// Adds thousands-separator commas to a number as the user types.
// "45000" → "45,000". Strips commas before re-inserting them.
class _MileageFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = _formatMileage(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Uppercases the plate and inserts a space between the letter group and
// digit group when the pattern matches (e.g. "ABC1234" → "ABC 1234").
class _PlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(' ', '').toUpperCase();
    final match = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(raw);
    final formatted = match != null
        ? '${match.group(1)} ${match.group(2)}'
        : raw;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

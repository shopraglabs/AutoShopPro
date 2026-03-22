import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';
import 'estimates_provider.dart' show dbProvider;

// ─── New Estimate Screen ──────────────────────────────────────────────────────
// The user picks a customer, optionally picks a vehicle from that customer,
// enters a customer complaint and an optional internal note, then saves.
class EstimateFormScreen extends ConsumerStatefulWidget {
  const EstimateFormScreen({super.key});

  @override
  ConsumerState<EstimateFormScreen> createState() =>
      _EstimateFormScreenState();
}

class _EstimateFormScreenState extends ConsumerState<EstimateFormScreen> {
  Customer? _customer;
  Vehicle? _vehicle;
  final _complaint = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _complaint.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_customer == null) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Customer required'),
          content: const Text('Please select a customer for this estimate.'),
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
    final settings = await db.getOrCreateSettings();
    final id = await db.insertEstimate(EstimatesCompanion.insert(
      customerId: _customer!.id,
      vehicleId: Value(_vehicle?.id),
      customerComplaint: Value(
          _complaint.text.trim().isEmpty ? null : _complaint.text.trim()),
      note: Value(_note.text.trim().isEmpty ? null : _note.text.trim()),
      taxRate: Value(settings.defaultTaxRate),
    ));
    if (mounted) {
      // Replace this screen with the estimate detail so Back goes to the list
      context.pushReplacement('/repair-orders/estimates/$id');
    }
  }

  // Opens a bottom sheet with a scrollable list of customers.
  // Always shows the picker — even if the list is empty, there's a "+ New" row.
  Future<void> _pickCustomer(List<Customer> customers) async {
    final picked = await showCupertinoModalPopup<Customer>(
      context: context,
      builder: (_) => _PickerSheet<Customer>(
        title: 'Select Customer',
        items: customers,
        labelFor: (c) => c.name,
        createNewLabel: 'New Customer',
        onCreateNew: () => context.push('/repair-orders/customers/new'),
      ),
    );
    if (picked != null && picked != _customer) {
      setState(() {
        _customer = picked;
        _vehicle = null; // reset vehicle when customer changes
      });
      // Auto-populate internal note from customer's stored note if field is empty
      if ((picked.internalNote ?? '').isNotEmpty && _note.text.trim().isEmpty) {
        _note.text = picked.internalNote!;
      }
    }
  }

  // Opens a bottom sheet with vehicles belonging to the selected customer.
  // Always shows the picker — even if empty, there's a "+ New Vehicle" row.
  Future<void> _pickVehicle(List<Vehicle> vehicles) async {
    final picked = await showCupertinoModalPopup<Vehicle>(
      context: context,
      builder: (_) => _PickerSheet<Vehicle>(
        title: 'Select Vehicle',
        items: vehicles,
        labelFor: (v) => [v.year?.toString(), v.make, v.model]
            .whereType<String>()
            .join(' '),
        sublabelFor: (v) => (v.licensePlate != null && v.licensePlate!.isNotEmpty)
            ? v.licensePlate
            : null,
        createNewLabel: 'New Vehicle',
        onCreateNew: () => context.push(
            '/repair-orders/customers/${_customer!.id}/vehicles/new'),
      ),
    );
    if (picked != null) setState(() => _vehicle = picked);
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final vehiclesAsync = _customer != null
        ? ref.watch(vehiclesProvider(_customer!.id))
        : null;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Estimate'),
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

            // ── Customer + Vehicle ─────────────────────────────────────────
            _SectionHeader(label: 'CUSTOMER'),
            Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  // Customer picker row
                  GestureDetector(
                    onTap: () {
                      final customers = customersAsync.value ?? [];
                      _pickCustomer(customers);
                    },
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 80,
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1C1C1E)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _customer?.name ?? 'Select…',
                              style: TextStyle(
                                fontSize: 16,
                                color: _customer != null
                                    ? const Color(0xFF1C1C1E)
                                    : const Color(0xFFC7C7CC),
                              ),
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: Color(0xFFC7C7CC),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.only(left: 96),
                  ),
                  // Vehicle picker row — grayed out until customer is chosen
                  GestureDetector(
                    onTap: _customer == null
                        ? null
                        : () {
                            final vehicles = vehiclesAsync?.value ?? [];
                            _pickVehicle(vehicles);
                          },
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              'Vehicle',
                              style: TextStyle(
                                fontSize: 16,
                                color: _customer != null
                                    ? const Color(0xFF1C1C1E)
                                    : const Color(0xFFAEAEB2),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _vehicle != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        [
                                          _vehicle!.year?.toString(),
                                          _vehicle!.make,
                                          _vehicle!.model
                                        ].whereType<String>().join(' '),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1C1C1E)),
                                      ),
                                      if (_vehicle!.licensePlate != null &&
                                          _vehicle!.licensePlate!.isNotEmpty)
                                        Text(
                                          _vehicle!.licensePlate!,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF8E8E93)),
                                        ),
                                    ],
                                  )
                                : Text(
                                    _customer != null
                                        ? 'Select…'
                                        : 'Select customer first',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFC7C7CC)),
                                  ),
                          ),
                          if (_customer != null)
                            const Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: Color(0xFFC7C7CC),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Customer Complaint ─────────────────────────────────────────
            _SectionHeader(label: 'CUSTOMER COMPLAINT'),
            Container(
              color: CupertinoColors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: CupertinoTextField.borderless(
                controller: _complaint,
                placeholder: 'e.g. Check engine light on, car shakes at highway speed',
                maxLines: 3,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                contextMenuBuilder: (context, editableTextState) {
                  return CupertinoAdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF1C1C1E)),
                placeholderStyle: const TextStyle(
                    fontSize: 16, color: Color(0xFFC7C7CC)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            // ── Internal Note ──────────────────────────────────────────────
            _SectionHeader(label: 'INTERNAL NOTE (OPTIONAL)'),
            Container(
              color: CupertinoColors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: CupertinoTextField.borderless(
                controller: _note,
                placeholder: 'e.g. Customer is a regular, has fleet account',
                maxLines: 3,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                contextMenuBuilder: (context, editableTextState) {
                  return CupertinoAdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
                style: const TextStyle(
                    fontSize: 16, color: Color(0xFF1C1C1E)),
                placeholderStyle: const TextStyle(
                    fontSize: 16, color: Color(0xFFC7C7CC)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
  }
}

// ─── Generic Picker Sheet ─────────────────────────────────────────────────────
// A scrollable bottom sheet that lets the user pick one item from a list.
// An optional "+ New …" row appears at the top when onCreateNew is provided.
class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelFor;
  // Optional secondary line shown in gray below the main label (e.g. plate number)
  final String? Function(T)? sublabelFor;
  final String? createNewLabel;
  final VoidCallback? onCreateNew;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.labelFor,
    this.sublabelFor,
    this.createNewLabel,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title + Cancel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
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

          // ── "+ New …" row (shown when onCreateNew is provided) ───────────
          if (onCreateNew != null) ...[
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // dismiss the sheet
                onCreateNew!(); // navigate to create form
              },
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.plus_circle_fill,
                        size: 18, color: Color(0xFF007AFF)),
                    const SizedBox(width: 10),
                    Text(
                      createNewLabel ?? 'Create New',
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF007AFF)),
                    ),
                  ],
                ),
              ),
            ),
            if (items.isNotEmpty)
              Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16)),
          ],

          // ── Scrollable list of items ──────────────────────────────────────
          if (items.isNotEmpty)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => Container(
                  height: 0.5,
                  color: const Color(0xFFE5E5EA),
                  margin: const EdgeInsets.only(left: 16),
                ),
                itemBuilder: (context, i) {
                  final sub = sublabelFor?.call(items[i]);
                  final showSub = sub != null && sub.isNotEmpty;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, items[i]),
                    child: Container(
                      color: CupertinoColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labelFor(items[i]),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          if (showSub)
                            Text(
                              sub!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                              ),
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

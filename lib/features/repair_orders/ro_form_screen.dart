import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'repair_orders_provider.dart';

// A simple form to edit the internal note and service date on a Repair Order.
// The customer, vehicle, and estimate are fixed once the RO is created.
class RoFormScreen extends ConsumerStatefulWidget {
  final RepairOrder ro;
  const RoFormScreen({super.key, required this.ro});

  @override
  ConsumerState<RoFormScreen> createState() => _RoFormScreenState();
}

class _RoFormScreenState extends ConsumerState<RoFormScreen> {
  late final TextEditingController _noteCtrl;
  late DateTime _serviceDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.ro.note ?? '');
    _serviceDate = widget.ro.serviceDate ?? widget.ro.createdAt;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(dbProvider);
    final trimmed = _noteCtrl.text.trim();
    await db.updateRepairOrder(
      widget.ro.copyWith(
        note: Value(trimmed.isEmpty ? null : trimmed),
        serviceDate: Value(_serviceDate),
      ),
    );
    if (mounted) context.pop();
  }

  void _pickDate() {
    DateTime picked = _serviceDate;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: () {
                    setState(() => _serviceDate = picked);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: picked,
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Repair Order'),
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

            // ── Service Date ───────────────────────────────────────────────
            _sectionHeader('SERVICE DATE'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        size: 18, color: Color(0xFF007AFF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _fmtDate(_serviceDate),
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF007AFF)),
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 16, color: Color(0xFFC7C7CC)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Internal Note ──────────────────────────────────────────────
            _sectionHeader('INTERNAL NOTE'),
            Container(
              color: CupertinoColors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CupertinoTextField(
                controller: _noteCtrl,
                placeholder: 'Notes visible only to shop staff...',
                maxLines: 6,
                minLines: 3,
                style:
                    const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
                placeholderStyle:
                    const TextStyle(fontSize: 15, color: Color(0xFFC7C7CC)),
                decoration: const BoxDecoration(),
                contextMenuBuilder: (ctx, editableTextState) =>
                    CupertinoAdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'This note is internal — customers do not see it.',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
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
}

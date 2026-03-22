import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'repair_orders_provider.dart';

// A simple form to edit the internal note on a Repair Order.
// The customer, vehicle, and estimate are fixed once the RO is created —
// only the note is editable here.
class RoFormScreen extends ConsumerStatefulWidget {
  final RepairOrder ro;
  const RoFormScreen({super.key, required this.ro});

  @override
  ConsumerState<RoFormScreen> createState() => _RoFormScreenState();
}

class _RoFormScreenState extends ConsumerState<RoFormScreen> {
  late final TextEditingController _noteCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.ro.note ?? '');
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
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit RO'),
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
            _sectionHeader('INTERNAL NOTE'),
            Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CupertinoTextField(
                controller: _noteCtrl,
                placeholder: 'Notes visible only to shop staff...',
                maxLines: 6,
                minLines: 3,
                autofocus: true,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'This note is internal — customers do not see it.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
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

import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';
import 'markup_rules_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _shopNameCtrl = TextEditingController();
  final _laborRateCtrl = TextEditingController();
  final _taxRateCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _laborRateCtrl.dispose();
    _taxRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(dbProvider).getOrCreateSettings();
    if (mounted) {
      setState(() {
        _shopNameCtrl.text = settings.shopName ?? '';
        _laborRateCtrl.text = settings.defaultLaborRate.toStringAsFixed(2);
        _taxRateCtrl.text = settings.defaultTaxRate.toStringAsFixed(1);
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(dbProvider);
    final settings = await db.getOrCreateSettings();
    final laborRate =
        double.tryParse(_laborRateCtrl.text) ?? settings.defaultLaborRate;
    final taxRate =
        double.tryParse(_taxRateCtrl.text) ?? settings.defaultTaxRate;
    final shopName = _shopNameCtrl.text.trim();

    await db.saveSettings(ShopSettingsCompanion(
      id: const Value(1),
      shopName: Value(shopName.isEmpty ? null : shopName),
      defaultLaborRate: Value(laborRate),
      defaultTaxRate: Value(taxRate),
    ));
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _showAddRuleDialog() => _showRuleDialog(existing: null);

  Future<void> _showRuleDialog({required MarkupRule? existing}) async {
    final minCtrl = TextEditingController(
        text: existing != null ? existing.minCost.toStringAsFixed(2) : '');
    final maxCtrl = TextEditingController(
        text: existing?.maxCost != null
            ? existing!.maxCost!.toStringAsFixed(2)
            : '');
    final pctCtrl = TextEditingController(
        text: existing != null
            ? existing.markupPercent.toStringAsFixed(1)
            : '');

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(existing == null ? 'Add Markup Rule' : 'Edit Markup Rule'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('From cost (\$)',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: minCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                placeholder: '0.00',
                contextMenuBuilder: (ctx, s) =>
                    CupertinoAdaptiveTextSelectionToolbar.editableText(
                        editableTextState: s),
              ),
              const SizedBox(height: 12),
              const Text('To cost (\$) — leave blank for no limit',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: maxCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                placeholder: 'No limit',
                contextMenuBuilder: (ctx, s) =>
                    CupertinoAdaptiveTextSelectionToolbar.editableText(
                        editableTextState: s),
              ),
              const SizedBox(height: 12),
              const Text('Markup %',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: pctCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                placeholder: '30.0',
                contextMenuBuilder: (ctx, s) =>
                    CupertinoAdaptiveTextSelectionToolbar.editableText(
                        editableTextState: s),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final min = double.tryParse(minCtrl.text);
              final max = double.tryParse(maxCtrl.text);
              final pct = double.tryParse(pctCtrl.text);
              if (min == null || pct == null) return;
              final db = ref.read(dbProvider);
              if (existing == null) {
                await db.insertMarkupRule(MarkupRulesCompanion(
                  minCost: Value(min),
                  maxCost: Value(max),
                  markupPercent: Value(pct),
                ));
              } else {
                await db.updateMarkupRule(existing.copyWith(
                  minCost: min,
                  maxCost: Value(max),
                  markupPercent: pct,
                ));
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _fieldRow({
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    String placeholder = '',
  }) {
    return Container(
      color: CupertinoColors.systemBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 16, color: CupertinoColors.label)),
          ),
          if (prefix != null)
            Text(prefix,
                style: const TextStyle(
                    fontSize: 16, color: CupertinoColors.secondaryLabel)),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: placeholder,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              padding: const EdgeInsets.symmetric(vertical: 13),
              onTap: () => controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              ),
              contextMenuBuilder: (ctx, s) =>
                  CupertinoAdaptiveTextSelectionToolbar.editableText(
                      editableTextState: s),
            ),
          ),
          if (suffix != null)
            Text(suffix,
                style: const TextStyle(
                    fontSize: 16, color: CupertinoColors.secondaryLabel)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(markupRulesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        trailing: _saving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _save,
                child: const Text('Save'),
              ),
      ),
      child: _loaded
          ? SafeArea(
              child: ListView(
                children: [
                  const SizedBox(height: 20),

                  // ── Shop Info ──────────────────────────────────────────────
                  _sectionHeader('SHOP INFO'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: Column(
                      children: [
                        Container(
                          color: CupertinoColors.systemBackground,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 140,
                                child: Text('Shop Name',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: CupertinoColors.label)),
                              ),
                              Expanded(
                                child: CupertinoTextField.borderless(
                                  controller: _shopNameCtrl,
                                  placeholder: 'My Auto Shop',
                                  textCapitalization:
                                      TextCapitalization.words,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  contextMenuBuilder: (ctx, s) =>
                                      CupertinoAdaptiveTextSelectionToolbar
                                          .editableText(
                                              editableTextState: s),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Labor ──────────────────────────────────────────────────
                  _sectionHeader('LABOR'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: _fieldRow(
                      label: 'Default Labor Rate',
                      controller: _laborRateCtrl,
                      prefix: '\$',
                      placeholder: '120.00',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Tax ────────────────────────────────────────────────────
                  _sectionHeader('TAX'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: _fieldRow(
                      label: 'Default Tax Rate',
                      controller: _taxRateCtrl,
                      suffix: '%',
                      placeholder: '0.0',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Parts Markup Rules ─────────────────────────────────────
                  _sectionHeader('PARTS MARKUP RULES'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: Column(
                      children: [
                        rulesAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: CupertinoActivityIndicator(),
                          ),
                          error: (e, _) => const SizedBox.shrink(),
                          data: (rules) {
                            if (rules.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Text(
                                  'No rules yet. Parts will use a 0% markup by default.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.secondaryLabel),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (int i = 0; i < rules.length; i++) ...[
                                  _MarkupRuleRow(
                                    rule: rules[i],
                                    onEdit: () => _showRuleDialog(existing: rules[i]),
                                    onDelete: () => ref
                                        .read(dbProvider)
                                        .deleteMarkupRule(rules[i].id),
                                  ),
                                  if (i < rules.length - 1)
                                    Container(
                                        height: 0.5,
                                        color: const Color(0xFFE5E5EA),
                                        margin: const EdgeInsets.only(
                                            left: 16)),
                                ],
                              ],
                            );
                          },
                        ),
                        // Divider before Add Rule
                        Container(
                            height: 0.5, color: const Color(0xFFE5E5EA)),
                        // + Add Rule row
                        GestureDetector(
                          onTap: _showAddRuleDialog,
                          child: Container(
                            color: CupertinoColors.systemBackground,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: const Row(
                              children: [
                                Icon(CupertinoIcons.plus_circle_fill,
                                    size: 18, color: Color(0xFF007AFF)),
                                SizedBox(width: 10),
                                Text('Add Rule',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF007AFF))),
                                Spacer(),
                                Icon(CupertinoIcons.chevron_right,
                                    size: 16, color: Color(0xFFC7C7CC)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Service Templates ──────────────────────────────────────
                  _sectionHeader('SERVICE TEMPLATES'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: GestureDetector(
                      onTap: () =>
                          context.push('/settings/service-templates'),
                      child: Container(
                        color: CupertinoColors.systemBackground,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.doc_text,
                                size: 18, color: Color(0xFF007AFF)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Manage Templates',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF))),
                            ),
                            Icon(CupertinoIcons.chevron_right,
                                size: 16, color: Color(0xFFC7C7CC)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            )
          : const Center(child: CupertinoActivityIndicator()),
    );
  }
}

// ─── Markup Rule Row ──────────────────────────────────────────────────────────
class _MarkupRuleRow extends StatelessWidget {
  final MarkupRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MarkupRuleRow({required this.rule, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final from = '\$${rule.minCost.toStringAsFixed(2)}';
    final to = rule.maxCost != null
        ? '\$${rule.maxCost!.toStringAsFixed(2)}'
        : 'and up';
    final label = '$from – $to';

    return Dismissible(
      key: Key('rule_${rule.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete,
            color: CupertinoColors.white, size: 20),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          color: CupertinoColors.systemBackground,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 16, color: CupertinoColors.label)),
              ),
              Text(
                '${rule.markupPercent.toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_right,
                  size: 16, color: Color(0xFFC7C7CC)),
            ],
          ),
        ),
      ),
    );
  }
}

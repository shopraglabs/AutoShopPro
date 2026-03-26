import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../../widgets/context_menu.dart';
import '../customers/customers_provider.dart';
import '../data/data_service.dart';
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
        // defaultLaborRate is int cents — convert to dollars for display
        _laborRateCtrl.text = fromCents(settings.defaultLaborRate).toStringAsFixed(2);
        _taxRateCtrl.text = settings.defaultTaxRate.toStringAsFixed(1);
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(dbProvider);
    final settings = await db.getOrCreateSettings();
    // Labor rate entered as dollars — convert to int cents for the DB
    final laborRateDollars = double.tryParse(_laborRateCtrl.text) ??
        fromCents(settings.defaultLaborRate);
    final taxRate =
        double.tryParse(_taxRateCtrl.text) ?? settings.defaultTaxRate;
    final shopName = _shopNameCtrl.text.trim();

    await db.saveSettings(ShopSettingsCompanion(
      id: const Value(1),
      shopName: Value(shopName.isEmpty ? null : shopName),
      defaultLaborRate: Value(toCents(laborRateDollars)),
      defaultTaxRate: Value(taxRate),
    ));
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _showAddRuleDialog() => _showRuleDialog(existing: null);

  Future<void> _showRuleDialog({required MarkupRule? existing}) async {
    // minCost/maxCost are int cents — convert to dollars for display
    final minCtrl = TextEditingController(
        text: existing != null
            ? fromCents(existing.minCost).toStringAsFixed(2)
            : '');
    final maxCtrl = TextEditingController(
        text: existing?.maxCost != null
            ? fromCents(existing!.maxCost!).toStringAsFixed(2)
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
                placeholder: '0',
                onTap: () => minCtrl.selection = TextSelection(
                  baseOffset: 0, extentOffset: minCtrl.text.length),
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
                onTap: () => maxCtrl.selection = TextSelection(
                  baseOffset: 0, extentOffset: maxCtrl.text.length),
                contextMenuBuilder: (ctx, s) =>
                    CupertinoAdaptiveTextSelectionToolbar.editableText(
                        editableTextState: s),
              ),
              const SizedBox(height: 12),
              const Text('Markup % above cost  (e.g. enter 10 to sell at 110% of cost)',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: pctCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                placeholder: '30.0',
                onTap: () => pctCtrl.selection = TextSelection(
                  baseOffset: 0, extentOffset: pctCtrl.text.length),
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
              // User enters dollar amounts — convert to int cents for the DB
              final minDollars = double.tryParse(minCtrl.text);
              final maxDollars = double.tryParse(maxCtrl.text);
              final pct = double.tryParse(pctCtrl.text);
              if (minDollars == null || pct == null) return;
              final db = ref.read(dbProvider);
              if (existing == null) {
                await db.insertMarkupRule(MarkupRulesCompanion(
                  minCost: Value(toCents(minDollars)),
                  maxCost: Value(maxDollars != null ? toCents(maxDollars) : null),
                  markupPercent: Value(pct),
                ));
              } else {
                await db.updateMarkupRule(existing.copyWith(
                  minCost: toCents(minDollars),
                  maxCost: Value(maxDollars != null ? toCents(maxDollars) : null),
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
                      placeholder: '120',
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

                  // ── People ────────────────────────────────────────────────
                  _sectionHeader('PEOPLE'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: GestureDetector(
                      onTap: () =>
                          context.push('/repair-orders/technicians'),
                      child: Container(
                        color: CupertinoColors.systemBackground,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.person_2_square_stack_fill,
                                size: 18, color: Color(0xFF007AFF)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Technicians',
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

                  const SizedBox(height: 20),

                  // ── Data Management ───────────────────────────────────────
                  _sectionHeader('DATA MANAGEMENT'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: Column(
                      children: [
                        // Export
                        GestureDetector(
                          onTap: _exportCsv,
                          child: Container(
                            color: CupertinoColors.systemBackground,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: const Row(
                              children: [
                                Icon(CupertinoIcons.arrow_up_doc,
                                    size: 18, color: Color(0xFF007AFF)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text('Export to CSV',
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
                        Container(height: 0.5, color: const Color(0xFFE5E5EA)),
                        // Import
                        GestureDetector(
                          onTap: _importCsv,
                          child: Container(
                            color: CupertinoColors.systemBackground,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: const Row(
                              children: [
                                Icon(CupertinoIcons.arrow_down_doc,
                                    size: 18, color: Color(0xFF007AFF)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text('Import from CSV',
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Danger Zone ───────────────────────────────────────────
                  _sectionHeader('DANGER ZONE'),
                  Container(
                    color: CupertinoColors.systemBackground,
                    child: Center(
                      child: CupertinoButton(
                        onPressed: _confirmClearData,
                        child: const Text(
                          'Clear All Customer Data',
                          style: TextStyle(
                              color: CupertinoColors.destructiveRed),
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

  Future<void> _exportCsv() async {
    final svc = ref.read(dataServiceProvider);
    try {
      final path = await svc.exportToCsv();
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Export Complete'),
          content: Text('Saved to:\n$path'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Export failed: $e');
    }
  }

  Future<void> _importCsv() async {
    final svc = ref.read(dataServiceProvider);
    try {
      final path = await svc.pickCsvFile();
      if (path == null) return; // user cancelled
      if (!mounted) return;

      // Show a loading indicator
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => const CupertinoAlertDialog(
          title: Text('Importing…'),
          content: Padding(
            padding: EdgeInsets.only(top: 12),
            child: CupertinoActivityIndicator(),
          ),
        ),
      );

      final result = await svc.importFromCsv(path);
      if (!mounted) return;
      Navigator.pop(context); // dismiss loading

      final summary = [
        '${result.customersCreated} customers added',
        '${result.vehiclesCreated} vehicles added',
        '${result.recordsCreated} records created',
        if (result.duplicatesSkipped > 0)
          '${result.duplicatesSkipped} duplicates skipped',
        if (result.errors.isNotEmpty)
          '${result.errors.length} errors (see below)',
      ].join('\n');

      final errorDetail = result.errors.take(5).join('\n');

      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Import Complete'),
          content: Text(
              '$summary${errorDetail.isNotEmpty ? '\n\n$errorDetail' : ''}'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Import failed: $e');
    }
  }

  Future<void> _confirmClearData() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Clear All Customer Data?'),
        content: const Text(
            'This permanently deletes all customers, vehicles, estimates, '
            'and repair orders. Your shop settings, templates, technicians, '
            'vendors, and inventory are kept.\n\nThis cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).clearAllCustomerData();
              if (!mounted) return;
              await showCupertinoDialog<void>(
                context: context,
                builder: (d) => CupertinoAlertDialog(
                  title: const Text('Done'),
                  content:
                      const Text('All customer data has been cleared.'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(d),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('OK'),
          ),
        ],
      ),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
        onTap: onEdit,
        onSecondaryTapUp: (details) => showContextMenu(
          context: context,
          position: details.globalPosition,
          items: [
            ContextMenuAction(
              label: 'Edit',
              icon: CupertinoIcons.pencil,
              onTap: onEdit,
            ),
            contextMenuDivider,
            ContextMenuAction(
              label: 'Delete',
              icon: CupertinoIcons.trash,
              isDestructive: true,
              onTap: onDelete,
            ),
          ],
        ),
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
      ),
    );
  }
}

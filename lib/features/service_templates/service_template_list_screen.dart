import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart' show dbProvider;
import 'service_templates_provider.dart';

// List of all saved service templates. Tap a row to edit. Swipe to delete.
class ServiceTemplateListScreen extends ConsumerWidget {
  const ServiceTemplateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(serviceTemplatesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Service Templates'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/settings/service-templates/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: templatesAsync.when(
          loading: () =>
              const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (templates) => templates.isEmpty
              ? _emptyState(context)
              : _list(context, ref, templates),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.doc_text,
                size: 48, color: Color(0xFFD1D1D6)),
            const SizedBox(height: 12),
            const Text('No Templates Yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E))),
            const SizedBox(height: 6),
            const Text('Add templates for common jobs like oil changes.',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: () =>
                  context.push('/settings/service-templates/new'),
              child: const Text('Add Template'),
            ),
          ],
        ),
      );

  Widget _list(BuildContext context, WidgetRef ref,
      List<ServiceTemplate> templates) {
    return ListView.builder(
      itemCount: templates.length,
      itemBuilder: (context, i) {
        final t = templates[i];
        return Column(
          children: [
            if (i == 0)
              Container(height: 0.5, color: const Color(0xFFE5E5EA)),
            Dismissible(
              key: ValueKey(t.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: CupertinoColors.destructiveRed,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(CupertinoIcons.trash,
                    color: CupertinoColors.white),
              ),
              confirmDismiss: (_) async {
                bool confirmed = false;
                await showCupertinoDialog(
                  context: context,
                  builder: (d) => CupertinoAlertDialog(
                    title: Text('Delete "${t.name}"?'),
                    content: const Text(
                        'This template will be permanently removed.'),
                    actions: [
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          confirmed = true;
                          Navigator.pop(d);
                        },
                        child: const Text('Delete'),
                      ),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () => Navigator.pop(d),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
                return confirmed;
              },
              onDismissed: (_) =>
                  ref.read(dbProvider).deleteServiceTemplate(t.id),
              child: GestureDetector(
                onTap: () => context.push(
                    '/settings/service-templates/${t.id}/edit'),
                child: Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.doc_text,
                          size: 18, color: Color(0xFF007AFF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1C1C1E))),
                            Text(
                              '${_fmtHours(t.defaultHours)} hr · ${t.laborDescription}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E8E93)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right,
                          size: 16, color: Color(0xFFC7C7CC)),
                    ],
                  ),
                ),
              ),
            ),
            Container(
                height: 0.5,
                color: const Color(0xFFE5E5EA),
                margin: const EdgeInsets.only(left: 46)),
          ],
        );
      },
    );
  }

  String _fmtHours(double h) =>
      h % 1 == 0 ? h.toInt().toString() : h.toStringAsFixed(1);
}

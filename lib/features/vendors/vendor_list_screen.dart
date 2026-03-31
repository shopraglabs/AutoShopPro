import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../widgets/context_menu.dart';
import 'vendors_provider.dart';

class VendorListScreen extends ConsumerWidget {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Vendors'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/records/vendors/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: vendorsAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (vendors) {
            if (vendors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.building_2_fill,
                        size: 48, color: Color(0xFFC7C7CC)),
                    SizedBox(height: 12),
                    Text('No vendors yet',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E))),
                    SizedBox(height: 4),
                    Text('Tap + to add your first vendor',
                        style: TextStyle(
                            fontSize: 15, color: Color(0xFF8E8E93))),
                  ],
                ),
              );
            }
            return CupertinoScrollbar(
              child: ListView.builder(
                itemCount: vendors.length,
                itemBuilder: (context, i) =>
                    _VendorRow(vendor: vendors[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VendorRow extends ConsumerWidget {
  final Vendor vendor;
  const _VendorRow({required this.vendor});

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text('Archive ${vendor.name}?'),
        content: const Text(
            'Archived vendors are hidden from lists and pickers but existing records are preserved.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).archiveVendor(vendor.id);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              context.push('/records/vendors/${vendor.id}/edit'),
          onSecondaryTapUp: (details) => showContextMenu(
            context: context,
            position: details.globalPosition,
            items: [
              ContextMenuAction(
                label: 'Edit Vendor',
                icon: CupertinoIcons.pencil,
                onTap: () => context.push(
                    '/records/vendors/${vendor.id}/edit'),
              ),
              contextMenuDivider,
              ContextMenuAction(
                label: 'Archive Vendor',
                icon: CupertinoIcons.archivebox,
                isDestructive: true,
                onTap: () => _confirmArchive(context, ref),
              ),
            ],
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
            color: CupertinoColors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(CupertinoIcons.building_2_fill,
                      color: CupertinoColors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1C1C1E))),
                      if (vendor.contactName != null)
                        Text(vendor.contactName!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93))),
                      if (vendor.accountNumber != null)
                        Text(
                          'ACCT: ${vendor.accountNumber!.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93)),
                        ),
                    ],
                  ),
                ),
                if (vendor.phone != null)
                  Text(vendor.phone!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93))),
                const SizedBox(width: 8),
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
          margin: const EdgeInsets.only(left: 68),
        ),
      ],
    );
  }
}

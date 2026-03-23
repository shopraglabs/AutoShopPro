import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../widgets/context_menu.dart';
import 'customers_provider.dart';

// The main customer list screen.
// It watches the database in real time — add or delete a customer and
// this list updates instantly without any manual refresh.
class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter the full list down to only customers that match the search query.
  List<Customer> _filter(List<Customer> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.phone?.toLowerCase().contains(q) ?? false) ||
            (c.email?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCustomers = ref.watch(customersProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Customers'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          // Tap + to go to the "New Customer" form
          onPressed: () => context.go('/repair-orders/customers/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                placeholder: 'Search customers',
              ),
            ),
            // List area
            Expanded(
              child: asyncCustomers.when(
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (all) {
                  final filtered = _filter(all);
                  if (filtered.isEmpty) {
                    return _buildEmpty();
                  }
                  return CupertinoScrollbar(
                    child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Container(
                      height: 0.5,
                      color: const Color(0xFFE5E5EA),
                      // Indent the divider to align with the text, not the avatar
                      margin: const EdgeInsets.only(left: 68),
                    ),
                    itemBuilder: (context, i) {
                      final customer = filtered[i];
                      return _CustomerTile(
                        customer: customer,
                        onTap: () => context.go(
                            '/repair-orders/customers/${customer.id}'),
                      );
                    },
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shown when the list is empty (no customers, or no search results)
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.person_2,
            size: 52,
            color: Color(0xFFAEAEB2),
          ),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty ? 'No customers yet' : 'No results for "$_query"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _query.isEmpty
                ? 'Tap + to add your first customer'
                : 'Try a different search',
            style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}

// A single row in the customer list.
class _CustomerTile extends ConsumerWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerTile({required this.customer, required this.onTap});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) {
    return showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text('Delete ${customer.name}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(dbProvider).deleteCustomer(customer.id);
            },
            child: const Text('Delete'),
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
    // Show the first letter of the customer's name as an avatar
    final initial =
        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      onTap: onTap,
      onSecondaryTapUp: (details) => showContextMenu(
        context: context,
        position: details.globalPosition,
        items: [
          ContextMenuAction(
            label: 'Open',
            icon: CupertinoIcons.person_fill,
            onTap: onTap,
          ),
          contextMenuDivider,
          ContextMenuAction(
            label: 'Edit Customer',
            icon: CupertinoIcons.pencil,
            onTap: () => context.push(
                '/repair-orders/customers/${customer.id}/edit'),
          ),
          contextMenuDivider,
          ContextMenuAction(
            label: 'Delete Customer',
            icon: CupertinoIcons.trash,
            isDestructive: true,
            onTap: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar circle with initial
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (customer.phone != null && customer.phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        customer.phone!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                ],
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
    );
  }
}

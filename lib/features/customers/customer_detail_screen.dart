import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'customers_provider.dart';

// ── Shared helpers ────────────────────────────────────────────────────────────

String _estimateNum(int id) => 'EST-${id.toString().padLeft(4, '0')}';
String _roNum(int id) => 'RO-${id.toString().padLeft(4, '0')}';

String _money(double amount) {
  final hasCents = amount % 1 != 0;
  final str = hasCents ? amount.toStringAsFixed(2) : amount.toInt().toString();
  final parts = str.split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return hasCents ? '\$$dollars.${parts[1]}' : '\$$dollars';
}

String _vehicleLabel(Vehicle? v) {
  if (v == null) return '';
  return [
    if (v.year != null) v.year.toString(),
    if (v.make != null) v.make!,
    if (v.model != null) v.model!,
  ].join(' ');
}

// Helper: builds "2018 Toyota Camry" from a Vehicle object
String vehicleLabel(Vehicle v) {
  final parts = [
    if (v.year != null) v.year.toString(),
    if (v.make != null) v.make!,
    if (v.model != null) v.model!,
  ];
  return parts.isEmpty ? 'Unknown vehicle' : parts.join(' ');
}

// Shows a single customer's profile — their contact info, vehicles, and a
// delete button. Tapping Edit opens the CustomerFormScreen pre-filled.
class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return StreamBuilder<Customer?>(
      stream: db.watchCustomer(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Customer')),
            child: Center(child: Text('Error loading customer.')),
          );
        }
        final customer = snapshot.data;
        if (customer == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Customer')),
            child: Center(child: Text('Customer not found.')),
          );
        }
        return _CustomerDetail(customer: customer);
      },
    );
  }
}

class _CustomerDetail extends ConsumerWidget {
  final Customer customer;
  const _CustomerDetail({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(customer.name),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              context.go('/repair-orders/customers/${customer.id}/edit'),
          child: const Text('Edit'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Avatar + name header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),

            // Contact info section
            _DetailSection(
              label: 'CONTACT',
              rows: [
                if (customer.phone != null && customer.phone!.isNotEmpty)
                  _DetailRow(
                    icon: CupertinoIcons.phone_fill,
                    label: 'Phone',
                    value: customer.phone!,
                  ),
                if (customer.email != null && customer.email!.isNotEmpty)
                  _DetailRow(
                    icon: CupertinoIcons.mail_solid,
                    label: 'Email',
                    value: customer.email!,
                  ),
                if (customer.internalNote != null &&
                    customer.internalNote!.isNotEmpty)
                  _DetailRow(
                    icon: CupertinoIcons.pencil_ellipsis_rectangle,
                    label: 'Internal Note',
                    value: customer.internalNote!,
                  ),
              ],
              emptyMessage: 'No contact info saved',
            ),

            const SizedBox(height: 20),

            // Vehicles section — live list from the database
            _VehiclesSection(customer: customer),

            const SizedBox(height: 20),

            // History section — all estimates and ROs for this customer
            _HistorySection(customer: customer),

            const SizedBox(height: 36),

            // Delete — subtle text link, not a big red button
            Center(
              child: CupertinoButton(
                onPressed: () => _confirmDelete(context, ref),
                child: const Text(
                  'Delete Customer',
                  style: TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      // 'dlg' is the dialog's own context — needed to close the dialog itself
      builder: (dlg) => CupertinoAlertDialog(
        title: const Text('Delete Customer?'),
        content: Text(
          'This will permanently delete ${customer.name}. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dlg); // close dialog first
              await ref.read(dbProvider).deleteCustomer(customer.id);
              if (context.mounted) {
                context.go('/repair-orders/customers');
              }
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// The vehicles section on the customer detail page.
// Watches the database live and shows a tile per vehicle plus an Add button.
class _VehiclesSection extends ConsumerWidget {
  final Customer customer;
  const _VehiclesSection({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVehicles = ref.watch(vehiclesProvider(customer.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with Add button on the right
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'VEHICLES',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minSize: 0,
                onPressed: () => context.go(
                  '/repair-orders/customers/${customer.id}/vehicles/new',
                ),
                child: const Icon(
                  CupertinoIcons.add_circled,
                  size: 22,
                  color: Color(0xFF007AFF),
                ),
              ),
            ],
          ),
        ),
        // Vehicle list or empty state
        asyncVehicles.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (vehicleList) {
            if (vehicleList.isEmpty) {
              return Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: const Text(
                  'No vehicles yet — tap + to add one',
                  style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                ),
              );
            }
            return Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  for (int i = 0; i < vehicleList.length; i++) ...[
                    _VehicleTile(
                      vehicle: vehicleList[i],
                      onTap: () => context.go(
                        '/repair-orders/customers/${customer.id}/vehicles/${vehicleList[i].id}',
                      ),
                    ),
                    if (i < vehicleList.length - 1)
                      Container(
                        height: 0.5,
                        color: const Color(0xFFE5E5EA),
                        margin: const EdgeInsets.only(left: 56),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleTile({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = vehicleLabel(vehicle);
    final sub = [
      if (vehicle.licensePlate != null) vehicle.licensePlate!,
      if (vehicle.mileage != null) '${vehicle.mileage} mi',
    ].join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.car_detailed,
              size: 22,
              color: Color(0xFF007AFF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (sub.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 13,
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
    );
  }
}

// ── History Section ───────────────────────────────────────────────────────────
// Shows all estimates and ROs for this customer, sorted newest first.
class _HistorySection extends ConsumerWidget {
  final Customer customer;
  const _HistorySection({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return StreamBuilder<List<EstimateWithDetails>>(
      stream: db.watchEstimatesForCustomer(customer.id),
      builder: (context, estSnap) {
        return StreamBuilder<List<RepairOrderWithDetails>>(
          stream: db.watchRepairOrdersForCustomer(customer.id),
          builder: (context, roSnap) {
            final estimates = estSnap.data ?? [];
            final ros = roSnap.data ?? [];

            // Build a combined flat list sorted newest first
            // Each entry: (date, widget)
            final items = <({DateTime date, Widget row})>[];

            for (final e in estimates) {
              final est = e.estimate;
              items.add((
                date: est.createdAt,
                row: _HistoryRow(
                  dot: _statusDot(est.status),
                  number: _estimateNum(est.id),
                  vehicle: _vehicleLabel(e.vehicle),
                  trailing: null,
                  statusLabel: _estimateStatusLabel(est.status),
                  onTap: () => context
                      .push('/repair-orders/estimates/${est.id}'),
                ),
              ));
            }

            for (final r in ros) {
              final ro = r.ro;
              items.add((
                date: ro.createdAt,
                row: _HistoryRow(
                  dot: _roDot(ro.status),
                  number: _roNum(ro.id),
                  vehicle: _vehicleLabel(r.vehicle),
                  trailing: null,
                  statusLabel: _roStatusLabel(ro.status),
                  onTap: () => context
                      .push('/repair-orders/ro/${ro.id}'),
                ),
              ));
            }

            items.sort((a, b) => b.date.compareTo(a.date));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: const Text(
                    'HISTORY',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (items.isEmpty)
                  Container(
                    color: CupertinoColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: const Text(
                      'No estimates or repair orders yet',
                      style: TextStyle(
                          fontSize: 16, color: Color(0xFF8E8E93)),
                    ),
                  )
                else
                  Container(
                    color: CupertinoColors.white,
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          items[i].row,
                          if (i < items.length - 1)
                            Container(
                              height: 0.5,
                              color: const Color(0xFFE5E5EA),
                              margin: const EdgeInsets.only(left: 16),
                            ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Color _statusDot(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF34C759); // green
      case 'declined':
        return const Color(0xFFFF3B30); // red
      default:
        return const Color(0xFF8E8E93); // gray (draft)
    }
  }

  Color _roDot(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF007AFF); // blue
      case 'in_progress':
        return const Color(0xFFFF9500); // orange
      case 'completed':
        return const Color(0xFF34C759); // green
      case 'closed':
        return const Color(0xFF8E8E93); // gray
      default:
        return const Color(0xFF8E8E93);
    }
  }

  String _estimateStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'declined':
        return 'Declined';
      default:
        return 'Estimate';
    }
  }

  String _roStatusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }
}

class _HistoryRow extends StatelessWidget {
  final Color dot;
  final String number;
  final String vehicle;
  final String? trailing;
  final String statusLabel;
  final VoidCallback onTap;

  const _HistoryRow({
    required this.dot,
    required this.number,
    required this.vehicle,
    required this.trailing,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (vehicle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        vehicle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}

// A labelled section containing a list of detail rows, or an empty message.
class _DetailSection extends StatelessWidget {
  final String label;
  final List<_DetailRow> rows;
  final String? emptyMessage;

  const _DetailSection({
    required this.label,
    required this.rows,
    this.emptyMessage,
  });

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
          child: rows.isEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    emptyMessage ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < rows.length; i++) ...[
                      rows[i],
                      if (i < rows.length - 1)
                        Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 56),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

// A single info row with an icon, small label, and value
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF007AFF)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

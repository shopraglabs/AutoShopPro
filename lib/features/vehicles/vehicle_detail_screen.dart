import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

// Shows a single vehicle's details with an Edit button and a Delete button.
class VehicleDetailScreen extends ConsumerWidget {
  final int customerId;
  final int vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.customerId,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return StreamBuilder<Vehicle?>(
      stream: db.watchVehicle(vehicleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Vehicle')),
            child: Center(child: Text('Error loading vehicle.')),
          );
        }
        final vehicle = snapshot.data;
        if (vehicle == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Vehicle')),
            child: Center(child: Text('Vehicle not found.')),
          );
        }
        return _VehicleDetail(vehicle: vehicle, customerId: customerId);
      },
    );
  }
}

class _VehicleDetail extends ConsumerWidget {
  final Vehicle vehicle;
  final int customerId;

  const _VehicleDetail({required this.vehicle, required this.customerId});

  // Builds a short display name like "2018 Toyota Camry SE"
  String get _title {
    final parts = [
      if (vehicle.year != null) vehicle.year.toString(),
      if (vehicle.make != null) vehicle.make!,
      if (vehicle.model != null) vehicle.model!,
    ];
    return parts.isEmpty ? 'Vehicle' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go(
            '/repair-orders/customers/$customerId/vehicles/${vehicle.id}/edit',
          ),
          child: const Text('Edit'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Car icon header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.car_detailed,
                        size: 38,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),

            // Vehicle info section
            _DetailSection(
              label: 'VEHICLE INFO',
              rows: [
                if (vehicle.vin != null && vehicle.vin!.isNotEmpty)
                  _DetailRow(label: 'VIN', value: vehicle.vin!),
                if (vehicle.mileage != null)
                  _DetailRow(
                    label: 'Mileage',
                    value:
                        '${_formatNumber(vehicle.mileage!)} mi',
                  ),
                if (vehicle.licensePlate != null &&
                    vehicle.licensePlate!.isNotEmpty)
                  _DetailRow(label: 'Plate', value: vehicle.licensePlate!),
              ],
              emptyMessage: 'No additional details',
            ),

            const SizedBox(height: 28),

            // New Estimate — styled as a standard list row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _newEstimate(context, ref),
                  child: Container(
                    color: CupertinoColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.doc_text,
                            size: 18, color: Color(0xFF007AFF)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'New Estimate',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF007AFF)),
                          ),
                        ),
                        Icon(CupertinoIcons.chevron_right,
                            size: 16, color: Color(0xFFC7C7CC)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Delete — subtle text link
            Center(
              child: CupertinoButton(
                onPressed: () => _confirmDelete(context, ref),
                child: const Text(
                  'Delete Vehicle',
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

  // Creates a new estimate pre-linked to this customer and vehicle,
  // then navigates directly to the estimate detail screen.
  Future<void> _newEstimate(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final id = await db.insertEstimate(EstimatesCompanion.insert(
      customerId: customerId,
      vehicleId: Value(vehicle.id),
    ));
    if (context.mounted) {
      context.push('/repair-orders/estimates/$id');
    }
  }

  // Formats 45000 → "45,000"
  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (dlg) => CupertinoAlertDialog(
        title: const Text('Delete Vehicle?'),
        content: Text('This will permanently delete $_title.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dlg); // close dialog first
              await ref.read(dbProvider).deleteVehicle(vehicle.id);
              if (context.mounted) {
                context.go('/repair-orders/customers/$customerId');
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                          margin: const EdgeInsets.only(left: 16),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
            ),
          ),
        ],
      ),
    );
  }
}

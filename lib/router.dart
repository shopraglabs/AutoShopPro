import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'main.dart';
import 'features/repair_orders/repair_orders_screen.dart';
import 'features/customers/customer_list_screen.dart';
import 'features/customers/customer_form_screen.dart';
import 'features/customers/customer_detail_screen.dart';
import 'features/customers/customers_provider.dart';
import 'features/vehicles/vehicle_form_screen.dart';
import 'features/vehicles/vehicle_detail_screen.dart';

// The router defines every screen address in the app.
// Think of each GoRoute as a page in a book — the 'path' is its page number,
// and 'builder' is what gets displayed when you turn to that page.

final appRouter = GoRouter(
  initialLocation: '/repair-orders',
  routes: [
    ShellRoute(
      // AppShell wraps every screen with the sidebar (desktop) or tab bar (mobile)
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // ── Module 1: Repair Orders ───────────────────────────────────────────
        GoRoute(
          path: '/repair-orders',
          builder: (context, state) => const RepairOrdersScreen(),
          routes: [
            // Customer list
            GoRoute(
              path: 'customers',
              builder: (context, state) => const CustomerListScreen(),
              routes: [
                // New customer form (no pre-existing customer passed in)
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const CustomerFormScreen(),
                ),
                // Customer detail — :id is replaced with the actual customer id
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return CustomerDetailScreen(customerId: id);
                  },
                  routes: [
                    // Edit customer — loads the customer then opens the form
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return _CustomerEditLoader(customerId: id);
                      },
                    ),
                    // ── Vehicles ─────────────────────────────────────────────
                    GoRoute(
                      path: 'vehicles/new',
                      builder: (context, state) {
                        final customerId =
                            int.parse(state.pathParameters['id']!);
                        return VehicleFormScreen(customerId: customerId);
                      },
                    ),
                    GoRoute(
                      path: 'vehicles/:vehicleId',
                      builder: (context, state) {
                        final customerId =
                            int.parse(state.pathParameters['id']!);
                        final vehicleId =
                            int.parse(state.pathParameters['vehicleId']!);
                        return VehicleDetailScreen(
                          customerId: customerId,
                          vehicleId: vehicleId,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final customerId =
                                int.parse(state.pathParameters['id']!);
                            final vehicleId =
                                int.parse(state.pathParameters['vehicleId']!);
                            return _VehicleEditLoader(
                              customerId: customerId,
                              vehicleId: vehicleId,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ── Module 2: Parts ───────────────────────────────────────────────────
        GoRoute(
          path: '/parts',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Parts'),
        ),

        // ── Module 3: Payments ────────────────────────────────────────────────
        GoRoute(
          path: '/payments',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Payments'),
        ),

        // ── Module 4: Dashboard ───────────────────────────────────────────────
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Dashboard'),
        ),

        // ── Module 5: Accounting ──────────────────────────────────────────────
        GoRoute(
          path: '/accounting',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Accounting'),
        ),
      ],
    ),
  ],
);

// Fetches a customer from the database by id, then shows the edit form
// pre-filled with that customer's data.
class _CustomerEditLoader extends ConsumerWidget {
  final int customerId;
  const _CustomerEditLoader({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: db.getCustomer(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final customer = snapshot.data;
        if (customer == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit Customer')),
            child: Center(child: Text('Customer not found.')),
          );
        }
        // Hand the loaded customer to the form so its fields are pre-filled
        return CustomerFormScreen(customer: customer);
      },
    );
  }
}

// Fetches a vehicle from the database by id, then shows the edit form
// pre-filled with that vehicle's data.
class _VehicleEditLoader extends ConsumerWidget {
  final int customerId;
  final int vehicleId;
  const _VehicleEditLoader({
    required this.customerId,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: db.getVehicle(vehicleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final vehicle = snapshot.data;
        if (vehicle == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Edit Vehicle')),
            child: Center(child: Text('Vehicle not found.')),
          );
        }
        return VehicleFormScreen(customerId: customerId, vehicle: vehicle);
      },
    );
  }
}

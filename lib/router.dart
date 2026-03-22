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
import 'features/estimates/estimate_list_screen.dart';
import 'features/estimates/estimate_form_screen.dart';
import 'features/estimates/estimate_detail_screen.dart';
import 'features/estimates/line_item_form_screen.dart';
import 'features/vendors/vendor_list_screen.dart';
import 'features/vendors/vendor_form_screen.dart';
import 'features/vendors/vendors_provider.dart';
import 'features/repair_orders/ro_list_screen.dart';
import 'features/repair_orders/ro_detail_screen.dart';

// The router defines every screen address in the app.
// Think of each GoRoute as a page in a book — the 'path' is its page number,
// and 'builder' is what gets displayed when you turn to that page.

// A global key that gives us a BuildContext from outside the widget tree.
// The macOS menu bar uses this to show dialogs when a menu item is tapped.
final appNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: appNavigatorKey,
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
            // Repair order list + detail
            GoRoute(
              path: 'ros',
              builder: (context, state) => const RoListScreen(),
              routes: [
                GoRoute(
                  path: ':roId',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['roId']!);
                    return RoDetailScreen(roId: id);
                  },
                ),
              ],
            ),

            // Vendor list
            GoRoute(
              path: 'vendors',
              builder: (context, state) => const VendorListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const VendorFormScreen(),
                ),
                GoRoute(
                  path: ':vendorId/edit',
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['vendorId']!);
                    return _VendorEditLoader(vendorId: id);
                  },
                ),
              ],
            ),

            // Estimate list
            GoRoute(
              path: 'estimates',
              builder: (context, state) => const EstimateListScreen(),
              routes: [
                // New estimate form
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const EstimateFormScreen(),
                ),
                // Estimate detail
                GoRoute(
                  path: ':estimateId',
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['estimateId']!);
                    return EstimateDetailScreen(estimateId: id);
                  },
                  routes: [
                    // Add labor line item
                    GoRoute(
                      path: 'line-items/labor',
                      builder: (context, state) {
                        final id = int.parse(
                            state.pathParameters['estimateId']!);
                        return LineItemFormScreen(
                            estimateId: id, type: 'labor');
                      },
                    ),
                    // Add part line item
                    GoRoute(
                      path: 'line-items/part',
                      builder: (context, state) {
                        final id = int.parse(
                            state.pathParameters['estimateId']!);
                        return LineItemFormScreen(
                            estimateId: id, type: 'part');
                      },
                    ),
                    // Edit existing line item
                    GoRoute(
                      path: 'line-items/:lineItemId/edit',
                      builder: (context, state) {
                        final estimateId = int.parse(
                            state.pathParameters['estimateId']!);
                        final lineItemId = int.parse(
                            state.pathParameters['lineItemId']!);
                        return _LineItemEditLoader(
                          estimateId: estimateId,
                          lineItemId: lineItemId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

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
        if (snapshot.hasError) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit Customer')),
            child: Center(child: Text('Error loading customer.')),
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

// Fetches a vendor from the database by id, then shows the edit form
// pre-filled with that vendor's data.
class _VendorEditLoader extends ConsumerWidget {
  final int vendorId;
  const _VendorEditLoader({required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: db.getVendor(vendorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit Vendor')),
            child: Center(child: Text('Error loading vendor.')),
          );
        }
        final vendor = snapshot.data;
        if (vendor == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Edit Vendor')),
            child: Center(child: Text('Vendor not found.')),
          );
        }
        return VendorFormScreen(vendor: vendor);
      },
    );
  }
}

// Fetches a line item from the database by id, then shows the edit form.
class _LineItemEditLoader extends ConsumerWidget {
  final int estimateId;
  final int lineItemId;
  const _LineItemEditLoader({
    required this.estimateId,
    required this.lineItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);
    return FutureBuilder(
      future: db.getLineItem(lineItemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit')),
            child: Center(child: Text('Error loading line item.')),
          );
        }
        final lineItem = snapshot.data;
        if (lineItem == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit')),
            child: Center(child: Text('Line item not found.')),
          );
        }
        return LineItemFormScreen(
          estimateId: estimateId,
          type: lineItem.type,
          lineItem: lineItem,
        );
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
        if (snapshot.hasError) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit Vehicle')),
            child: Center(child: Text('Error loading vehicle.')),
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

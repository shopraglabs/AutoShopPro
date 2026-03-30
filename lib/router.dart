import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'database/database.dart';
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
import 'features/repair_orders/ro_form_screen.dart';
import 'features/technicians/technician_list_screen.dart';
import 'features/technicians/technician_form_screen.dart';
import 'features/technicians/technicians_provider.dart';
import 'features/inventory/part_list_screen.dart';
import 'features/inventory/part_form_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/service_templates/service_template_list_screen.dart';
import 'features/service_templates/service_template_form_screen.dart';
import 'features/search/search_screen.dart';
import 'features/invoices/invoice_list_screen.dart';
import 'features/invoices/invoice_detail_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

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
                  routes: [
                    // Edit RO note
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['roId']!);
                        return _RoEditLoader(roId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),

            // Technicians
            GoRoute(
              path: 'technicians',
              builder: (context, state) => const TechnicianListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const TechnicianFormScreen(),
                ),
                GoRoute(
                  path: ':techId/edit',
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['techId']!);
                    return _TechEditLoader(techId: id);
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
                // New estimate form — optional ?customerId=X&vehicleId=Y pre-fill
                GoRoute(
                  path: 'new',
                  builder: (context, state) {
                    final params = state.uri.queryParameters;
                    final customerId =
                        int.tryParse(params['customerId'] ?? '');
                    final vehicleId =
                        int.tryParse(params['vehicleId'] ?? '');
                    return EstimateFormScreen(
                      preCustomerId: customerId,
                      preVehicleId: vehicleId,
                    );
                  },
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
                        final parentLaborId = int.tryParse(
                            state.uri.queryParameters['parentLaborId'] ?? '');
                        return LineItemFormScreen(
                            estimateId: id,
                            type: 'part',
                            parentLaborId: parentLaborId);
                      },
                    ),
                    // Add other line item (fees, sublet, misc)
                    GoRoute(
                      path: 'line-items/other',
                      builder: (context, state) {
                        final id = int.parse(
                            state.pathParameters['estimateId']!);
                        return LineItemFormScreen(
                            estimateId: id, type: 'other');
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

        // ── Invoices (inside Records) ─────────────────────────────────────────
        GoRoute(
          path: '/repair-orders/invoices',
          builder: (context, state) => const InvoiceListScreen(),
          routes: [
            GoRoute(
              path: ':roId',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['roId']!);
                return InvoiceDetailScreen(roId: id);
              },
            ),
          ],
        ),

        // ── Module 2: Parts ───────────────────────────────────────────────────
        GoRoute(
          path: '/parts',
          builder: (context, state) => const PartListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const PartFormScreen(),
            ),
            GoRoute(
              path: ':partId/edit',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['partId']!);
                return _PartEditLoader(partId: id);
              },
            ),
          ],
        ),

        // ── Settings ──────────────────────────────────────────────────────
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'service-templates',
              builder: (context, state) =>
                  const ServiceTemplateListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) =>
                      const ServiceTemplateFormScreen(),
                ),
                GoRoute(
                  path: ':templateId/edit',
                  builder: (context, state) {
                    final id = int.parse(
                        state.pathParameters['templateId']!);
                    return _ServiceTemplateEditLoader(templateId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Search ────────────────────────────────────────────────────────
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),

        // ── Module 3: Payments / Invoices ─────────────────────────────────────
        GoRoute(
          path: '/payments',
          builder: (context, state) => const InvoiceListScreen(),
          routes: [
            GoRoute(
              path: ':roId',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['roId']!);
                return InvoiceDetailScreen(roId: id);
              },
            ),
          ],
        ),

        // ── Module 4: Dashboard ───────────────────────────────────────────────
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
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
    final customerAsync = ref.watch(customerProvider(customerId));
    return customerAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Edit Customer')),
        child: Center(child: Text('Error loading customer.')),
      ),
      data: (customer) {
        if (customer == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit Customer')),
            child: Center(child: Text('Customer not found.')),
          );
        }
        return CustomerFormScreen(customer: customer);
      },
    );
  }
}

// Fetches a vendor from the database by id, then shows the edit form
// pre-filled with that vendor's data.
class _VendorEditLoader extends ConsumerStatefulWidget {
  final int vendorId;
  const _VendorEditLoader({required this.vendorId});

  @override
  ConsumerState<_VendorEditLoader> createState() => _VendorEditLoaderState();
}

class _VendorEditLoaderState extends ConsumerState<_VendorEditLoader> {
  late final Future<Vendor?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(dbProvider).getVendor(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
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
class _LineItemEditLoader extends ConsumerStatefulWidget {
  final int estimateId;
  final int lineItemId;
  const _LineItemEditLoader({
    required this.estimateId,
    required this.lineItemId,
  });

  @override
  ConsumerState<_LineItemEditLoader> createState() =>
      _LineItemEditLoaderState();
}

class _LineItemEditLoaderState extends ConsumerState<_LineItemEditLoader> {
  late final Future<EstimateLineItem?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(dbProvider).getLineItem(widget.lineItemId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
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
          estimateId: widget.estimateId,
          type: lineItem.type,
          lineItem: lineItem,
        );
      },
    );
  }
}

// Fetches a repair order from the database by id, then shows the edit form.
class _RoEditLoader extends ConsumerStatefulWidget {
  final int roId;
  const _RoEditLoader({required this.roId});

  @override
  ConsumerState<_RoEditLoader> createState() => _RoEditLoaderState();
}

class _RoEditLoaderState extends ConsumerState<_RoEditLoader> {
  late final Future<RepairOrder?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(dbProvider).getRepairOrder(widget.roId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final ro = snapshot.data;
        if (ro == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit RO')),
            child: Center(child: Text('Repair order not found.')),
          );
        }
        return RoFormScreen(ro: ro);
      },
    );
  }
}

// Fetches a technician from the database by id, then shows the edit form.
class _TechEditLoader extends ConsumerStatefulWidget {
  final int techId;
  const _TechEditLoader({required this.techId});

  @override
  ConsumerState<_TechEditLoader> createState() => _TechEditLoaderState();
}

class _TechEditLoaderState extends ConsumerState<_TechEditLoader> {
  late final Future<Technician?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(dbProvider).getTechnician(widget.techId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final tech = snapshot.data;
        if (tech == null) {
          return const CupertinoPageScaffold(
            navigationBar:
                CupertinoNavigationBar(middle: Text('Edit Technician')),
            child: Center(child: Text('Technician not found.')),
          );
        }
        return TechnicianFormScreen(technician: tech);
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
    final vehicleAsync = ref.watch(vehicleProvider(vehicleId));
    return vehicleAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Edit Vehicle')),
        child: Center(child: Text('Error loading vehicle.')),
      ),
      data: (vehicle) {
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

// Fetches a part from the database by id, then shows the edit form.
class _PartEditLoader extends ConsumerStatefulWidget {
  final int partId;
  const _PartEditLoader({required this.partId});

  @override
  ConsumerState<_PartEditLoader> createState() => _PartEditLoaderState();
}

class _PartEditLoaderState extends ConsumerState<_PartEditLoader> {
  late final Future<InventoryPart?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(dbProvider).getPart(widget.partId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final part = snapshot.data;
        if (part == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text('Edit Part')),
            child: Center(child: Text('Part not found.')),
          );
        }
        return PartFormScreen(part: part);
      },
    );
  }
}

// Fetches a service template from the database by id, then shows the edit form.
class _ServiceTemplateEditLoader extends ConsumerStatefulWidget {
  final int templateId;
  const _ServiceTemplateEditLoader({required this.templateId});

  @override
  ConsumerState<_ServiceTemplateEditLoader> createState() =>
      _ServiceTemplateEditLoaderState();
}

class _ServiceTemplateEditLoaderState
    extends ConsumerState<_ServiceTemplateEditLoader> {
  late final Future<ServiceTemplate?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(dbProvider).getServiceTemplate(widget.templateId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final template = snapshot.data;
        if (template == null) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                middle: Text('Edit Template')),
            child: Center(child: Text('Template not found.')),
          );
        }
        return ServiceTemplateFormScreen(template: template);
      },
    );
  }
}

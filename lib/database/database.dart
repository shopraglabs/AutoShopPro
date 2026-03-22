import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// This tells Drift to look at this file and generate a companion file
// called database.g.dart with all the boilerplate read/write code.
part 'database.g.dart';

// ─── Table Definitions ───────────────────────────────────────────────────────
// Each class below is one database table. The class name becomes the table
// name (in snake_case). Each field is a column.

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which customer owns this vehicle
  IntColumn get customerId => integer()();
  IntColumn get year => integer().nullable()();
  TextColumn get make => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get vin => text().nullable()();
  IntColumn get mileage => integer().nullable()();
  TextColumn get licensePlate => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Estimates extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which customer this estimate is for
  IntColumn get customerId => integer()();
  // Which vehicle (optional — can be added later)
  IntColumn get vehicleId => integer().nullable()();
  // Optional short note, e.g. "Check engine light, oil change"
  TextColumn get note => text().nullable()();
  // 'draft' | 'approved' | 'declined'
  TextColumn get status => text().withDefault(const Constant('draft'))();
  // Tax rate as a percentage, e.g. 8.5 means 8.5%
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class EstimateLineItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which estimate this line belongs to
  IntColumn get estimateId => integer()();
  // 'labor' or 'part'
  TextColumn get type => text()();
  TextColumn get description => text()();
  // Hours for labor, units for parts
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  // Rate per hour for labor, price per unit for parts
  RealColumn get unitPrice => real()();
  // Which vendor this part came from (parts only, optional)
  IntColumn get vendorId => integer().nullable()();
}

class Vendors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get contactName => text().nullable()();
  TextColumn get phone => text().nullable()();
  // The shop's account number with this vendor
  TextColumn get accountNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// A Repair Order is created when a customer approves an estimate and work begins.
// It tracks the lifecycle of the job from open to closed.
class RepairOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which estimate this RO was created from (null if created directly)
  IntColumn get estimateId => integer().nullable()();
  // Which customer
  IntColumn get customerId => integer()();
  // Which vehicle (optional)
  IntColumn get vehicleId => integer().nullable()();
  // Short description of the work, carried over from the estimate
  TextColumn get note => text().nullable()();
  // 'open' | 'in_progress' | 'completed' | 'closed'
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// A single-row table that stores app-wide defaults set by the shop owner.
// The row is always id = 1. We use getOrCreateSettings() to read it safely.
class ShopSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Default hourly labor rate charged to customers, e.g. 120.0
  RealColumn get defaultLaborRate =>
      real().withDefault(const Constant(120.0))();
  // Default parts markup as a percentage, e.g. 30.0 means 30%
  RealColumn get defaultPartsMarkup =>
      real().withDefault(const Constant(30.0))();
}

/// Combined estimate + customer + vehicle — used in the estimate list screen.
class EstimateWithDetails {
  final Estimate estimate;
  final Customer? customer;
  final Vehicle? vehicle;
  EstimateWithDetails({
    required this.estimate,
    this.customer,
    this.vehicle,
  });
}

/// Combined repair order + customer + vehicle — used in the RO list screen.
class RepairOrderWithDetails {
  final RepairOrder ro;
  final Customer? customer;
  final Vehicle? vehicle;
  RepairOrderWithDetails({
    required this.ro,
    this.customer,
    this.vehicle,
  });
}

// ─── Database Class ───────────────────────────────────────────────────────────
// This is the database itself. List every table you defined above inside the
// @DriftDatabase annotation so the generator knows about them.

@DriftDatabase(tables: [
  Customers,
  Vehicles,
  Estimates,
  EstimateLineItems,
  ShopSettings,
  Vendors,
  RepairOrders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Every time you change a table definition, bump this number by 1.
  // Drift uses it to know when to run a migration (update the stored schema).
  @override
  int get schemaVersion => 9;

  // Drift runs this when it finds an older database on the device.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.drop(customers);
        await m.createTable(customers);
      }
      if (from < 3) {
        await m.drop(vehicles);
        await m.createTable(vehicles);
      }
      if (from < 4) {
        await m.createTable(estimates);
        await m.createTable(estimateLineItems);
      }
      if (from < 5) {
        await m.createTable(shopSettings);
      }
      if (from < 6) {
        await m.createTable(vendors); // uses CREATE TABLE IF NOT EXISTS
        // Guard against partial migration: only add column if missing
        final cols = await m.database
            .customSelect(
                "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='supplier_id'")
            .get();
        if (cols.isEmpty) {
          await m.database.customStatement(
              'ALTER TABLE estimate_line_items ADD COLUMN supplier_id INTEGER');
        }
      }
      if (from == 6) {
        // Rename suppliers → vendors and add contact_name column.
        // Only runs when upgrading from exactly v6 — devices that never had
        // a suppliers table get vendors created fresh in the < 6 block above.
        await m.database
            .customStatement('ALTER TABLE suppliers RENAME TO vendors');
        final cols = await m.database
            .customSelect(
                "SELECT name FROM pragma_table_info('vendors') WHERE name='contact_name'")
            .get();
        if (cols.isEmpty) {
          await m.addColumn(vendors, vendors.contactName);
        }
      }
      if (from < 8) {
        // Rename supplier_id → vendor_id to match the vendors table rename.
        await m.database.customStatement(
            'ALTER TABLE estimate_line_items RENAME COLUMN supplier_id TO vendor_id');
      }
      if (from < 9) {
        // Add the repair_orders table.
        await m.createTable(repairOrders);
      }
    },
  );

  // ─── Customer Queries ───────────────────────────────────────────────────────

  // Returns a live stream — the UI rebuilds automatically when data changes.
  Stream<List<Customer>> watchAllCustomers() =>
      (select(customers)..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();

  // Fetches a single customer by id (returns null if not found).
  Future<Customer?> getCustomer(int id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();

  // Adds a new customer row and returns the new row's id.
  Future<int> insertCustomer(CustomersCompanion entry) =>
      into(customers).insert(entry);

  // Replaces all fields on an existing customer row.
  Future<bool> updateCustomer(Customer customer) =>
      update(customers).replace(customer);

  // Permanently removes a customer by id.
  Future<int> deleteCustomer(int id) =>
      (delete(customers)..where((c) => c.id.equals(id))).go();

  // ─── Vehicle Queries ────────────────────────────────────────────────────────

  // Returns a live stream of all vehicles belonging to one customer.
  Stream<List<Vehicle>> watchVehiclesForCustomer(int customerId) =>
      (select(vehicles)..where((v) => v.customerId.equals(customerId))).watch();

  // Fetches a single vehicle by id.
  Future<Vehicle?> getVehicle(int id) =>
      (select(vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();

  // Adds a new vehicle and returns the new row's id.
  Future<int> insertVehicle(VehiclesCompanion entry) =>
      into(vehicles).insert(entry);

  // Replaces all fields on an existing vehicle row.
  Future<bool> updateVehicle(Vehicle vehicle) =>
      update(vehicles).replace(vehicle);

  // Permanently removes a vehicle by id.
  Future<int> deleteVehicle(int id) =>
      (delete(vehicles)..where((v) => v.id.equals(id))).go();

  // ─── Estimate Queries ────────────────────────────────────────────────────────

  // Returns a live stream of all estimates, joined with their customer and
  // vehicle so the list screen can show names without extra lookups.
  Stream<List<EstimateWithDetails>> watchAllEstimates() {
    final q = select(estimates).join([
      leftOuterJoin(customers, customers.id.equalsExp(estimates.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(estimates.vehicleId)),
    ]);
    return q.watch().map((rows) => rows
        .map((row) => EstimateWithDetails(
              estimate: row.readTable(estimates),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Returns a live stream of a single estimate by id.
  Stream<Estimate?> watchEstimate(int id) =>
      (select(estimates)..where((e) => e.id.equals(id))).watchSingleOrNull();

  // Adds a new estimate and returns its new id.
  Future<int> insertEstimate(EstimatesCompanion entry) =>
      into(estimates).insert(entry);

  // Replaces all fields on an existing estimate.
  Future<bool> updateEstimate(Estimate estimate) =>
      update(estimates).replace(estimate);

  // Permanently removes an estimate by id.
  Future<int> deleteEstimate(int id) =>
      (delete(estimates)..where((e) => e.id.equals(id))).go();

  // ─── Line Item Queries ───────────────────────────────────────────────────────

  // Returns a live stream of all line items for one estimate.
  Stream<List<EstimateLineItem>> watchLineItems(int estimateId) =>
      (select(estimateLineItems)
            ..where((l) => l.estimateId.equals(estimateId)))
          .watch();

  // Fetches a single line item by id.
  Future<EstimateLineItem?> getLineItem(int id) =>
      (select(estimateLineItems)..where((l) => l.id.equals(id))).getSingleOrNull();

  // Adds a new line item and returns its new id.
  Future<int> insertLineItem(EstimateLineItemsCompanion entry) =>
      into(estimateLineItems).insert(entry);

  // Replaces all fields on an existing line item.
  Future<bool> updateLineItem(EstimateLineItem item) =>
      update(estimateLineItems).replace(item);

  // Permanently removes a line item by id.
  Future<int> deleteLineItem(int id) =>
      (delete(estimateLineItems)..where((l) => l.id.equals(id))).go();

  // ─── Settings Queries ────────────────────────────────────────────────────────

  // Returns the single settings row, creating it with defaults on first launch.
  Future<ShopSetting> getOrCreateSettings() async {
    final existing = await (select(shopSettings)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    if (existing != null) return existing;
    await into(shopSettings).insert(const ShopSettingsCompanion());
    return (select(shopSettings)..where((s) => s.id.equals(1))).getSingle();
  }

  // Saves (insert or update) the settings row.
  Future<void> saveSettings(ShopSettingsCompanion entry) =>
      into(shopSettings).insertOnConflictUpdate(entry);

  // Live stream of the settings row — UI rebuilds when settings change.
  Stream<ShopSetting?> watchSettings() =>
      (select(shopSettings)..where((s) => s.id.equals(1)))
          .watchSingleOrNull();

  // ─── Vendor Queries ───────────────────────────────────────────────────────

  Stream<List<Vendor>> watchAllVendors() =>
      (select(vendors)..orderBy([(v) => OrderingTerm.asc(v.name)])).watch();

  Future<Vendor?> getVendor(int id) =>
      (select(vendors)..where((v) => v.id.equals(id))).getSingleOrNull();

  Future<int> insertVendor(VendorsCompanion entry) =>
      into(vendors).insert(entry);

  Future<bool> updateVendor(Vendor vendor) =>
      update(vendors).replace(vendor);

  Future<int> deleteVendor(int id) =>
      (delete(vendors)..where((v) => v.id.equals(id))).go();

  // ─── Repair Order Queries ─────────────────────────────────────────────────

  // Returns a live stream of all ROs, joined with customer + vehicle,
  // newest first so the shop always sees the most recent jobs at the top.
  Stream<List<RepairOrderWithDetails>> watchAllRepairOrders() {
    final q = select(repairOrders).join([
      leftOuterJoin(customers, customers.id.equalsExp(repairOrders.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(repairOrders.vehicleId)),
    ]);
    q.orderBy([OrderingTerm.desc(repairOrders.createdAt)]);
    return q.watch().map((rows) => rows
        .map((row) => RepairOrderWithDetails(
              ro: row.readTable(repairOrders),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Returns a live stream of a single RO by id.
  Stream<RepairOrder?> watchRepairOrder(int id) =>
      (select(repairOrders)..where((r) => r.id.equals(id)))
          .watchSingleOrNull();

  // Returns the RO linked to a specific estimate (null if none exists yet).
  // Used by the estimate detail screen to show "Convert to RO" or "View RO".
  Stream<RepairOrder?> watchRoForEstimate(int estimateId) =>
      (select(repairOrders)..where((r) => r.estimateId.equals(estimateId)))
          .watchSingleOrNull();

  // Adds a new repair order and returns its new id.
  Future<int> insertRepairOrder(RepairOrdersCompanion entry) =>
      into(repairOrders).insert(entry);

  // Replaces all fields on an existing repair order.
  Future<bool> updateRepairOrder(RepairOrder ro) =>
      update(repairOrders).replace(ro);

  // Permanently removes a repair order by id.
  Future<int> deleteRepairOrder(int id) =>
      (delete(repairOrders)..where((r) => r.id.equals(id))).go();
}

// Opens (or creates) the SQLite database file on the device.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'autoshoppro.db'));
    return NativeDatabase.createInBackground(file);
  });
}

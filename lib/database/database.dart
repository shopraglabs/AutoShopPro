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

// ─── Database Class ───────────────────────────────────────────────────────────
// This is the database itself. List every table you defined above inside the
// @DriftDatabase annotation so the generator knows about them.

@DriftDatabase(tables: [Customers, Vehicles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Every time you change a table definition, bump this number by 1.
  // Drift uses it to know when to run a migration (update the stored schema).
  @override
  int get schemaVersion => 3;

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
}

// Opens (or creates) the SQLite database file on the device.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'autoshoppro.db'));
    return NativeDatabase.createInBackground(file);
  });
}

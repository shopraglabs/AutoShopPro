import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';

// The single AppDatabase instance shared across the whole app.
// Riverpod creates it once and disposes it when the app closes.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Emits a fresh, sorted list of customers every time the database changes.
// Any screen that watches this will rebuild automatically when a customer
// is added, edited, or deleted.
final customersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(dbProvider).watchAllCustomers();
});

// Emits a single customer (or null) by id — rebuilds when that customer changes.
final customerProvider =
    StreamProvider.family<Customer?, int>((ref, customerId) {
  return ref.watch(dbProvider).watchCustomer(customerId);
});

// Emits a single vehicle (or null) by id — rebuilds when that vehicle changes.
final vehicleProvider =
    StreamProvider.family<Vehicle?, int>((ref, vehicleId) {
  return ref.watch(dbProvider).watchVehicle(vehicleId);
});

// Emits a fresh list of vehicles for a specific customer.
// Pass the customer's id as a parameter.
final vehiclesProvider =
    StreamProvider.family<List<Vehicle>, int>((ref, customerId) {
  return ref.watch(dbProvider).watchVehiclesForCustomer(customerId);
});

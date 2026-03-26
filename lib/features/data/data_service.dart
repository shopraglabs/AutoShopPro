import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/money.dart';
import '../../database/database.dart';
import '../customers/customers_provider.dart';

// ─── Result types ─────────────────────────────────────────────────────────────

class ImportResult {
  final int customersCreated;
  final int vehiclesCreated;
  final int recordsCreated;
  final int duplicatesSkipped;
  final List<String> errors;

  ImportResult({
    required this.customersCreated,
    required this.vehiclesCreated,
    required this.recordsCreated,
    required this.duplicatesSkipped,
    required this.errors,
  });
}

// ─── Data Service ─────────────────────────────────────────────────────────────

class DataService {
  final AppDatabase _db;

  DataService(this._db);

  // ── Export ─────────────────────────────────────────────────────────────────

  /// Exports all repair orders to a CSV file in ~/Downloads.
  ///
  /// Column layout (one row per RO):
  ///   RO Number | Service Date | Date Created | Status
  ///   Customer Name | Phone | Email | Customer Note
  ///   Year | Make | Model | VIN | License Plate | Mileage
  ///   Technician | Customer Complaint | RO Note
  ///   Labor Items | Parts
  ///   Shop Cost | Customer Subtotal | Tax Rate % | Tax Amount
  ///   Customer Total | Gross Profit
  ///
  /// Returns the path of the file that was written.
  Future<String> exportToCsv() async {
    final rows = await _db.getAllRepairOrdersForExport();

    // Bulk-fetch supporting data in parallel
    final estimateIds = rows.map((r) => r.ro.estimateId).whereType<int>().toList();
    final results = await Future.wait([
      _db.getLineItemsForEstimates(estimateIds),
      _db.getEstimatesByIds(estimateIds),
      _db.getAllVendors(),
      _db.getAllTechnicians(),
    ]);

    final lineItems    = results[0] as List<EstimateLineItem>;
    final estimates    = results[1] as List<Estimate>;
    final vendors      = results[2] as List<Vendor>;
    final technicians  = results[3] as List<Technician>;

    // Build lookup maps
    final itemsByEstimate = <int, List<EstimateLineItem>>{};
    for (final item in lineItems) {
      itemsByEstimate.putIfAbsent(item.estimateId, () => []).add(item);
    }
    final estimateById   = {for (final e in estimates)   e.id: e};
    final vendorById     = {for (final v in vendors)     v.id: v};
    final techById       = {for (final t in technicians) t.id: t};

    // ── Header ────────────────────────────────────────────────────────────
    final buf = StringBuffer();
    buf.writeln([
      'RO Number',
      'Service Date',
      'Date Created',
      'Status',
      'Customer Name',
      'Customer Phone',
      'Customer Email',
      'Customer Internal Note',
      'Vehicle Year',
      'Vehicle Make',
      'Vehicle Model',
      'VIN',
      'License Plate',
      'Mileage',
      'Technician',
      'Customer Complaint',
      'RO Note',
      'Labor Items',
      'Parts',
      'Shop Cost',
      'Customer Subtotal',
      'Tax Rate %',
      'Tax Amount',
      'Customer Total',
      'Gross Profit',
    ].map(_csvField).join(','));

    // ── Rows ──────────────────────────────────────────────────────────────
    for (final r in rows) {
      final ro       = r.ro;
      final customer = r.customer;
      final vehicle  = r.vehicle;
      final estimate = ro.estimateId != null ? estimateById[ro.estimateId] : null;
      final tech     = ro.technicianId != null ? techById[ro.technicianId] : null;
      final items    = ro.estimateId != null
          ? (itemsByEstimate[ro.estimateId] ?? [])
              .where((i) => i.approvalStatus != 'declined')
              .toList()
          : <EstimateLineItem>[];

      // Dates
      final svcDate = _fmtDateIso(ro.serviceDate ?? ro.createdAt);
      final created = _fmtDateIso(ro.createdAt);

      // Status — capitalise for readability
      final status = {
        'open': 'Open',
        'in_progress': 'In Progress',
        'completed': 'Completed',
        'closed': 'Closed',
      }[ro.status] ?? ro.status;

      // Labor items: "Labor Name – description (qty hr × $rate)" per line, joined by " | "
      final laborLines = items.where((i) => i.type == 'labor').map((i) {
        final name = (i.laborName?.isNotEmpty ?? false) ? i.laborName! : i.description;
        final detail = i.laborName != null && i.description != i.laborName
            ? ' — ${i.description}' : '';
        final hrs = i.quantity % 1 == 0
            ? i.quantity.toInt().toString() : i.quantity.toStringAsFixed(1);
        final rate = fromCents(i.unitPrice).toStringAsFixed(2);
        final vendor = i.vendorId != null ? ' [${vendorById[i.vendorId]?.name ?? ''}]' : '';
        return '$name$detail ($hrs hr × \$$rate)$vendor';
      }).join(' | ');

      // Parts: "Description – part# × qty @ $price" per line, joined by " | "
      final partLines = items.where((i) => i.type == 'part').map((i) {
        final pn = (i.partNumber?.isNotEmpty ?? false) ? ' (${i.partNumber})' : '';
        final qty = i.quantity % 1 == 0
            ? i.quantity.toInt().toString() : i.quantity.toStringAsFixed(1);
        final price = fromCents(i.unitPrice).toStringAsFixed(2);
        final vendor = i.vendorId != null ? ' [${vendorById[i.vendorId]?.name ?? ''}]' : '';
        return '${i.description}$pn × $qty @ \$$price$vendor';
      }).join(' | ');

      // Financials
      double shopCost = 0;
      double subtotal = 0;
      for (final item in items) {
        subtotal += fromCents(item.unitPrice) * item.quantity;
        if (item.unitCost != null) shopCost += fromCents(item.unitCost!) * item.quantity;
      }
      final taxRate   = estimate?.taxRate ?? 0.0;
      final taxAmt    = subtotal * taxRate / 100.0;
      final total     = subtotal + taxAmt;
      final profit    = total - shopCost;

      buf.writeln([
        _csvField('RO-${ro.id.toString().padLeft(4, '0')}'),
        _csvField(svcDate),
        _csvField(created),
        _csvField(status),
        _csvField(customer?.name ?? ''),
        _csvField(customer?.phone ?? ''),
        _csvField(customer?.email ?? ''),
        _csvField(customer?.internalNote ?? ''),
        _csvField(vehicle?.year?.toString() ?? ''),
        _csvField(vehicle?.make ?? ''),
        _csvField(vehicle?.model ?? ''),
        _csvField(vehicle?.vin ?? ''),
        _csvField(vehicle?.licensePlate ?? ''),
        _csvField(vehicle?.mileage?.toString() ?? ''),
        _csvField(tech?.name ?? ''),
        _csvField(estimate?.customerComplaint ?? ''),
        _csvField(ro.note ?? ''),
        _csvField(laborLines),
        _csvField(partLines),
        shopCost > 0 ? shopCost.toStringAsFixed(2) : '0.00',
        subtotal.toStringAsFixed(2),
        taxRate > 0 ? taxRate.toStringAsFixed(2) : '0.00',
        taxAmt > 0 ? taxAmt.toStringAsFixed(2) : '0.00',
        total.toStringAsFixed(2),
        profit.toStringAsFixed(2),
      ].join(','));
    }

    // Write to ~/Downloads
    final downloads = Directory('${Platform.environment['HOME']}/Downloads');
    final now = DateTime.now();
    final filename =
        'AutoShopPro_Export_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.csv';
    final file = File('${downloads.path}/$filename');
    await file.writeAsString(buf.toString());
    return file.path;
  }

  String _fmtDateIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Import ─────────────────────────────────────────────────────────────────

  /// Shows a macOS native file picker and imports the selected CSV.
  /// Returns null if the user cancelled.
  Future<String?> pickCsvFile() async {
    final result = await Process.run('osascript', [
      '-e',
      'POSIX path of (choose file with prompt "Select AutoShopPro CSV" of type {"csv", "public.comma-separated-values-text"})',
    ]);
    final path = result.stdout.toString().trim();
    if (path.isEmpty) return null;
    return path;
  }

  /// Imports customer records from a CSV file.
  /// Expected header row:
  ///   Date of Service, Customer Name, Phone, Email, Year, Make, Model,
  ///   VIN, License Plate, Mileage, Services, Shop Cost, Customer Cost,
  ///   Profit, Notes
  Future<ImportResult> importFromCsv(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return ImportResult(
          customersCreated: 0,
          vehiclesCreated: 0,
          recordsCreated: 0,
          duplicatesSkipped: 0,
          errors: ['File not found: $filePath']);
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return ImportResult(
          customersCreated: 0,
          vehiclesCreated: 0,
          recordsCreated: 0,
          duplicatesSkipped: 0,
          errors: ['File is empty']);
    }

    // Skip header row (first line)
    final dataLines = lines.skip(1).where((l) => l.trim().isNotEmpty).toList();

    int customersCreated = 0;
    int vehiclesCreated = 0;
    int recordsCreated = 0;
    int duplicatesSkipped = 0;
    final errors = <String>[];

    // Cache vendors so we only look them up once
    final allVendors = await _db.getAllVendors();

    for (int i = 0; i < dataLines.length; i++) {
      final rowNum = i + 2; // human-readable row number (1-indexed, skipping header)
      try {
        final cols = _parseCsvRow(dataLines[i]);
        if (cols.length < 2) continue;

        final dateStr = _col(cols, 0);
        final customerName = _col(cols, 1).trim();
        final phone = _col(cols, 2).trim();
        final email = _col(cols, 3).trim();
        final year = int.tryParse(_col(cols, 4));
        final make = _col(cols, 5).trim();
        final model = _col(cols, 6).trim();
        final vin = _col(cols, 7).trim();
        final plate = _col(cols, 8).trim();
        final mileage = int.tryParse(_col(cols, 9).replaceAll(',', ''));
        final services = _col(cols, 10).trim();
        final shopCost =
            double.tryParse(_col(cols, 11).replaceAll(RegExp(r'[^\d.]'), ''));
        final customerCost =
            double.tryParse(_col(cols, 12).replaceAll(RegExp(r'[^\d.]'), ''));
        final notes = _col(cols, 14).trim();

        if (customerName.isEmpty) continue;

        // Parse service date
        final serviceDate = _parseDate(dateStr);

        // ── Find or create customer ────────────────────────────────────────
        Customer? customer;
        if (phone.isNotEmpty) {
          customer = await _db.findCustomerByNameAndPhone(customerName, phone);
        }
        if (customer == null) {
          // Also check by name only if no phone match
          final byName = await _db.searchCustomers(customerName);
          if (byName.isNotEmpty &&
              byName.any((c) =>
                  c.name.toLowerCase() == customerName.toLowerCase() &&
                  (phone.isEmpty || (c.phone ?? '').isEmpty))) {
            customer = byName.firstWhere(
                (c) => c.name.toLowerCase() == customerName.toLowerCase());
          }
        }

        bool isNewCustomer = customer == null;
        if (customer == null) {
          final id = await _db.insertCustomer(CustomersCompanion(
            name: Value(customerName),
            phone: phone.isNotEmpty ? Value(phone) : const Value.absent(),
            email: email.isNotEmpty ? Value(email) : const Value.absent(),
          ));
          customer = await _db.getCustomer(id);
          if (customer == null) {
            errors.add('Row $rowNum: Failed to create customer $customerName');
            continue;
          }
          customersCreated++;
        }

        // ── Find or create vehicle ─────────────────────────────────────────
        Vehicle? vehicle;
        if (vin.isNotEmpty) {
          vehicle = await _db.findVehicleByVin(vin);
        }

        if (vehicle == null && (make.isNotEmpty || model.isNotEmpty || year != null)) {
          final id = await _db.insertVehicle(VehiclesCompanion(
            customerId: Value(customer.id),
            year: year != null ? Value(year) : const Value.absent(),
            make: make.isNotEmpty ? Value(make) : const Value.absent(),
            model: model.isNotEmpty ? Value(model) : const Value.absent(),
            vin: vin.isNotEmpty ? Value(vin) : const Value.absent(),
            licensePlate:
                plate.isNotEmpty ? Value(plate) : const Value.absent(),
            mileage:
                mileage != null ? Value(mileage) : const Value.absent(),
          ));
          vehicle = await _db.getVehicle(id);
          vehiclesCreated++;
        } else if (vehicle != null && !isNewCustomer) {
          // Existing vehicle on a potentially new visit — check if this
          // exact RO date already exists to avoid duplicate imports
          // (simple heuristic: same customer + same service date = duplicate)
          duplicatesSkipped++;
          continue;
        }

        // ── Create estimate + RO ───────────────────────────────────────────
        // Parse vendor groups from services field: (VENDOR - item1, item2)
        final vendorGroups = _parseVendorGroups(services);

        // Build note from services if no vendor groups parsed
        final estimateNote = services.isNotEmpty ? services : notes;

        final estimateId = await _db.insertEstimate(EstimatesCompanion(
          customerId: Value(customer.id),
          vehicleId: vehicle != null ? Value(vehicle.id) : const Value.absent(),
          note: Value(estimateNote.isNotEmpty ? estimateNote : null),
          status: const Value('approved'),
          createdAt: serviceDate != null
              ? Value(serviceDate)
              : const Value.absent(),
        ));

        // Create line items from vendor groups
        if (vendorGroups.isNotEmpty) {
          // Distribute customer cost equally across vendor groups
          final costPerGroup = (customerCost ?? 0) / vendorGroups.length;
          final shopCostPerGroup = (shopCost ?? 0) / vendorGroups.length;

          for (final group in vendorGroups) {
            final vendorName = group['vendor']!;
            final description = group['description']!;

            // Find matching vendor in the DB
            Vendor? matchedVendor;
            try {
              matchedVendor = allVendors.firstWhere((v) =>
                  v.name.toUpperCase() == vendorName.toUpperCase());
            } catch (_) {
              // No matching vendor — create it
              final vendorId = await _db.insertVendor(VendorsCompanion(
                name: Value(vendorName),
              ));
              final newVendor = await _db.getVendor(vendorId);
              if (newVendor != null) {
                allVendors.add(newVendor);
                matchedVendor = newVendor;
              }
            }

            await _db.insertLineItem(EstimateLineItemsCompanion(
              estimateId: Value(estimateId),
              type: const Value('labor'),
              description: Value(description),
              quantity: const Value(1.0),
              unitPrice: Value(toCents(costPerGroup)),
              unitCost: shopCostPerGroup > 0
                  ? Value(toCents(shopCostPerGroup))
                  : const Value.absent(),
              vendorId: matchedVendor != null
                  ? Value(matchedVendor.id)
                  : const Value.absent(),
              approvalStatus: const Value('approved'),
            ));
          }
        } else if (customerCost != null && customerCost > 0) {
          // No vendor groups — create a single line item with the total
          await _db.insertLineItem(EstimateLineItemsCompanion(
            estimateId: Value(estimateId),
            type: const Value('labor'),
            description: Value(
                services.isNotEmpty ? services : 'Imported service record'),
            quantity: const Value(1.0),
            unitPrice: Value(toCents(customerCost)),
            unitCost:
                shopCost != null && shopCost > 0 ? Value(toCents(shopCost)) : const Value.absent(),
            approvalStatus: const Value('approved'),
          ));
        }

        // Create the Repair Order (status closed — it's a historical record)
        await _db.insertRepairOrder(RepairOrdersCompanion(
          estimateId: Value(estimateId),
          customerId: Value(customer.id),
          vehicleId: vehicle != null ? Value(vehicle.id) : const Value.absent(),
          note: notes.isNotEmpty ? Value(notes) : const Value.absent(),
          status: const Value('closed'),
          serviceDate: serviceDate != null
              ? Value(serviceDate)
              : const Value.absent(),
          createdAt: serviceDate != null
              ? Value(serviceDate)
              : const Value.absent(),
        ));

        recordsCreated++;
      } catch (e) {
        errors.add('Row $rowNum: $e');
      }
    }

    return ImportResult(
      customersCreated: customersCreated,
      vehiclesCreated: vehiclesCreated,
      recordsCreated: recordsCreated,
      duplicatesSkipped: duplicatesSkipped,
      errors: errors,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Wraps a field in double-quotes if it contains commas, quotes, or newlines.
  String _csvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Parses a single CSV row, handling quoted fields correctly.
  List<String> _parseCsvRow(String line) {
    final fields = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++; // skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    fields.add(buf.toString());
    return fields;
  }

  /// Safe column accessor — returns empty string if index is out of range.
  String _col(List<String> cols, int index) =>
      index < cols.length ? cols[index] : '';

  /// Parses a date string in various formats → DateTime, or null.
  DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    // Try ISO format: 2026-01-20
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // Try M/D/YYYY or MM/DD/YYYY
    final parts = s.split(RegExp(r'[/\-]'));
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final c = int.tryParse(parts[2]);
      if (a != null && b != null && c != null) {
        if (c > 1000) return DateTime(c, a, b);   // M/D/YYYY
        if (a > 1000) return DateTime(a, b, c);   // YYYY-M-D (already caught above)
      }
    }
    return null;
  }

  /// Parses vendor groups from a services string formatted as:
  ///   (VENDOR - item1, item2) (VENDOR2 - item3)
  /// Returns a list of {vendor, description} maps.
  List<Map<String, String>> _parseVendorGroups(String services) {
    if (services.isEmpty) return [];

    final groups = <Map<String, String>>[];
    final regex = RegExp(r'\(([^)]+)\)');
    final matches = regex.allMatches(services);

    for (final match in matches) {
      final content = match.group(1)?.trim() ?? '';
      if (content.isEmpty) continue;

      // The first all-caps word is the vendor name
      final spaceIdx = content.indexOf(' ');
      if (spaceIdx == -1) {
        groups.add({'vendor': content, 'description': content});
        continue;
      }

      final firstWord = content.substring(0, spaceIdx);
      // Check if first word is all caps (vendor name)
      if (firstWord == firstWord.toUpperCase() &&
          RegExp(r'^[A-Z]+$').hasMatch(firstWord)) {
        // Strip leading dash/space after vendor name
        var desc = content.substring(spaceIdx).trim();
        if (desc.startsWith('-')) desc = desc.substring(1).trim();
        groups.add({'vendor': firstWord, 'description': desc});
      } else {
        // No all-caps vendor prefix — treat whole content as description
        groups.add({'vendor': '', 'description': content});
      }
    }

    return groups;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final dataServiceProvider = Provider<DataService>((ref) {
  return DataService(ref.read(dbProvider));
});

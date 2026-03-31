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
//
// MONEY COLUMNS — stored as INTEGER cents (e.g. $120.00 → 12000).
// Use toCents() before writing and fromCents() after reading.
// See lib/core/utils/money.dart.

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  // Shop-facing note about this customer (e.g. "Fleet account, net-30 terms")
  TextColumn get internalNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which customer owns this vehicle
  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();
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
  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();
  // Which vehicle (optional — can be added later)
  IntColumn get vehicleId => integer().nullable()
      .references(Vehicles, #id, onDelete: KeyAction.setNull)();
  // What the customer says is wrong — captured at write-up
  TextColumn get customerComplaint => text().nullable()();
  // Optional internal note
  TextColumn get note => text().nullable()();
  // 'draft' | 'approved' | 'declined'
  TextColumn get status => text().withDefault(const Constant('draft'))();
  // Tax rate as a percentage, e.g. 8.5 means 8.5%  (REAL — not money)
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  // The date shown on the estimate (editable). Null = use createdAt for display.
  DateTimeColumn get estimateDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class EstimateLineItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which estimate this line belongs to
  IntColumn get estimateId =>
      integer().references(Estimates, #id, onDelete: KeyAction.cascade)();
  // 'labor' | 'part' | 'other'
  TextColumn get type => text()();
  TextColumn get description => text()();
  // Hours for labor, units for parts (REAL — not money)
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  // What the shop charges the customer — INTEGER CENTS
  // (rate/hr for labor, list price for parts/other)
  IntColumn get unitPrice => integer()();
  // What the shop paid for the part — INTEGER CENTS (parts only, optional)
  IntColumn get unitCost => integer().nullable()();
  // Which vendor this part came from (parts only, optional)
  IntColumn get vendorId => integer().nullable()
      .references(Vendors, #id, onDelete: KeyAction.setNull)();
  // Which labor line this part is associated with (parts only, optional)
  IntColumn get parentLaborId => integer().nullable()();
  // Whether this item has been marked done on the repair order (null = not done)
  BoolColumn get isDone => boolean().nullable()();
  // Customer approval status: null = pending, 'approved', 'declined'
  TextColumn get approvalStatus => text().nullable()();
  // Which inventory part this line item was sourced from (null = not from catalog)
  IntColumn get inventoryPartId => integer().nullable()
      .references(InventoryParts, #id, onDelete: KeyAction.setNull)();
  // Short name for a labor line (e.g. "Oil Change"). Separate from description
  // which holds the detailed operation text. Null on old rows and parts.
  TextColumn get laborName => text().nullable()();
  // Part number (parts only, optional). e.g. "ACDelco 41-993"
  TextColumn get partNumber => text().nullable()();
}

class Vendors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get contactName => text().nullable()();
  TextColumn get phone => text().nullable()();
  // The shop's account number with this vendor
  TextColumn get accountNumber => text().nullable()();
  // Soft-delete: archived vendors stay in DB (existing line items still reference
  // them) but are hidden from lists and pickers.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// A Repair Order is created when a customer approves an estimate and work begins.
// It tracks the lifecycle of the job from open to closed.
class RepairOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Which estimate this RO was created from (null if created directly)
  IntColumn get estimateId => integer().nullable()
      .references(Estimates, #id, onDelete: KeyAction.setNull)();
  // Which customer
  IntColumn get customerId =>
      integer().references(Customers, #id, onDelete: KeyAction.cascade)();
  // Which vehicle (optional)
  IntColumn get vehicleId => integer().nullable()
      .references(Vehicles, #id, onDelete: KeyAction.setNull)();
  // Short description of the work, carried over from the estimate
  TextColumn get note => text().nullable()();
  // 'open' | 'closed'
  TextColumn get status => text().withDefault(const Constant('open'))();
  // Which technician is assigned to this RO (optional)
  IntColumn get technicianId => integer().nullable()
      .references(Technicians, #id, onDelete: KeyAction.setNull)();
  // The actual date the work was performed — separate from createdAt (entry date).
  // Null means not set; defaults to createdAt for display purposes.
  DateTimeColumn get serviceDate => dateTime().nullable()();
  // Optional comment printed on the invoice (e.g. warranty notes, terms).
  TextColumn get comment => text().nullable()();
  // Tax rate snapshotted at RO creation time — stored as basis points (int).
  // e.g. 8.5% → 850. Copied from estimates.taxRate on conversion.
  // Prevents reprints from showing 0% tax if the estimate is later deleted.
  // NULL on ROs that predate v33 (falls back to estimate.taxRate at display time).
  IntColumn get taxRateBps => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Parts the shop keeps in inventory. Stock levels drive the low-stock warnings.
class InventoryParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  // The part's catalog or SKU number, e.g. "BP-4502"
  TextColumn get partNumber => text().nullable()();
  // Human-readable description, e.g. "Front Brake Pads"
  TextColumn get description => text()();
  // Category: "Part", "Fluid", "Filter", "Chemical" — null treated as "Part"
  TextColumn get category => text().nullable()();
  // What the shop paid for this part — INTEGER CENTS
  IntColumn get cost => integer().withDefault(const Constant(0))();
  // What the shop charges the customer for this part — INTEGER CENTS
  IntColumn get sellPrice => integer().withDefault(const Constant(0))();
  // How many are currently on the shelf
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  // Quantity at or below which we show a "Low Stock" warning (default 2)
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(2))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Parts (from inventory) linked to a service template.
// When a template is applied to an estimate, these are auto-added as part lines.
class ServiceTemplateParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  // The template this part belongs to
  IntColumn get templateId =>
      integer().references(ServiceTemplates, #id, onDelete: KeyAction.cascade)();
  // The inventory part being linked
  IntColumn get inventoryPartId =>
      integer().references(InventoryParts, #id, onDelete: KeyAction.cascade)();
  // How many of this part are needed for the job (default 1)  (REAL — not money)
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
}

// A technician who works at the shop. ROs can be assigned to a technician.
class Technicians extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // e.g. "Engine", "Brakes", "Electrical"
  TextColumn get specialty => text().nullable()();
  TextColumn get phone => text().nullable()();
  // Soft-delete: archived technicians stay in DB (existing ROs still reference
  // them) but are hidden from lists and pickers.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// A single-row table that stores app-wide defaults set by the shop owner.
// The row is always id = 1. We use getOrCreateSettings() to read it safely.
class ShopSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  // The shop's name — shown on invoices and reports
  TextColumn get shopName => text().nullable()();
  // Default hourly labor rate charged to customers — INTEGER CENTS
  // e.g. 12000 = $120.00 / hr
  IntColumn get defaultLaborRate =>
      integer().withDefault(const Constant(12000))();
  // Default parts markup as a percentage, e.g. 30.0 means 30%  (REAL — not money)
  // Kept for backwards compatibility — markup rules take precedence when set
  RealColumn get defaultPartsMarkup =>
      real().withDefault(const Constant(30.0))();
  // Default tax rate applied to new estimates, e.g. 8.5 means 8.5%  (REAL — not money)
  RealColumn get defaultTaxRate => real().withDefault(const Constant(0.0))();
  // Shop contact info — printed on invoice headers (required by law in many states)
  TextColumn get shopAddress => text().nullable()();
  TextColumn get shopPhone => text().nullable()();
  TextColumn get shopEmail => text().nullable()();
}

// A reusable service template — e.g. "Oil Change", "Tire Rotation".
// When applied to an estimate it adds a pre-filled labor line in one tap.
class ServiceTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Display name shown in the picker, e.g. "Oil Change"
  TextColumn get name => text()();
  // The labor line description added to the estimate, e.g. "Oil and Filter Change"
  TextColumn get laborDescription => text()();
  // Default number of hours for this job  (REAL — not money)
  RealColumn get defaultHours => real().withDefault(const Constant(1.0))();
  // Optional override rate — null means use the shop's default labor rate
  // INTEGER CENTS, e.g. 9500 = $95.00 / hr
  IntColumn get defaultRate => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Tiered markup rules: parts within a cost range get a specific markup %.
// Rows are ordered by minCost. The first matching rule wins.
class MarkupRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Lower bound of the part cost range (inclusive) — INTEGER CENTS
  // e.g. 0 = $0.00
  IntColumn get minCost => integer()();
  // Upper bound of the part cost range (exclusive) — INTEGER CENTS
  // Null = no upper limit.
  IntColumn get maxCost => integer().nullable()();
  // Markup percentage to apply, e.g. 50.0 means 50%  (REAL — not money)
  RealColumn get markupPercent => real()();
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
  Technicians,
  InventoryParts,
  MarkupRules,
  ServiceTemplates,
  ServiceTemplateParts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Every time you change a table definition, bump this number by 1.
  // Drift uses it to know when to run a migration (update the stored schema).
  @override
  int get schemaVersion => 34;

  // Drift runs this when it finds an older database on the device.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Enable SQLite foreign key enforcement.
      // This enforces FK constraints on tables created with REFERENCES clauses.
      // Fresh installs get full FK enforcement. Existing tables get it on
      // recreation. Manual Dart cascade-deletes remain as a safety net.
      await customStatement('PRAGMA foreign_keys = ON');
    },
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
      if (from == 7) {
        // Rename supplier_id → vendor_id to match the vendors table rename.
        // Must use from == 7 (not from < 8) — RENAME runs exactly once.
        // Using from < 8 would re-run on devices upgrading from v1–v5,
        // trying to rename a column that doesn't exist yet and crashing.
        await m.database.customStatement(
            'ALTER TABLE estimate_line_items RENAME COLUMN supplier_id TO vendor_id');
      }
      if (from < 9) {
        // Add the repair_orders table.
        await m.createTable(repairOrders);
      }
      if (from < 10) {
        // Added in v10: unit_cost and parent_labor_id on estimate_line_items.
        final costCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='unit_cost'")
            .get();
        if (costCol.isEmpty) {
          await m.database.customStatement(
              'ALTER TABLE estimate_line_items ADD COLUMN unit_cost REAL');
        }
        final laborCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='parent_labor_id'")
            .get();
        if (laborCol.isEmpty) {
          await m.database.customStatement(
              'ALTER TABLE estimate_line_items ADD COLUMN parent_labor_id INTEGER');
        }
      }
      if (from < 11) {
        // Added in v11: customer_complaint on estimates.
        final col = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('estimates') WHERE name='customer_complaint'")
            .get();
        if (col.isEmpty) {
          await m.addColumn(estimates, estimates.customerComplaint);
        }
      }
      if (from < 12) {
        // Added in v12: internal_note on customers, is_done on estimate_line_items.
        final noteCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('customers') WHERE name='internal_note'")
            .get();
        if (noteCol.isEmpty) {
          await m.addColumn(customers, customers.internalNote);
        }
        final doneCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='is_done'")
            .get();
        if (doneCol.isEmpty) {
          await m.addColumn(estimateLineItems, estimateLineItems.isDone);
        }
      }
      if (from < 13) {
        // Added in v13: approval_status on estimate_line_items.
        final approvalCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='approval_status'")
            .get();
        if (approvalCol.isEmpty) {
          await m.addColumn(estimateLineItems, estimateLineItems.approvalStatus);
        }
      }
      if (from < 14) {
        // Added in v14: technicians table + technician_id on repair_orders.
        await m.createTable(technicians);
        final techCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('repair_orders') WHERE name='technician_id'")
            .get();
        if (techCol.isEmpty) {
          await m.addColumn(repairOrders, repairOrders.technicianId);
        }
      }
      if (from < 15) {
        // Added in v15: inventory_parts table.
        await m.createTable(inventoryParts);
      }
      if (from < 16) {
        // Added in v16: inventory_part_id on estimate_line_items.
        final col = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='inventory_part_id'")
            .get();
        if (col.isEmpty) {
          await m.database.customStatement(
              'ALTER TABLE estimate_line_items ADD COLUMN inventory_part_id INTEGER');
        }
      }
      if (from < 17) {
        // Added in v17: markup_rules table + shop_name and default_tax_rate on shop_settings.
        await m.createTable(markupRules);
        final nameCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('shop_settings') WHERE name='shop_name'")
            .get();
        if (nameCol.isEmpty) {
          await m.addColumn(shopSettings, shopSettings.shopName);
        }
        final taxCol = await m.database.customSelect(
            "SELECT name FROM pragma_table_info('shop_settings') WHERE name='default_tax_rate'")
            .get();
        if (taxCol.isEmpty) {
          await m.addColumn(shopSettings, shopSettings.defaultTaxRate);
        }
      }
      if (from < 18) {
        // Added in v18: service_templates table for premade service presets.
        await m.createTable(serviceTemplates);
      }
      if (from < 19) {
        // Added in v19: laborName on estimate_line_items for labor job title.
        final cols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='labor_name'",
        ).get();
        if (cols.isEmpty) {
          await m.addColumn(estimateLineItems, estimateLineItems.laborName);
        }
      }
      if (from < 20) {
        // Added in v20: category on inventory_parts + service_template_parts table.
        final catCol = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('inventory_parts') WHERE name='category'",
        ).get();
        if (catCol.isEmpty) {
          await m.addColumn(inventoryParts, inventoryParts.category);
        }
        await m.createTable(serviceTemplateParts);
      }
      if (from < 21) {
        // Added in v21: part_number on estimate_line_items.
        final cols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('estimate_line_items') WHERE name='part_number'",
        ).get();
        if (cols.isEmpty) {
          await m.addColumn(estimateLineItems, estimateLineItems.partNumber);
        }
      }
      if (from < 22) {
        // Added in v22: service_date on repair_orders (actual date work was done).
        final cols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('repair_orders') WHERE name='service_date'",
        ).get();
        if (cols.isEmpty) {
          await m.addColumn(repairOrders, repairOrders.serviceDate);
        }
      }
      if (from < 23) {
        // Added in v23: comment on repair_orders (printed on invoice).
        final cols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('repair_orders') WHERE name='comment'",
        ).get();
        if (cols.isEmpty) {
          await m.addColumn(repairOrders, repairOrders.comment);
        }
      }
      if (from < 24) {
        // Added in v24: estimateDate on estimates (editable display date).
        final cols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('estimates') WHERE name='estimate_date'",
        ).get();
        if (cols.isEmpty) {
          await m.addColumn(estimates, estimates.estimateDate);
        }
      }
      if (from < 25) {
        // Added in v25: isArchived on vendors + technicians (soft-delete).
        final vendorCols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('vendors') WHERE name='is_archived'",
        ).get();
        if (vendorCols.isEmpty) {
          await m.addColumn(vendors, vendors.isArchived);
        }
        final techCols = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('technicians') WHERE name='is_archived'",
        ).get();
        if (techCols.isEmpty) {
          await m.addColumn(technicians, technicians.isArchived);
        }
      }
      if (from < 26) {
        // v26: Convert money columns from REAL (dollars) to INTEGER (cents).
        // Multiply existing values × 100 during copy.
        // Five tables are recreated: estimate_line_items, inventory_parts,
        // shop_settings, service_templates, markup_rules.
        //
        // We temporarily disable FK checks for the recreation (they don't
        // exist on the old tables anyway) then re-enable after.
        await m.database.customStatement('PRAGMA foreign_keys = OFF');

        // ── estimate_line_items ──────────────────────────────────────────
        await m.database.customStatement('''
          CREATE TABLE estimate_line_items_v26 (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            estimate_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            description TEXT NOT NULL,
            quantity REAL NOT NULL DEFAULT 1.0,
            unit_price INTEGER NOT NULL,
            unit_cost INTEGER,
            vendor_id INTEGER,
            parent_labor_id INTEGER,
            is_done INTEGER,
            approval_status TEXT,
            inventory_part_id INTEGER,
            labor_name TEXT,
            part_number TEXT
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO estimate_line_items_v26
            SELECT id, estimate_id, type, description, quantity,
              CAST(ROUND(unit_price * 100) AS INTEGER),
              CASE WHEN unit_cost IS NULL THEN NULL
                   ELSE CAST(ROUND(unit_cost * 100) AS INTEGER) END,
              vendor_id, parent_labor_id, is_done, approval_status,
              inventory_part_id, labor_name, part_number
            FROM estimate_line_items
        ''');
        await m.database
            .customStatement('DROP TABLE estimate_line_items');
        await m.database.customStatement(
            'ALTER TABLE estimate_line_items_v26 RENAME TO estimate_line_items');

        // ── inventory_parts ──────────────────────────────────────────────
        await m.database.customStatement('''
          CREATE TABLE inventory_parts_v26 (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            part_number TEXT,
            description TEXT NOT NULL,
            category TEXT,
            cost INTEGER NOT NULL DEFAULT 0,
            sell_price INTEGER NOT NULL DEFAULT 0,
            stock_qty INTEGER NOT NULL DEFAULT 0,
            low_stock_threshold INTEGER NOT NULL DEFAULT 2,
            created_at INTEGER NOT NULL
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO inventory_parts_v26
            SELECT id, part_number, description, category,
              CAST(ROUND(cost * 100) AS INTEGER),
              CAST(ROUND(sell_price * 100) AS INTEGER),
              stock_qty, low_stock_threshold, created_at
            FROM inventory_parts
        ''');
        await m.database.customStatement('DROP TABLE inventory_parts');
        await m.database.customStatement(
            'ALTER TABLE inventory_parts_v26 RENAME TO inventory_parts');

        // ── shop_settings ────────────────────────────────────────────────
        await m.database.customStatement('''
          CREATE TABLE shop_settings_v26 (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            shop_name TEXT,
            default_labor_rate INTEGER NOT NULL DEFAULT 12000,
            default_parts_markup REAL NOT NULL DEFAULT 30.0,
            default_tax_rate REAL NOT NULL DEFAULT 0.0
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO shop_settings_v26
            SELECT id, shop_name,
              CAST(ROUND(default_labor_rate * 100) AS INTEGER),
              default_parts_markup,
              default_tax_rate
            FROM shop_settings
        ''');
        await m.database.customStatement('DROP TABLE shop_settings');
        await m.database.customStatement(
            'ALTER TABLE shop_settings_v26 RENAME TO shop_settings');

        // ── service_templates ────────────────────────────────────────────
        await m.database.customStatement('''
          CREATE TABLE service_templates_v26 (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            labor_description TEXT NOT NULL,
            default_hours REAL NOT NULL DEFAULT 1.0,
            default_rate INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO service_templates_v26
            SELECT id, name, labor_description, default_hours,
              CASE WHEN default_rate IS NULL THEN NULL
                   ELSE CAST(ROUND(default_rate * 100) AS INTEGER) END,
              created_at
            FROM service_templates
        ''');
        await m.database.customStatement('DROP TABLE service_templates');
        await m.database.customStatement(
            'ALTER TABLE service_templates_v26 RENAME TO service_templates');

        // ── markup_rules ─────────────────────────────────────────────────
        await m.database.customStatement('''
          CREATE TABLE markup_rules_v26 (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            min_cost INTEGER NOT NULL,
            max_cost INTEGER,
            markup_percent REAL NOT NULL
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO markup_rules_v26
            SELECT id,
              CAST(ROUND(min_cost * 100) AS INTEGER),
              CASE WHEN max_cost IS NULL THEN NULL
                   ELSE CAST(ROUND(max_cost * 100) AS INTEGER) END,
              markup_percent
            FROM markup_rules
        ''');
        await m.database.customStatement('DROP TABLE markup_rules');
        await m.database.customStatement(
            'ALTER TABLE markup_rules_v26 RENAME TO markup_rules');

        await m.database.customStatement('PRAGMA foreign_keys = ON');
      }
      if (from < 30) {
        // v30: Clear corrupted service dates on all imported ROs (IDs 1–12).
        // The original import had a year-parsing bug (year 58023). Every prior
        // migration attempt to recover the month/day also produced wrong values.
        // The exported Numbers file dates were equally corrupted.
        // Solution: NULL service_date so each RO shows "—" and the user can
        // tap in to set the correct date manually.
        // created_at is set to 2026-01-01 (ms=1767225600000) as a neutral
        // placeholder so the record is sortable and the year guard passes.
        await m.database.customStatement('UPDATE repair_orders SET service_date = NULL, created_at = 1767225600000 WHERE id IN (1,2,3,4,5,6,7,8,9,10,11,12)');
        await m.database.customStatement('UPDATE estimates SET created_at = 1767225600000 WHERE id IN (SELECT estimate_id FROM repair_orders WHERE id IN (1,2,3,4,5,6,7,8,9,10,11,12) AND estimate_id IS NOT NULL)');
      }
      if (from == 28) {
        // v29: Directly stamp each known RO with its correct service date.
        // Values are ms-since-epoch (UTC) from AutoShopPro_Export_2026-03-27.numbers.
        // No safety-net logic — just targeted per-row updates.
        const roFixes = [
          [1,  1790553600000],  // 2026-09-28
          [2,  1794182400000],  // 2026-11-09
          [3,  1792627200000],  // 2026-10-22
          [4,  1797897600000],  // 2026-12-22
          [5,  1779840000000],  // 2026-05-27
          [6,  1778371200000],  // 2026-05-10
          [7,  1793318400000],  // 2026-10-30
          [8,  1775260800000],  // 2026-04-04
          [9,  1775260800000],  // 2026-04-04
          [10, 1773705600000],  // 2026-03-17
          [11, 1773878400000],  // 2026-03-19
          [12, 1774224000000],  // 2026-03-23
        ];
        for (final pair in roFixes) {
          final roId = pair[0];
          final ms   = pair[1];
          await m.database.customStatement(
            'UPDATE repair_orders SET service_date = $ms, created_at = $ms WHERE id = $roId',
          );
          await m.database.customStatement(
            'UPDATE estimates SET created_at = $ms WHERE id = (SELECT estimate_id FROM repair_orders WHERE id = $roId)',
          );
        }
      }
      if (from == 27) {
        // v28: Set exact correct service dates sourced from the shop's export file.
        // The v27 migration failed to preserve month/day because Dart's DateTime
        // round-trip is unreliable for year-58023 ms values on macOS.
        // All values below are ms-since-epoch (UTC) computed directly from the
        // AutoShopPro_Export_2026-03-27.numbers file — no Dart DateTime involved.
        //
        //  RO-0001  2026-09-28  1790553600000
        //  RO-0002  2026-11-09  1794182400000
        //  RO-0003  2026-10-22  1792627200000
        //  RO-0004  2026-12-22  1797897600000
        //  RO-0005  2026-05-27  1779840000000
        //  RO-0006  2026-05-10  1778371200000
        //  RO-0007  2026-10-30  1793318400000
        //  RO-0008  2026-04-04  1775260800000
        //  RO-0009  2026-04-04  1775260800000
        //  RO-0010  2026-03-17  1773705600000
        //  RO-0011  2026-03-19  1773878400000
        //  RO-0012  2026-03-23  1774224000000

        final roDateMs = {
           1: 1790553600000,
           2: 1794182400000,
           3: 1792627200000,
           4: 1797897600000,
           5: 1779840000000,
           6: 1778371200000,
           7: 1793318400000,
           8: 1775260800000,
           9: 1775260800000,
          10: 1773705600000,
          11: 1773878400000,
          12: 1774224000000,
        };

        for (final entry in roDateMs.entries) {
          final roId = entry.key;
          final ms   = entry.value;
          // Fix service_date and created_at on the repair order.
          await m.database.customStatement(
            'UPDATE repair_orders SET service_date = $ms, created_at = $ms WHERE id = $roId',
          );
          // Fix created_at on the linked estimate so its display date also matches.
          await m.database.customStatement('''
            UPDATE estimates
            SET created_at = $ms
            WHERE id = (SELECT estimate_id FROM repair_orders WHERE id = $roId)
          ''');
        }

        // Safety net: NULL any remaining service_dates still outside 1900-2100,
        // and set created_at to Jan 1, 2026 for any other corrupted rows.
        const minMs   = -2208988800000;
        const maxMs   =  4102444800000;
        const jan2026 =  1767225600000;

        await m.database.customStatement('''
          UPDATE repair_orders SET service_date = NULL
          WHERE service_date IS NOT NULL AND (service_date < $minMs OR service_date > $maxMs)
        ''');
        await m.database.customStatement('''
          UPDATE repair_orders SET created_at = $jan2026
          WHERE created_at < $minMs OR created_at > $maxMs
        ''');
        await m.database.customStatement('''
          UPDATE estimates SET estimate_date = NULL
          WHERE estimate_date IS NOT NULL AND (estimate_date < $minMs OR estimate_date > $maxMs)
        ''');
        await m.database.customStatement('''
          UPDATE estimates SET created_at = $jan2026
          WHERE created_at < $minMs OR created_at > $maxMs
        ''');
      }
      if (from == 26) {
        // v27: Fix imported records whose dates have a corrupted year (e.g. 58023).
        // The month and day are correct — only the year needs to be set to 2026.
        // Drift stores DateTimes as INTEGER milliseconds since epoch, so we read
        // each bad value in Dart, extract month + day, rebuild as 2026-MM-DD,
        // and write the corrected milliseconds back.
        const minMs = -2208988800000; // ~year 1900
        const maxMs =  4102444800000; // ~year 2100

        // ── repair_orders.service_date ────────────────────────────────────
        final badRoServiceDates = await m.database.customSelect(
          'SELECT id, service_date FROM repair_orders '
          'WHERE service_date IS NOT NULL '
          '  AND (service_date < $minMs OR service_date > $maxMs)',
        ).get();
        for (final row in badRoServiceDates) {
          final id  = row.read<int>('id');
          final ms  = row.read<int>('service_date');
          final dt  = DateTime.fromMillisecondsSinceEpoch(ms);
          final fix = DateTime(2026, dt.month, dt.day).millisecondsSinceEpoch;
          await m.database.customStatement(
            'UPDATE repair_orders SET service_date = $fix WHERE id = $id',
          );
        }

        // ── repair_orders.created_at ──────────────────────────────────────
        final badRoCreatedAt = await m.database.customSelect(
          'SELECT id, created_at FROM repair_orders '
          'WHERE created_at < $minMs OR created_at > $maxMs',
        ).get();
        for (final row in badRoCreatedAt) {
          final id  = row.read<int>('id');
          final ms  = row.read<int>('created_at');
          final dt  = DateTime.fromMillisecondsSinceEpoch(ms);
          final fix = DateTime(2026, dt.month, dt.day).millisecondsSinceEpoch;
          await m.database.customStatement(
            'UPDATE repair_orders SET created_at = $fix WHERE id = $id',
          );
        }

        // ── estimates.estimate_date ───────────────────────────────────────
        final badEstDates = await m.database.customSelect(
          'SELECT id, estimate_date FROM estimates '
          'WHERE estimate_date IS NOT NULL '
          '  AND (estimate_date < $minMs OR estimate_date > $maxMs)',
        ).get();
        for (final row in badEstDates) {
          final id  = row.read<int>('id');
          final ms  = row.read<int>('estimate_date');
          final dt  = DateTime.fromMillisecondsSinceEpoch(ms);
          final fix = DateTime(2026, dt.month, dt.day).millisecondsSinceEpoch;
          await m.database.customStatement(
            'UPDATE estimates SET estimate_date = $fix WHERE id = $id',
          );
        }

        // ── estimates.created_at ──────────────────────────────────────────
        final badEstCreatedAt = await m.database.customSelect(
          'SELECT id, created_at FROM estimates '
          'WHERE created_at < $minMs OR created_at > $maxMs',
        ).get();
        for (final row in badEstCreatedAt) {
          final id  = row.read<int>('id');
          final ms  = row.read<int>('created_at');
          final dt  = DateTime.fromMillisecondsSinceEpoch(ms);
          final fix = DateTime(2026, dt.month, dt.day).millisecondsSinceEpoch;
          await m.database.customStatement(
            'UPDATE estimates SET created_at = $fix WHERE id = $id',
          );
        }
      }
      if (from < 31) {
        // v31: ROOT-CAUSE FIX for all prior date migrations (v27–v30).
        //
        // The bug: every previous migration wrote DateTime values as INTEGER
        // MILLISECONDS (e.g. 1767225600000), but Drift reads DateTimeColumn as
        // UNIX SECONDS and multiplies × 1000 to get ms.  So Drift computed:
        //   1767225600000 × 1000 = 1,767,225,600,000,000 ms  →  year ~58,023
        // which made every fixed date display as "—".
        //
        // Fix: write UNIX SECONDS (e.g. 1767225600) so Drift reads back
        //   1767225600 × 1000 = 1,767,225,600,000 ms  →  2026-01-01  ✓
        //
        // Each imported RO (IDs 1–12) gets its actual service date from the
        // original export, corrected to 2026.  created_at on both the RO and
        // its linked estimate is set to the same date.
        // Values produced by: DateTime(year, month, day).millisecondsSinceEpoch ~/ 1000
        // in the local timezone (UTC-7) so Drift round-trips correctly.
        const roFixesSecs = [
          [1,  1790568000],  // RO-0001  2026-09-28
          [2,  1794200400],  // RO-0002  2026-11-09
          [3,  1792641600],  // RO-0003  2026-10-22
          [4,  1797915600],  // RO-0004  2026-12-22
          [5,  1779854400],  // RO-0005  2026-05-27
          [6,  1778385600],  // RO-0006  2026-05-10
          [7,  1793332800],  // RO-0007  2026-10-30
          [8,  1775275200],  // RO-0008  2026-04-04
          [9,  1775275200],  // RO-0009  2026-04-04
          [10, 1773720000],  // RO-0010  2026-03-17
          [11, 1773892800],  // RO-0011  2026-03-19
          [12, 1774238400],  // RO-0012  2026-03-23
        ];
        for (final pair in roFixesSecs) {
          final roId = pair[0];
          final secs = pair[1];
          await m.database.customStatement(
            'UPDATE repair_orders SET service_date = $secs, created_at = $secs WHERE id = $roId',
          );
          await m.database.customStatement(
            'UPDATE estimates SET created_at = $secs WHERE id = (SELECT estimate_id FROM repair_orders WHERE id = $roId)',
          );
        }
        // Safety net: NULL any service_date still way out of valid range
        // (> year-2100 in seconds = 4102444800).  This catches any rows where
        // an old ms-based migration wrote a value that was not in IDs 1–12.
        const maxValidSecs = 4102444800;   // ~year 2100 in seconds
        const jan2026Secs  = 1767243600;   // 2026-01-01 local midnight
        await m.database.customStatement(
          'UPDATE repair_orders SET service_date = NULL WHERE service_date IS NOT NULL AND service_date > $maxValidSecs',
        );
        await m.database.customStatement(
          'UPDATE repair_orders SET created_at = $jan2026Secs WHERE created_at > $maxValidSecs',
        );
        await m.database.customStatement(
          'UPDATE estimates SET created_at = $jan2026Secs WHERE created_at > $maxValidSecs',
        );
      }
      if (from < 32) {
        // v32: Add shop address, phone, and email to shop_settings.
        // Required for invoice headers (legal requirement in many states).
        final addrCol = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('shop_settings') WHERE name='shop_address'",
        ).get();
        if (addrCol.isEmpty) {
          await m.addColumn(shopSettings, shopSettings.shopAddress);
        }
        final phoneCol = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('shop_settings') WHERE name='shop_phone'",
        ).get();
        if (phoneCol.isEmpty) {
          await m.addColumn(shopSettings, shopSettings.shopPhone);
        }
        final emailCol = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('shop_settings') WHERE name='shop_email'",
        ).get();
        if (emailCol.isEmpty) {
          await m.addColumn(shopSettings, shopSettings.shopEmail);
        }
      }
      if (from < 33) {
        // v33: Add tax_rate_bps to repair_orders — snapshot of the tax rate at
        // RO creation time (basis points: 850 = 8.5%).
        // NULL for existing ROs (they fall back to estimate.taxRate at display time).
        final col = await m.database.customSelect(
          "SELECT name FROM pragma_table_info('repair_orders') WHERE name='tax_rate_bps'",
        ).get();
        if (col.isEmpty) {
          await m.addColumn(repairOrders, repairOrders.taxRateBps);
        }
      }
      if (from < 34) {
        // v34: Add indexes on high-traffic FK columns to eliminate full table
        // scans on common joins (vehicles→customer, items→estimate, ROs→estimate, etc.).
        // CREATE INDEX IF NOT EXISTS is idempotent — safe to run on any version.
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_vehicles_customer_id ON vehicles(customer_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_estimates_customer_id ON estimates(customer_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_line_items_estimate_id ON estimate_line_items(estimate_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_line_items_parent_labor_id ON estimate_line_items(parent_labor_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_repair_orders_customer_id ON repair_orders(customer_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_repair_orders_estimate_id ON repair_orders(estimate_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_template_parts_template_id ON service_template_parts(template_id)',
        );
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

  // Watches a single customer — emits a new value whenever the record changes.
  Stream<Customer?> watchCustomer(int id) =>
      (select(customers)..where((c) => c.id.equals(id))).watchSingleOrNull();

  // Adds a new customer row and returns the new row's id.
  Future<int> insertCustomer(CustomersCompanion entry) =>
      into(customers).insert(entry);

  // Replaces all fields on an existing customer row.
  Future<bool> updateCustomer(Customer customer) =>
      update(customers).replace(customer);

  // Permanently removes a customer and all related records (vehicles, estimates,
  // line items, and repair orders). Wrapped in a transaction so the whole
  // operation succeeds or fails together.
  Future<void> deleteCustomer(int id) => transaction(() async {
    final ests = await (select(estimates)
          ..where((e) => e.customerId.equals(id)))
        .get();
    for (final est in ests) {
      await (delete(estimateLineItems)
            ..where((l) => l.estimateId.equals(est.id)))
          .go();
    }
    await (delete(repairOrders)..where((r) => r.customerId.equals(id))).go();
    await (delete(estimates)..where((e) => e.customerId.equals(id))).go();
    await (delete(vehicles)..where((v) => v.customerId.equals(id))).go();
    await (delete(customers)..where((c) => c.id.equals(id))).go();
  });

  // ─── Vehicle Queries ────────────────────────────────────────────────────────

  // Returns a live stream of all vehicles belonging to one customer.
  Stream<List<Vehicle>> watchVehiclesForCustomer(int customerId) =>
      (select(vehicles)..where((v) => v.customerId.equals(customerId))).watch();

  // Fetches a single vehicle by id.
  Future<Vehicle?> getVehicle(int id) =>
      (select(vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();

  // Watches a single vehicle — emits a new value whenever the record changes.
  Stream<Vehicle?> watchVehicle(int id) =>
      (select(vehicles)..where((v) => v.id.equals(id))).watchSingleOrNull();

  // Adds a new vehicle and returns the new row's id.
  Future<int> insertVehicle(VehiclesCompanion entry) =>
      into(vehicles).insert(entry);

  // Replaces all fields on an existing vehicle row.
  Future<bool> updateVehicle(Vehicle vehicle) =>
      update(vehicles).replace(vehicle);

  // Permanently removes a vehicle and all linked estimates, line items, and ROs.
  Future<void> deleteVehicle(int id) => transaction(() async {
    final ests = await (select(estimates)
          ..where((e) => e.vehicleId.equals(id)))
        .get();
    for (final est in ests) {
      await (delete(estimateLineItems)
            ..where((l) => l.estimateId.equals(est.id)))
          .go();
    }
    await (delete(repairOrders)..where((r) => r.vehicleId.equals(id))).go();
    await (delete(estimates)..where((e) => e.vehicleId.equals(id))).go();
    await (delete(vehicles)..where((v) => v.id.equals(id))).go();
  });

  // ─── Estimate Queries ────────────────────────────────────────────────────────

  // Returns a live stream of all estimates, joined with their customer and
  // vehicle so the list screen can show names without extra lookups.
  Stream<List<EstimateWithDetails>> watchAllEstimates() {
    final q = select(estimates).join([
      leftOuterJoin(customers, customers.id.equalsExp(estimates.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(estimates.vehicleId)),
    ]);
    q.orderBy([OrderingTerm.desc(estimates.id)]);
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

  // Fetches a single estimate by id (one-time read, returns null if not found).
  Future<Estimate?> getEstimate(int id) =>
      (select(estimates)..where((e) => e.id.equals(id))).getSingleOrNull();

  // Adds a new estimate and returns its new id.
  Future<int> insertEstimate(EstimatesCompanion entry) =>
      into(estimates).insert(entry);

  // Replaces all fields on an existing estimate.
  Future<bool> updateEstimate(Estimate estimate) =>
      update(estimates).replace(estimate);

  // Permanently removes an estimate and all its line items.
  Future<void> deleteEstimate(int id) => transaction(() async {
    await (delete(estimateLineItems)
          ..where((l) => l.estimateId.equals(id)))
        .go();
    await (delete(estimates)..where((e) => e.id.equals(id))).go();
  });

  // ─── Line Item Queries ───────────────────────────────────────────────────────

  // Returns a live stream of all line items for one estimate.
  Stream<List<EstimateLineItem>> watchLineItems(int estimateId) =>
      (select(estimateLineItems)
            ..where((l) => l.estimateId.equals(estimateId)))
          .watch();

  // Fetches all line items for one estimate (one-time read, not streamed).
  // Used by the dashboard to calculate revenue totals without a live subscription.
  Future<List<EstimateLineItem>> getLineItemsForEstimate(int estimateId) =>
      (select(estimateLineItems)
            ..where((l) => l.estimateId.equals(estimateId)))
          .get();

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
  // If the item is a labor line, any parts linked to it (via parentLaborId)
  // are first orphaned (parentLaborId set to null) so they stay on the estimate
  // rather than silently disappearing.
  Future<int> deleteLineItem(int id) => transaction(() async {
        await (update(estimateLineItems)
              ..where((l) => l.parentLaborId.equals(id)))
            .write(const EstimateLineItemsCompanion(
          parentLaborId: Value(null),
        ));
        return (delete(estimateLineItems)..where((l) => l.id.equals(id))).go();
      });

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

  // Returns only active (non-archived) vendors for lists and pickers.
  Stream<List<Vendor>> watchAllVendors() =>
      (select(vendors)
            ..where((v) => v.isArchived.equals(false))
            ..orderBy([(v) => OrderingTerm.asc(v.name)]))
          .watch();

  // Returns ALL vendors including archived — used when displaying historical
  // data (e.g. a line item that references an archived vendor).
  Stream<List<Vendor>> watchAllVendorsIncludingArchived() =>
      (select(vendors)..orderBy([(v) => OrderingTerm.asc(v.name)])).watch();

  Future<Vendor?> getVendor(int id) =>
      (select(vendors)..where((v) => v.id.equals(id))).getSingleOrNull();

  Future<int> insertVendor(VendorsCompanion entry) =>
      into(vendors).insert(entry);

  Future<bool> updateVendor(Vendor vendor) =>
      update(vendors).replace(vendor);

  Future<int> deleteVendor(int id) =>
      (delete(vendors)..where((v) => v.id.equals(id))).go();

  Future<void> archiveVendor(int id) =>
      (update(vendors)..where((v) => v.id.equals(id)))
          .write(const VendorsCompanion(isArchived: Value(true)));

  Future<void> unarchiveVendor(int id) =>
      (update(vendors)..where((v) => v.id.equals(id)))
          .write(const VendorsCompanion(isArchived: Value(false)));

  // ─── Repair Order Queries ─────────────────────────────────────────────────

  // Returns a live stream of all ROs, joined with customer + vehicle,
  // newest first so the shop always sees the most recent jobs at the top.
  Stream<List<RepairOrderWithDetails>> watchAllRepairOrders() {
    final q = select(repairOrders).join([
      leftOuterJoin(customers, customers.id.equalsExp(repairOrders.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(repairOrders.vehicleId)),
    ]);
    q.orderBy([OrderingTerm.desc(repairOrders.id)]);
    return q.watch().map((rows) => rows
        .map((row) => RepairOrderWithDetails(
              ro: row.readTable(repairOrders),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Fetches a single repair order by id (one-time read).
  Future<RepairOrder?> getRepairOrder(int id) =>
      (select(repairOrders)..where((r) => r.id.equals(id))).getSingleOrNull();

  // Returns a live stream of a single RO by id.
  Stream<RepairOrder?> watchRepairOrder(int id) =>
      (select(repairOrders)..where((r) => r.id.equals(id)))
          .watchSingleOrNull();

  // Returns the RO linked to a specific estimate (null if none exists yet).
  // Used by the estimate detail screen to show "Convert to RO" or "View RO".
  Stream<RepairOrder?> watchRoForEstimate(int estimateId) =>
      (select(repairOrders)..where((r) => r.estimateId.equals(estimateId)))
          .watchSingleOrNull();

  // Returns a live stream of all estimates for one customer, newest first.
  Stream<List<EstimateWithDetails>> watchEstimatesForCustomer(int customerId) {
    final q = select(estimates).join([
      leftOuterJoin(customers, customers.id.equalsExp(estimates.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(estimates.vehicleId)),
    ]);
    q.where(estimates.customerId.equals(customerId));
    q.orderBy([OrderingTerm.desc(estimates.createdAt)]);
    return q.watch().map((rows) => rows
        .map((row) => EstimateWithDetails(
              estimate: row.readTable(estimates),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Returns a live stream of all ROs for one customer, newest first.
  Stream<List<RepairOrderWithDetails>> watchRepairOrdersForCustomer(
      int customerId) {
    final q = select(repairOrders).join([
      leftOuterJoin(customers, customers.id.equalsExp(repairOrders.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(repairOrders.vehicleId)),
    ]);
    q.where(repairOrders.customerId.equals(customerId));
    q.orderBy([OrderingTerm.desc(repairOrders.createdAt)]);
    return q.watch().map((rows) => rows
        .map((row) => RepairOrderWithDetails(
              ro: row.readTable(repairOrders),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Returns a live stream of all estimates for one vehicle, newest first.
  Stream<List<EstimateWithDetails>> watchEstimatesForVehicle(int vehicleId) {
    final q = select(estimates).join([
      leftOuterJoin(customers, customers.id.equalsExp(estimates.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(estimates.vehicleId)),
    ]);
    q.where(estimates.vehicleId.equals(vehicleId));
    q.orderBy([OrderingTerm.desc(estimates.createdAt)]);
    return q.watch().map((rows) => rows
        .map((row) => EstimateWithDetails(
              estimate: row.readTable(estimates),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Returns a live stream of all ROs for one vehicle, newest first.
  Stream<List<RepairOrderWithDetails>> watchRepairOrdersForVehicle(
      int vehicleId) {
    final q = select(repairOrders).join([
      leftOuterJoin(customers, customers.id.equalsExp(repairOrders.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(repairOrders.vehicleId)),
    ]);
    q.where(repairOrders.vehicleId.equals(vehicleId));
    q.orderBy([OrderingTerm.desc(repairOrders.createdAt)]);
    return q.watch().map((rows) => rows
        .map((row) => RepairOrderWithDetails(
              ro: row.readTable(repairOrders),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // Adds a new repair order and returns its new id.
  Future<int> insertRepairOrder(RepairOrdersCompanion entry) =>
      into(repairOrders).insert(entry);

  // Replaces all fields on an existing repair order.
  Future<bool> updateRepairOrder(RepairOrder ro) =>
      update(repairOrders).replace(ro);

  // Permanently removes a repair order by id.
  Future<int> deleteRepairOrder(int id) =>
      (delete(repairOrders)..where((r) => r.id.equals(id))).go();

  // ─── Technician Queries ───────────────────────────────────────────────────

  // Returns only active (non-archived) technicians for lists and pickers.
  Stream<List<Technician>> watchAllTechnicians() =>
      (select(technicians)
            ..where((t) => t.isArchived.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<Technician?> getTechnician(int id) =>
      (select(technicians)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTechnician(TechniciansCompanion entry) =>
      into(technicians).insert(entry);

  Future<bool> updateTechnician(Technician tech) =>
      update(technicians).replace(tech);

  Future<int> deleteTechnician(int id) =>
      (delete(technicians)..where((t) => t.id.equals(id))).go();

  Future<void> archiveTechnician(int id) =>
      (update(technicians)..where((t) => t.id.equals(id)))
          .write(const TechniciansCompanion(isArchived: Value(true)));

  Future<void> unarchiveTechnician(int id) =>
      (update(technicians)..where((t) => t.id.equals(id)))
          .write(const TechniciansCompanion(isArchived: Value(false)));

  // ─── Inventory Part Queries ───────────────────────────────────────────────

  Stream<List<InventoryPart>> watchAllParts() =>
      (select(inventoryParts)
            ..orderBy([(p) => OrderingTerm.asc(p.description)]))
          .watch();

  Future<InventoryPart?> getPart(int id) =>
      (select(inventoryParts)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertPart(InventoryPartsCompanion entry) =>
      into(inventoryParts).insert(entry);

  Future<bool> updatePart(InventoryPart part) =>
      update(inventoryParts).replace(part);

  Future<int> deletePart(int id) =>
      (delete(inventoryParts)..where((p) => p.id.equals(id))).go();

  // ─── Markup Rule Queries ──────────────────────────────────────────────────

  // Returns a live stream of all markup rules, ordered cheapest-first.
  Stream<List<MarkupRule>> watchAllMarkupRules() =>
      (select(markupRules)
            ..orderBy([(r) => OrderingTerm.asc(r.minCost)]))
          .watch();

  Future<int> insertMarkupRule(MarkupRulesCompanion entry) =>
      into(markupRules).insert(entry);

  Future<bool> updateMarkupRule(MarkupRule rule) =>
      update(markupRules).replace(rule);

  Future<int> deleteMarkupRule(int id) =>
      (delete(markupRules)..where((r) => r.id.equals(id))).go();

  // ─── Service Template Queries ─────────────────────────────────────────────

  Stream<List<ServiceTemplate>> watchAllServiceTemplates() =>
      (select(serviceTemplates)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<ServiceTemplate?> getServiceTemplate(int id) =>
      (select(serviceTemplates)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertServiceTemplate(ServiceTemplatesCompanion entry) =>
      into(serviceTemplates).insert(entry);

  Future<bool> updateServiceTemplate(ServiceTemplate t) =>
      update(serviceTemplates).replace(t);

  // Permanently removes a service template and its linked parts.
  Future<void> deleteServiceTemplate(int id) => transaction(() async {
    await (delete(serviceTemplateParts)
          ..where((p) => p.templateId.equals(id)))
        .go();
    await (delete(serviceTemplates)..where((t) => t.id.equals(id))).go();
  });

  // ─── Service Template Part Queries ────────────────────────────────────────

  // Live stream of all parts linked to a given template.
  Stream<List<ServiceTemplatePart>> watchTemplatePartsForTemplate(int templateId) =>
      (select(serviceTemplateParts)
            ..where((p) => p.templateId.equals(templateId)))
          .watch();

  // One-shot fetch — used when applying a template to an estimate.
  Future<List<ServiceTemplatePart>> getTemplatePartsForTemplate(int templateId) =>
      (select(serviceTemplateParts)
            ..where((p) => p.templateId.equals(templateId)))
          .get();

  Future<int> insertTemplatePart(ServiceTemplatePartsCompanion entry) =>
      into(serviceTemplateParts).insert(entry);

  Future<int> deleteTemplatePart(int id) =>
      (delete(serviceTemplateParts)..where((p) => p.id.equals(id))).go();

  Future<int> deleteAllTemplatePartsForTemplate(int templateId) =>
      (delete(serviceTemplateParts)
            ..where((p) => p.templateId.equals(templateId)))
          .go();

  // ─── Global Search ────────────────────────────────────────────────────────
  // Each method searches its table for a query string.
  // Results are returned as simple lists for the search screen to display.

  Future<List<Customer>> searchCustomers(String q) {
    final lower = '%${q.toLowerCase()}%';
    return (select(customers)
          ..where((c) =>
              c.name.lower().like(lower) |
              c.phone.lower().like(lower) |
              c.email.lower().like(lower))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<List<Vehicle>> searchVehicles(String q) {
    final lower = '%${q.toLowerCase()}%';
    return (select(vehicles)
          ..where((v) =>
              v.make.lower().like(lower) |
              v.model.lower().like(lower) |
              v.vin.lower().like(lower) |
              v.licensePlate.lower().like(lower) |
              v.year.cast<String>().like(lower))
          ..orderBy([(v) => OrderingTerm.asc(v.make)]))
        .get();
  }

  Future<List<EstimateWithDetails>> searchEstimates(String q) {
    final lower = '%${q.toLowerCase()}%';
    final query = select(estimates).join([
      leftOuterJoin(customers, customers.id.equalsExp(estimates.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(estimates.vehicleId)),
    ]);
    query.where(customers.name.lower().like(lower) |
        estimates.note.lower().like(lower) |
        estimates.customerComplaint.lower().like(lower));
    query.orderBy([OrderingTerm.desc(estimates.createdAt)]);
    return query.get().then((rows) => rows
        .map((row) => EstimateWithDetails(
              estimate: row.readTable(estimates),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  Future<List<RepairOrderWithDetails>> searchRepairOrders(String q) {
    final lower = '%${q.toLowerCase()}%';
    // Also match on RO number — strip "RO-" prefix so "RO-0012" or "12" both work
    final stripped = q.replaceAll(RegExp(r'[^0-9]'), '');
    final roId = int.tryParse(stripped);
    final query = select(repairOrders).join([
      leftOuterJoin(customers, customers.id.equalsExp(repairOrders.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(repairOrders.vehicleId)),
    ]);
    var condition = customers.name.lower().like(lower) |
        repairOrders.note.lower().like(lower);
    if (roId != null) {
      condition = condition | repairOrders.id.equals(roId);
    }
    query.where(condition);
    query.orderBy([OrderingTerm.desc(repairOrders.createdAt)]);
    return query.get().then((rows) => rows
        .map((row) => RepairOrderWithDetails(
              ro: row.readTable(repairOrders),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  // ─── Data Management ─────────────────────────────────────────────────────

  /// Deletes all customer-facing records: customers, vehicles, estimates,
  /// line items, and repair orders. Preserves shop config: settings,
  /// vendors, technicians, inventory, templates, and markup rules.
  Future<void> clearAllCustomerData() => transaction(() async {
    await delete(estimateLineItems).go();
    await delete(estimates).go();
    await delete(repairOrders).go();
    await delete(vehicles).go();
    await delete(customers).go();
  });

  /// One-shot fetch of all ROs joined with customer + vehicle, for CSV export.
  Future<List<RepairOrderWithDetails>> getAllRepairOrdersForExport() {
    final q = select(repairOrders).join([
      leftOuterJoin(customers, customers.id.equalsExp(repairOrders.customerId)),
      leftOuterJoin(vehicles, vehicles.id.equalsExp(repairOrders.vehicleId)),
    ]);
    q.orderBy([OrderingTerm.desc(repairOrders.serviceDate),
               OrderingTerm.desc(repairOrders.createdAt)]);
    return q.get().then((rows) => rows
        .map((row) => RepairOrderWithDetails(
              ro: row.readTable(repairOrders),
              customer: row.readTableOrNull(customers),
              vehicle: row.readTableOrNull(vehicles),
            ))
        .toList());
  }

  /// Fetch all line items for a list of RO-linked estimate IDs, for CSV export.
  Future<List<EstimateLineItem>> getLineItemsForEstimates(List<int> estimateIds) {
    if (estimateIds.isEmpty) return Future.value([]);
    return (select(estimateLineItems)
          ..where((l) => l.estimateId.isIn(estimateIds)))
        .get();
  }

  /// Find a customer by exact name + phone for duplicate detection during import.
  Future<Customer?> findCustomerByNameAndPhone(String name, String phone) {
    return (select(customers)
          ..where((c) => c.name.equals(name) & c.phone.equals(phone)))
        .getSingleOrNull();
  }

  /// Find a vehicle by VIN for duplicate detection during import.
  Future<Vehicle?> findVehicleByVin(String vin) {
    return (select(vehicles)
          ..where((v) => v.vin.equals(vin)))
        .getSingleOrNull();
  }

  /// One-shot fetch of all vendors (for import: match vendor name → id).
  Future<List<Vendor>> getAllVendors() => select(vendors).get();

  /// One-shot fetch of all technicians (for export: look up name by id).
  Future<List<Technician>> getAllTechnicians() => select(technicians).get();

  /// One-shot fetch of multiple estimates by id list (for export: tax rate + complaint).
  Future<List<Estimate>> getEstimatesByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(estimates)..where((e) => e.id.isIn(ids))).get();
  }
}

// Opens (or creates) the SQLite database file on the device.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'autoshoppro.db'));
    return NativeDatabase.createInBackground(file);
  });
}

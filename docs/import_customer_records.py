#!/usr/bin/env python3
"""
import_customer_records.py
──────────────────────────
Reads the exported Customer Records CSV (exported from Apple Numbers)
and inserts every row into the AutoShopPro SQLite database.

Usage:
    python3 docs/import_customer_records.py

The script:
  - Skips duplicate customers (same name + same phone)
  - Skips duplicate vehicles (same VIN)
  - Creates vendors automatically when a new vendor code is found
  - Parses vendor groups from the Services Done column:
        (VENDOR - item1, item2)  ← VENDOR is the all-caps first word
  - Creates one labor line item per vendor group
  - Creates the Repair Order with status "closed" (historical record)
  - Distributes shop cost + customer cost evenly across vendor groups

Run this ONCE to seed your real data. Running it again on a fresh DB
(after Clear All Customer Data) is safe.
"""

import csv
import os
import re
import sqlite3
from datetime import datetime, date

# ── Config ────────────────────────────────────────────────────────────────────

CSV_FILE = "/tmp/customer_records.csv/Customer Records-Customer Records.csv"

DB_FILE = os.path.expanduser(
    "~/Library/Containers/com.example.autoshoppro/Data/Documents/autoshoppro.db"
)

# ── Helpers ───────────────────────────────────────────────────────────────────

def parse_date(s: str):
    """Parse 'Jan 20, 2026' → datetime object, or None."""
    s = s.strip()
    if not s:
        return None
    for fmt in ("%b %d, %Y", "%Y-%m-%d", "%m/%d/%Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None

def parse_money(s: str) -> float:
    """Parse '$1,234.56' or '1234.56' → float."""
    if not s:
        return 0.0
    cleaned = re.sub(r"[^\d.]", "", s)
    try:
        return float(cleaned)
    except ValueError:
        return 0.0

def parse_int(s: str):
    """Parse '130,490' → 130490, or None."""
    if not s:
        return None
    cleaned = re.sub(r"[^\d]", "", s)
    return int(cleaned) if cleaned else None

def parse_vendor_groups(services: str) -> list[dict]:
    """
    Parse '(VENDOR - item1, item2)(VENDOR2 - item3)' into a list of
    {'vendor': 'VENDOR', 'description': 'item1, item2'} dicts.

    Rules:
    - Content inside parentheses
    - First all-caps word = vendor code
    - Rest of content = work description (strip leading dash)
    - 'LABOR' and 'N/C' are treated as no-vendor labor entries
    """
    groups = []
    for match in re.finditer(r"\(([^)]+)\)", services):
        content = match.group(1).strip()
        if not content:
            continue
        # Split off the first word
        parts = content.split(" ", 1)
        first_word = parts[0].rstrip(",- ")
        # All-caps vendor code?
        if re.match(r"^[A-Z/]+$", first_word):
            desc = parts[1].strip() if len(parts) > 1 else ""
            if desc.startswith("-"):
                desc = desc[1:].strip()
            groups.append({"vendor": first_word, "description": desc})
        else:
            # No vendor prefix
            groups.append({"vendor": "", "description": content})
    return groups

def to_unix_ms(dt: datetime) -> int:
    """Convert datetime → Unix timestamp in milliseconds (Drift's format)."""
    return int(dt.timestamp() * 1000)

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    if not os.path.exists(CSV_FILE):
        print(f"ERROR: CSV file not found at:\n  {CSV_FILE}")
        print("\nMake sure you've exported the Numbers file first.")
        print("Run this in Terminal:")
        print('  osascript -e \'tell application "Numbers"')
        print('    open POSIX file "/Users/jamestoney/Documents/Customer Records.zip"')
        print('    delay 2')
        print('    export front document to POSIX file "/tmp/customer_records.csv" as CSV')
        print('    close front document saving no')
        print("  end tell'")
        return

    if not os.path.exists(DB_FILE):
        print(f"ERROR: Database not found at:\n  {DB_FILE}")
        print("Make sure AutoShopPro has been run at least once in Xcode.")
        return

    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()

    # Ensure service_date column exists (added in schema v22 — script can run
    # before the app migrates, so we add it ourselves if missing).
    cur.execute("PRAGMA table_info(repair_orders)")
    ro_cols = {row[1] for row in cur.fetchall()}
    if "service_date" not in ro_cols:
        cur.execute("ALTER TABLE repair_orders ADD COLUMN service_date INTEGER")
        conn.commit()
        print("  ℹ️  Added service_date column to repair_orders (schema upgrade).")

    # Cache: vendor name (upper) → vendor id
    vendor_cache: dict[str, int] = {}
    cur.execute("SELECT id, name FROM vendors")
    for vid, vname in cur.fetchall():
        vendor_cache[vname.upper()] = vid

    stats = {
        "customers_created": 0,
        "customers_reused": 0,
        "vehicles_created": 0,
        "vehicles_reused": 0,
        "records_created": 0,
        "records_skipped": 0,
        "vendors_created": 0,
        "errors": [],
    }

    with open(CSV_FILE, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row_num, row in enumerate(reader, start=2):
            try:
                customer_name = row.get("Customer Name", "").strip()
                if not customer_name:
                    continue

                # Parse fields
                service_date   = parse_date(row.get("Date of Service", ""))
                phone          = row.get("Phone Number", "").strip()
                year           = parse_int(row.get("Vehicle Year", ""))
                make           = row.get("Vehicle Make", "").strip()
                model          = row.get("Vehicle Model", "").strip()
                vin            = row.get("VIN Number", "").strip()
                plate          = row.get("License Plate", "").strip()
                mileage        = parse_int(row.get("Mileage", ""))
                services       = row.get("Services Done", "").strip()
                shop_cost      = parse_money(row.get("My Cost", ""))
                customer_cost  = parse_money(row.get("Customer Cost", ""))
                notes          = row.get("Notes", "").strip()

                now_ms = to_unix_ms(service_date or datetime.now())

                # ── Customer ──────────────────────────────────────────────
                customer_id = None

                if phone:
                    cur.execute(
                        "SELECT id FROM customers WHERE name = ? AND phone = ?",
                        (customer_name, phone),
                    )
                    row_found = cur.fetchone()
                    if row_found:
                        customer_id = row_found[0]
                        stats["customers_reused"] += 1

                if customer_id is None:
                    # Try name-only match (for customers with no phone)
                    cur.execute(
                        "SELECT id FROM customers WHERE name = ?",
                        (customer_name,),
                    )
                    row_found = cur.fetchone()
                    if row_found and not phone:
                        customer_id = row_found[0]
                        stats["customers_reused"] += 1

                if customer_id is None:
                    cur.execute(
                        "INSERT INTO customers (name, phone, created_at) VALUES (?, ?, ?)",
                        (customer_name, phone or None, now_ms),
                    )
                    customer_id = cur.lastrowid
                    stats["customers_created"] += 1
                    print(f"  ✅ New customer: {customer_name}")

                # ── Vehicle ───────────────────────────────────────────────
                vehicle_id = None

                if vin:
                    cur.execute("SELECT id FROM vehicles WHERE vin = ?", (vin,))
                    row_found = cur.fetchone()
                    if row_found:
                        vehicle_id = row_found[0]
                        stats["vehicles_reused"] += 1

                if vehicle_id is None and (make or model or year):
                    cur.execute(
                        """INSERT INTO vehicles
                           (customer_id, year, make, model, vin, license_plate, mileage, created_at)
                           VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                        (
                            customer_id,
                            year,
                            make or None,
                            model or None,
                            vin or None,
                            plate or None,
                            mileage,
                            now_ms,
                        ),
                    )
                    vehicle_id = cur.lastrowid
                    stats["vehicles_created"] += 1

                # ── Estimate ──────────────────────────────────────────────
                cur.execute(
                    """INSERT INTO estimates
                       (customer_id, vehicle_id, note, status, tax_rate, created_at)
                       VALUES (?, ?, ?, 'approved', 0.0, ?)""",
                    (customer_id, vehicle_id, services or None, now_ms),
                )
                estimate_id = cur.lastrowid

                # ── Line items ────────────────────────────────────────────
                vendor_groups = parse_vendor_groups(services)

                if vendor_groups:
                    n = len(vendor_groups)
                    cost_each     = round(customer_cost / n, 2) if n else 0
                    shop_cost_each = round(shop_cost / n, 2) if n else 0

                    for g in vendor_groups:
                        vendor_code = g["vendor"].upper() if g["vendor"] else None
                        desc        = g["description"] or g["vendor"] or "Service"

                        # Skip N/C (no-charge) items from cost distribution
                        is_nc = vendor_code in ("N/C", "NC")
                        line_price = 0.0 if is_nc else cost_each
                        line_cost  = 0.0 if is_nc else shop_cost_each

                        # Get or create vendor
                        line_vendor_id = None
                        if vendor_code and vendor_code not in ("LABOR", "N/C", "NC", ""):
                            if vendor_code in vendor_cache:
                                line_vendor_id = vendor_cache[vendor_code]
                            else:
                                cur.execute(
                                    "INSERT INTO vendors (name, created_at) VALUES (?, ?)",
                                    (vendor_code, now_ms),
                                )
                                line_vendor_id = cur.lastrowid
                                vendor_cache[vendor_code] = line_vendor_id
                                stats["vendors_created"] += 1
                                print(f"    🏪 New vendor: {vendor_code}")

                        cur.execute(
                            """INSERT INTO estimate_line_items
                               (estimate_id, type, description, quantity,
                                unit_price, unit_cost, vendor_id, approval_status)
                               VALUES (?, 'labor', ?, 1.0, ?, ?, ?, 'approved')""",
                            (estimate_id, desc, line_price, line_cost or None, line_vendor_id),
                        )

                elif customer_cost > 0:
                    # No vendor groups — single catch-all line item
                    cur.execute(
                        """INSERT INTO estimate_line_items
                           (estimate_id, type, description, quantity,
                            unit_price, unit_cost, approval_status)
                           VALUES (?, 'labor', ?, 1.0, ?, ?, 'approved')""",
                        (estimate_id, services or "Service record",
                         customer_cost, shop_cost or None),
                    )

                # ── Repair Order ──────────────────────────────────────────
                cur.execute(
                    """INSERT INTO repair_orders
                       (estimate_id, customer_id, vehicle_id, note, status,
                        service_date, created_at)
                       VALUES (?, ?, ?, ?, 'closed', ?, ?)""",
                    (
                        estimate_id,
                        customer_id,
                        vehicle_id,
                        notes or None,
                        now_ms,  # service_date = same as the date of service
                        now_ms,  # created_at
                    ),
                )

                stats["records_created"] += 1
                date_str = service_date.strftime("%b %d, %Y") if service_date else "?"
                print(f"  📋 [{date_str}] {customer_name} — {make} {model}")

            except Exception as e:
                msg = f"Row {row_num}: {e}"
                stats["errors"].append(msg)
                print(f"  ⚠️  {msg}")

    conn.commit()
    conn.close()

    print("\n" + "─" * 50)
    print("Import complete!")
    print(f"  Customers created : {stats['customers_created']}")
    print(f"  Customers reused  : {stats['customers_reused']}")
    print(f"  Vehicles created  : {stats['vehicles_created']}")
    print(f"  Vehicles reused   : {stats['vehicles_reused']}")
    print(f"  Records created   : {stats['records_created']}")
    print(f"  Vendors created   : {stats['vendors_created']}")
    if stats["errors"]:
        print(f"  Errors            : {len(stats['errors'])}")
        for e in stats["errors"]:
            print(f"    • {e}")
    print("\nRestart AutoShopPro in Xcode to see your records.")


if __name__ == "__main__":
    main()

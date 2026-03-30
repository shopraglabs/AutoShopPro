import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/money.dart';
import '../customers/customers_provider.dart';
import '../repair_orders/repair_orders_provider.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

/// All KPI numbers shown on the dashboard, calculated fresh each time the
/// user opens the screen.
class DashboardStats {
  /// Repair orders currently open.
  final int openROCount;

  /// Closed ROs invoiced today.
  final int closedToday;

  /// Revenue billed today (in dollars).
  final double revenueToday;

  /// Closed ROs invoiced this calendar week (Mon–Sun).
  final int closedThisWeek;

  /// Revenue billed this calendar week (in dollars).
  final double revenueThisWeek;

  /// Closed ROs invoiced this calendar month.
  final int closedThisMonth;

  /// Revenue billed this calendar month (sum of non-declined line items, in dollars).
  final double revenueThisMonth;

  /// Number of unique vehicles worked on (closed ROs) this calendar month.
  final int carCountThisMonth;

  /// All-time average repair order value (total all-time revenue / total closed ROs).
  final double aroAllTime;

  /// All-time average gross profit percentage (only counted when cost data exists).
  /// -1 means no cost data is available.
  final double avgGpPctAllTime;

  /// Total closed ROs of all time.
  final int closedAllTime;

  /// All-time total revenue in dollars.
  final double revenueAllTime;

  /// Closed ROs invoiced this calendar year (Jan 1 – Dec 31).
  final int closedThisYear;

  /// Revenue billed this calendar year (in dollars).
  final double revenueThisYear;

  /// Number of unique vehicles worked on (closed ROs) this calendar year.
  final int carCountThisYear;

  /// Gross profit today (revenue minus known part costs, in dollars).
  final double grossProfitToday;

  /// Gross profit this calendar week.
  final double grossProfitThisWeek;

  /// Gross profit this calendar month.
  final double grossProfitThisMonth;

  /// Gross profit this calendar year.
  final double grossProfitThisYear;

  /// All-time gross profit.
  final double grossProfitAllTime;

  const DashboardStats({
    required this.openROCount,
    required this.closedToday,
    required this.revenueToday,
    required this.closedThisWeek,
    required this.revenueThisWeek,
    required this.closedThisMonth,
    required this.revenueThisMonth,
    required this.carCountThisMonth,
    required this.aroAllTime,
    required this.avgGpPctAllTime,
    required this.closedAllTime,
    required this.revenueAllTime,
    required this.closedThisYear,
    required this.revenueThisYear,
    required this.carCountThisYear,
    required this.grossProfitToday,
    required this.grossProfitThisWeek,
    required this.grossProfitThisMonth,
    required this.grossProfitThisYear,
    required this.grossProfitAllTime,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Calculates dashboard KPIs.
/// autoDispose so the numbers refresh when you leave and return to the screen.
final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  final db = ref.watch(dbProvider);

  // Get a one-time snapshot of all ROs (with customer + vehicle metadata).
  final allRos = await db.watchAllRepairOrders().first;

  final now = DateTime.now();
  final startOfToday    = DateTime(now.year, now.month, now.day);
  final endOfToday      = startOfToday.add(const Duration(days: 1));
  final startOfMonth    = DateTime(now.year, now.month, 1);
  final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
  final startOfYear     = DateTime(now.year, 1, 1);
  final startOfNextYear = DateTime(now.year + 1, 1, 1);

  // Start of current week (Monday) and end (next Monday)
  final weekdayOffset = now.weekday - 1; // Monday = 0
  final startOfWeek = DateTime(now.year, now.month, now.day - weekdayOffset);
  final endOfWeek   = startOfWeek.add(const Duration(days: 7));

  final openROs  = allRos.where((r) => r.ro.status == 'open').toList();
  final closedROs = allRos.where((r) => r.ro.status == 'closed').toList();

  // Invoice date = serviceDate (the date work was done), falling back to createdAt.
  DateTime _invoiceDate(r) => r.ro.serviceDate ?? r.ro.createdAt;

  final closedToday = closedROs.where((r) {
    final d = _invoiceDate(r);
    return !d.isBefore(startOfToday) && d.isBefore(endOfToday);
  }).toList();

  final closedThisMonth = closedROs.where((r) {
    final d = _invoiceDate(r);
    return !d.isBefore(startOfMonth) && d.isBefore(startOfNextMonth);
  }).toList();

  final closedThisWeek = closedROs.where((r) {
    final d = _invoiceDate(r);
    return !d.isBefore(startOfWeek) && d.isBefore(endOfWeek);
  }).toList();

  final closedThisYear = closedROs.where((r) {
    final d = _invoiceDate(r);
    return !d.isBefore(startOfYear) && d.isBefore(startOfNextYear);
  }).toList();

  // Unique vehicles worked on (closed ROs) this month
  final carCountThisMonth = closedThisMonth
      .where((r) => r.ro.vehicleId != null)
      .map((r) => r.ro.vehicleId!)
      .toSet()
      .length;

  // Unique vehicles worked on (closed ROs) this year
  final carCountThisYear = closedThisYear
      .where((r) => r.ro.vehicleId != null)
      .map((r) => r.ro.vehicleId!)
      .toSet()
      .length;

  // Calculate revenue, cost, and GP by loading line items for each closed RO.
  // Line item unitPrice is stored as INTEGER cents. quantity is a double.
  int revenueAllCents = 0;
  int revenueMonthCents = 0;
  int revenueWeekCents = 0;
  int revenueTodayCents = 0;
  int revenueYearCents = 0;
  int gpAllCents = 0;
  int gpMonthCents = 0;
  int gpWeekCents = 0;
  int gpTodayCents = 0;
  int gpYearCents = 0;
  int totalCostCents = 0;
  int rosWithCostData = 0;
  double totalGpPct = 0.0;

  for (final roDetail in closedROs) {
    final ro = roDetail.ro;
    if (ro.estimateId == null) continue;

    final items = await db.getLineItemsForEstimate(ro.estimateId!);
    final approved = items.where((i) => i.approvalStatus != 'declined').toList();

    // Only count approved/pending items — not declined.
    final roRevenueCents = approved
        .fold(0, (sum, i) => sum + (i.quantity * i.unitPrice).round());
    final roCostCents = approved
        .fold(0, (sum, i) => sum + (i.quantity * (i.unitCost ?? i.unitPrice)).round());

    revenueAllCents += roRevenueCents;

    // Gross profit = revenue minus known part costs only.
    // Items without unitCost (most labor) are treated as 100% margin —
    // we don't track technician wages so labor is shown as pure revenue.
    final roKnownCostCents = approved
        .where((i) => i.unitCost != null && i.unitCost! > 0)
        .fold(0, (sum, i) => sum + (i.quantity * i.unitCost!).round());
    final roGpCents = roRevenueCents - roKnownCostCents;

    gpAllCents += roGpCents;

    // GP% tracking — only count ROs where at least one part has cost data
    if (approved.any((i) => i.unitCost != null && i.unitCost! > 0)) {
      rosWithCostData++;
      if (roRevenueCents > 0) {
        totalGpPct += roGpCents / roRevenueCents * 100;
      }
    }
    totalCostCents += roCostCents;

    final date = ro.serviceDate ?? ro.createdAt;
    if (!date.isBefore(startOfMonth)  && date.isBefore(startOfNextMonth)) { revenueMonthCents += roRevenueCents; gpMonthCents += roGpCents; }
    if (!date.isBefore(startOfWeek)   && date.isBefore(endOfWeek))        { revenueWeekCents  += roRevenueCents; gpWeekCents  += roGpCents; }
    if (!date.isBefore(startOfToday)  && date.isBefore(endOfToday))       { revenueTodayCents += roRevenueCents; gpTodayCents += roGpCents; }
    if (!date.isBefore(startOfYear)   && date.isBefore(startOfNextYear))  { revenueYearCents  += roRevenueCents; gpYearCents  += roGpCents; }
  }

  final aroAllTimeCents = closedROs.isEmpty
      ? 0.0
      : revenueAllCents / closedROs.length;

  final avgGpPct = rosWithCostData == 0
      ? -1.0
      : totalGpPct / rosWithCostData;

  return DashboardStats(
    openROCount: openROs.length,
    closedToday: closedToday.length,
    revenueToday: fromCents(revenueTodayCents),
    closedThisWeek: closedThisWeek.length,
    revenueThisWeek: fromCents(revenueWeekCents),
    closedThisMonth: closedThisMonth.length,
    revenueThisMonth: fromCents(revenueMonthCents),
    carCountThisMonth: carCountThisMonth,
    aroAllTime: fromCents(aroAllTimeCents.round()),
    avgGpPctAllTime: avgGpPct,
    closedAllTime: closedROs.length,
    revenueAllTime: fromCents(revenueAllCents),
    closedThisYear: closedThisYear.length,
    revenueThisYear: fromCents(revenueYearCents),
    carCountThisYear: carCountThisYear,
    grossProfitToday: fromCents(gpTodayCents),
    grossProfitThisWeek: fromCents(gpWeekCents),
    grossProfitThisMonth: fromCents(gpMonthCents),
    grossProfitThisYear: fromCents(gpYearCents),
    grossProfitAllTime: fromCents(gpAllCents),
  );
});

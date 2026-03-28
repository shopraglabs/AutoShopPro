import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/money.dart';
import '../customers/customers_provider.dart';
import '../repair_orders/repair_orders_provider.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

/// All KPI numbers shown on the dashboard, calculated fresh each time the
/// user opens the screen.
class DashboardStats {
  /// Repair orders currently open (in progress).
  final int openROCount;

  /// Closed ROs invoiced this calendar month.
  final int closedThisMonth;

  /// Revenue billed this calendar month (sum of non-declined line items, in dollars).
  final double revenueThisMonth;

  /// All-time average repair order value (total all-time revenue / total closed ROs).
  final double aroAllTime;

  /// Total closed ROs of all time.
  final int closedAllTime;

  /// All-time total revenue in dollars.
  final double revenueAllTime;

  const DashboardStats({
    required this.openROCount,
    required this.closedThisMonth,
    required this.revenueThisMonth,
    required this.aroAllTime,
    required this.closedAllTime,
    required this.revenueAllTime,
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
  final startOfMonth = DateTime(now.year, now.month, 1);

  final openROs = allRos.where((r) => r.ro.status == 'open').toList();
  final closedROs = allRos.where((r) => r.ro.status == 'closed').toList();

  final closedThisMonth = closedROs.where((r) {
    final date = r.ro.serviceDate ?? r.ro.createdAt;
    return !date.isBefore(startOfMonth);
  }).toList();

  // Calculate revenue by loading line items for each closed RO.
  // Line item unitPrice is stored as INTEGER cents. quantity is a double (hours/units).
  int revenueAllCents = 0;
  int revenueMonthCents = 0;

  for (final roDetail in closedROs) {
    final ro = roDetail.ro;
    if (ro.estimateId == null) continue;

    final items = await db.getLineItemsForEstimate(ro.estimateId!);
    // Only count approved/pending items — not declined.
    final roTotalCents = items
        .where((i) => i.approvalStatus != 'declined')
        .fold(0, (sum, i) => sum + (i.quantity * i.unitPrice).round());

    revenueAllCents += roTotalCents;

    final date = ro.serviceDate ?? ro.createdAt;
    if (!date.isBefore(startOfMonth)) {
      revenueMonthCents += roTotalCents;
    }
  }

  final aroAllTimeCents = closedROs.isEmpty
      ? 0.0
      : revenueAllCents / closedROs.length;

  return DashboardStats(
    openROCount: openROs.length,
    closedThisMonth: closedThisMonth.length,
    revenueThisMonth: fromCents(revenueMonthCents),
    aroAllTime: fromCents(aroAllTimeCents.round()),
    closedAllTime: closedROs.length,
    revenueAllTime: fromCents(revenueAllCents),
  );
});

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/money.dart';
import 'dashboard_provider.dart';

// Formats a month name from a DateTime, e.g. "March 2026"
String _monthLabel(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[d.month - 1]} ${d.year}';
}

// Formats a short date like "Mar 24"
String _shortDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[d.month - 1]} ${d.day}';
}

// Returns "Mar 24 – Mar 30" for the week containing [d]
String _weekLabel(DateTime d) {
  final offset = d.weekday - 1;
  final monday = DateTime(d.year, d.month, d.day - offset);
  final sunday = monday.add(const Duration(days: 6));
  return '${_shortDate(monday)} – ${_shortDate(sunday)}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => ref.invalidate(dashboardStatsProvider),
          child: const Icon(
            CupertinoIcons.refresh,
            size: 20,
            color: Color(0xFF007AFF),
          ),
        ),
      ),
      child: SafeArea(
        child: statsAsync.when(
          loading: () =>
              const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (stats) => _DashboardBody(stats: stats),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final DashboardStats stats;
  const _DashboardBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel = _monthLabel(now);
    final weekLabel = _weekLabel(now);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Live status ─────────────────────────────────────────────
                _sectionHeader('LIVE STATUS'),
                Container(
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      _KpiRow(
                        icon: CupertinoIcons.wrench_fill,
                        iconColor: const Color(0xFF007AFF),
                        label: 'Open Repair Orders',
                        value: stats.openROCount.toString(),
                        valueColor: stats.openROCount > 0
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF8E8E93),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Today ───────────────────────────────────────────────────
                _sectionHeader('TODAY — ${_shortDate(now).toUpperCase()}'),
                Container(
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      _KpiRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: const Color(0xFFFF9500),
                        label: 'Invoices Closed',
                        value: stats.closedToday.toString(),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: const Color(0xFFFF9500),
                        label: 'Revenue (excl. tax)',
                        value: formatMoneyFromDouble(stats.revenueToday),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.arrow_up_right_circle_fill,
                        iconColor: const Color(0xFFFF9500),
                        label: 'Gross Profit',
                        value: formatMoneyFromDouble(stats.grossProfitToday),
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── This week ───────────────────────────────────────────────
                _sectionHeader('THIS WEEK — $weekLabel'.toUpperCase()),
                Container(
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      _KpiRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: const Color(0xFF007AFF),
                        label: 'Invoices Closed',
                        value: stats.closedThisWeek.toString(),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: const Color(0xFF007AFF),
                        label: 'Revenue (excl. tax)',
                        value: formatMoneyFromDouble(stats.revenueThisWeek),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.arrow_up_right_circle_fill,
                        iconColor: const Color(0xFF007AFF),
                        label: 'Gross Profit',
                        value: formatMoneyFromDouble(stats.grossProfitThisWeek),
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── This month ──────────────────────────────────────────────
                _sectionHeader(monthLabel.toUpperCase()),
                Container(
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      _KpiRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: const Color(0xFF34C759),
                        label: 'Invoices Closed',
                        value: stats.closedThisMonth.toString(),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: const Color(0xFF34C759),
                        label: 'Revenue (excl. tax)',
                        value: formatMoneyFromDouble(stats.revenueThisMonth),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.arrow_up_right_circle_fill,
                        iconColor: const Color(0xFF34C759),
                        label: 'Gross Profit',
                        value: formatMoneyFromDouble(stats.grossProfitThisMonth),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.car_fill,
                        iconColor: const Color(0xFF34C759),
                        label: 'Car Count',
                        value: stats.carCountThisMonth.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── This year ───────────────────────────────────────────────
                _sectionHeader('${now.year}'),
                Container(
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      _KpiRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: const Color(0xFF5856D6),
                        label: 'Invoices Closed',
                        value: stats.closedThisYear.toString(),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: const Color(0xFF5856D6),
                        label: 'Revenue (excl. tax)',
                        value: formatMoneyFromDouble(stats.revenueThisYear),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.arrow_up_right_circle_fill,
                        iconColor: const Color(0xFF5856D6),
                        label: 'Gross Profit',
                        value: formatMoneyFromDouble(stats.grossProfitThisYear),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.car_fill,
                        iconColor: const Color(0xFF5856D6),
                        label: 'Car Count',
                        value: stats.carCountThisYear.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── All time ────────────────────────────────────────────────
                _sectionHeader('ALL TIME'),
                Container(
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      _KpiRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: const Color(0xFF8E8E93),
                        label: 'Total Invoices',
                        value: stats.closedAllTime.toString(),
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: const Color(0xFF8E8E93),
                        label: 'Total Revenue (excl. tax)',
                        value: formatMoneyFromDouble(stats.revenueAllTime),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.arrow_up_right_circle_fill,
                        iconColor: const Color(0xFF8E8E93),
                        label: 'Total Gross Profit',
                        value: formatMoneyFromDouble(stats.grossProfitAllTime),
                        valueBold: true,
                      ),
                      Container(
                          height: 0.5,
                          color: const Color(0xFFE5E5EA),
                          margin: const EdgeInsets.only(left: 52)),
                      _KpiRow(
                        icon: CupertinoIcons.chart_bar_fill,
                        iconColor: const Color(0xFF8E8E93),
                        label: 'Avg. Repair Order (ARO)',
                        value: stats.closedAllTime == 0
                            ? '—'
                            : formatMoneyFromDouble(stats.aroAllTime),
                        sublabel: stats.closedAllTime == 0
                            ? 'No closed invoices yet'
                            : null,
                      ),
                      // Avg GP — only shown when cost data exists on any line items
                      if (stats.avgGpPctAllTime >= 0) ...[
                        Container(
                            height: 0.5,
                            color: const Color(0xFFE5E5EA),
                            margin: const EdgeInsets.only(left: 52)),
                        _KpiRow(
                          icon: CupertinoIcons.percent,
                          iconColor: const Color(0xFF34C759),
                          label: 'Avg. Gross Profit',
                          value:
                              '${stats.avgGpPctAllTime.toStringAsFixed(1)}%',
                          valueColor: const Color(0xFF34C759),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF8E8E93),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── KPI row ──────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final String? sublabel;

  const _KpiRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: valueBold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

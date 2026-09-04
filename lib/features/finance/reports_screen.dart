import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/theme/relatos_spacing.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/section_card.dart';
import '../../data/relatos_scope.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);

    // Group everything by month
    final reports = _calculateMonthlyReports(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Mensuales')),
      body: ListView.separated(
        padding: const EdgeInsets.all(RelatosSpacing.page),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: RelatosSpacing.lg),
        itemBuilder: (context, index) {
          final report = reports[index];
          return SectionCard(
            title: report.monthName,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Ventas',
                        value: formatMoney(report.sales),
                        icon: Icons.south_west,
                      ),
                    ),
                    const SizedBox(width: RelatosSpacing.md),
                    Expanded(
                      child: MetricCard(
                        label: 'Gastos',
                        value: formatMoney(report.expenses),
                        icon: Icons.north_east,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RelatosSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Unidades',
                        value: report.unitsSold.round().toString(),
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: RelatosSpacing.md),
                    Expanded(
                      child: MetricCard(
                        label: 'Ganancia',
                        value: formatMoney(report.profit),
                        icon: Icons.trending_up_rounded,
                        highlighted: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_MonthlyReport> _calculateMonthlyReports(dynamic store) {
    final Map<String, _MonthlyReport> reportsMap = {};

    final monthFormat = DateFormat('yyyy-MM');
    final monthDisplayFormat = DateFormat.yMMMM('es_ES');

    void ensureMonth(DateTime date) {
      final key = monthFormat.format(date);
      if (!reportsMap.containsKey(key)) {
        reportsMap[key] = _MonthlyReport(
          monthName: monthDisplayFormat.format(date),
          sales: 0,
          expenses: 0,
          unitsSold: 0,
        );
      }
    }

    // Process Sales
    for (final sale in store.sales) {
      ensureMonth(sale.soldAt);
      final key = monthFormat.format(sale.soldAt);
      reportsMap[key]!.sales += sale.total;
      reportsMap[key]!.unitsSold += sale.quantity;
    }

    // Process Manual Expenses
    for (final expense in store.expenses) {
      ensureMonth(expense.spentAt);
      final key = monthFormat.format(expense.spentAt);
      reportsMap[key]!.expenses += expense.amount;
    }

    // Process Purchases
    for (final purchase in store.purchases) {
      ensureMonth(purchase.purchasedAt);
      final key = monthFormat.format(purchase.purchasedAt);
      reportsMap[key]!.expenses += purchase.totalCost;
    }

    final sortedKeys = reportsMap.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys.map((k) => reportsMap[k]!).toList();
  }
}

class _MonthlyReport {
  final String monthName;
  double sales;
  double expenses;
  double unitsSold;

  double get profit => sales - expenses;

  _MonthlyReport({
    required this.monthName,
    required this.sales,
    required this.expenses,
    required this.unitsSold,
  });
}

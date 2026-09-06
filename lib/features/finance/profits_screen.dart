import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/theme/relatos_spacing.dart';
import '../../data/relatos_scope.dart';

class ProfitsScreen extends StatelessWidget {
  const ProfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    final monthlyData = _calculateMonthlyData(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Ganancias Mensuales')),
      body: ListView.separated(
        padding: const EdgeInsets.all(RelatosSpacing.page),
        itemCount: monthlyData.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final data = monthlyData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: RelatosSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.monthName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ingresos (Ventas):'),
                    Text(formatMoney(data.sales)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gastos (Compras + Op.):'),
                    Text(formatMoney(data.expenses),
                        style: const TextStyle(color: Colors.redAccent)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ganancia Neta:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatMoney(data.profit),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: data.profit >= 0 ? Colors.green : Colors.red,
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

  List<_MonthlyData> _calculateMonthlyData(dynamic store) {
    final Map<String, _MonthlyData> map = {};
    final monthFormat = DateFormat('yyyy-MM');
    final monthDisplayFormat = DateFormat.yMMMM('es_ES');

    void ensureMonth(DateTime date) {
      final key = monthFormat.format(date);
      if (!map.containsKey(key)) {
        map[key] = _MonthlyData(
          monthName: monthDisplayFormat.format(date),
          sales: 0,
          expenses: 0,
        );
      }
    }

    for (final sale in store.sales) {
      ensureMonth(sale.soldAt);
      map[monthFormat.format(sale.soldAt)]!.sales += sale.total;
    }

    for (final exp in store.expenses) {
      ensureMonth(exp.spentAt);
      map[monthFormat.format(exp.spentAt)]!.expenses += exp.amount;
    }

    for (final pur in store.purchases) {
      ensureMonth(pur.purchasedAt);
      map[monthFormat.format(pur.purchasedAt)]!.expenses += pur.totalCost;
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys.map((k) => map[k]!).toList();
  }
}

class _MonthlyData {
  final String monthName;
  double sales;
  double expenses;
  double get profit => sales - expenses;

  _MonthlyData({
    required this.monthName,
    required this.sales,
    required this.expenses,
  });
}

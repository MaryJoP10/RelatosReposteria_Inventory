import 'package:flutter/material.dart';

import '../../core/widgets/feature_hub.dart';
import '../sales/sales_screen.dart';
import 'expenses_screen.dart';
import 'reports_screen.dart';

class FinanceHubScreen extends StatelessWidget {
  const FinanceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureHubScreen(
      title: 'Finanzas',
      actions: [
        HubAction(
          title: 'Ingresos',
          subtitle: 'Entradas por ventas y otros',
          icon: Icons.south_west,
          builder: (_) => const SalesScreen(),
        ),
        HubAction(
          title: 'Gastos',
          subtitle: 'Insumos, servicios y operación',
          icon: Icons.north_east,
          builder: (_) => const ExpensesScreen(),
        ),
        HubAction(
          title: 'Ganancias',
          subtitle: 'Resultado mensual',
          icon: Icons.trending_up_rounded,
          builder: (_) => const ReportsScreen(),
        ),
        HubAction(
          title: 'Reportes',
          subtitle: 'Resúmenes de operación',
          icon: Icons.insights_outlined,
          builder: (_) => const ReportsScreen(),
        ),
      ],
    );
  }
}

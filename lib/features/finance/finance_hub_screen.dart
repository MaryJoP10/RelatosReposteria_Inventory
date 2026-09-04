import 'package:flutter/material.dart';

import '../../core/widgets/feature_hub.dart';
import '../sales/sales_screen.dart';
import 'expenses_screen.dart';

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
          subtitle: 'Resultado del período',
          icon: Icons.trending_up_rounded,
          builder: (_) => const PlaceholderDetailScreen(
            title: 'Ganancias',
            description: 'Aquí se verá la ganancia calculada del período.',
          ),
        ),
        HubAction(
          title: 'Reportes',
          subtitle: 'Resúmenes para la operación',
          icon: Icons.insights_outlined,
          builder: (_) => const PlaceholderDetailScreen(
            title: 'Reportes',
            description: 'Aquí se generarán reportes de costos y resultados.',
          ),
        ),
      ],
    );
  }
}

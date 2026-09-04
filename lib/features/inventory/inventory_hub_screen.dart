import 'package:flutter/material.dart';

import '../../core/widgets/feature_hub.dart';
import 'adjustments_screen.dart';
import 'ingredients_screen.dart';
import 'products_screen.dart';
import 'purchases_screen.dart';

class InventoryHubScreen extends StatelessWidget {
  const InventoryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureHubScreen(
      title: 'Inventario',
      actions: [
        HubAction(
          title: 'Ingredientes',
          subtitle: 'Existencias y unidades de materia prima',
          icon: Icons.kitchen_outlined,
          builder: (_) => const IngredientsScreen(),
        ),
        HubAction(
          title: 'Productos terminados',
          subtitle: 'Stock listo para la venta',
          icon: Icons.cake_outlined,
          builder: (_) => const ProductsScreen(),
        ),
        HubAction(
          title: 'Compras',
          subtitle: 'Ingresos de insumos al inventario',
          icon: Icons.shopping_bag_outlined,
          builder: (_) => const PurchasesScreen(),
        ),
        HubAction(
          title: 'Ajustes',
          subtitle: 'Correcciones de stock y merma',
          icon: Icons.tune_outlined,
          builder: (_) => const AdjustmentsScreen(),
        ),
      ],
    );
  }
}

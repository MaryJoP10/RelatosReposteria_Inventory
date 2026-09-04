import 'package:flutter/material.dart';

import '../../core/widgets/feature_hub.dart';
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
          title: 'Productos y Precios',
          subtitle: 'Catálogo, precios de venta y stock',
          icon: Icons.cake_outlined,
          builder: (_) => const ProductsScreen(),
        ),
        HubAction(
          title: 'Compras',
          subtitle: 'Ingresos de insumos al inventario',
          icon: Icons.shopping_bag_outlined,
          builder: (_) => const PurchasesScreen(),
        ),
      ],
    );
  }
}

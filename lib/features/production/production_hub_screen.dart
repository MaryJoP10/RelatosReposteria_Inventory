import 'package:flutter/material.dart';

import '../../core/widgets/feature_hub.dart';
import 'production_list_screen.dart';
import 'recipes_screen.dart';

class ProductionHubScreen extends StatelessWidget {
  const ProductionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureHubScreen(
      title: 'Producción',
      actions: [
        HubAction(
          title: 'Recetas',
          subtitle: 'Fichas de producto y porciones',
          icon: Icons.menu_book_outlined,
          builder: (_) => const RecipesScreen(),
        ),
        HubAction(
          title: 'Nueva producción',
          subtitle: 'Registrar una tanda lista',
          icon: Icons.add_circle_outline,
          builder: (_) => const ProductionFormScreen(),
        ),
        HubAction(
          title: 'Historial de producción',
          subtitle: 'Tandas recientes y cantidades',
          icon: Icons.history,
          builder: (_) => const ProductionListScreen(),
        ),
      ],
    );
  }
}

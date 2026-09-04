import 'package:flutter/material.dart';

import '../../core/widgets/feature_hub.dart';
import '../inventory/products_screen.dart';
import 'sales_screen.dart';

class SalesHubScreen extends StatelessWidget {
  const SalesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureHubScreen(
      title: 'Ventas',
      actions: [
        HubAction(
          title: 'Nueva venta',
          subtitle: 'Registrar un pedido o mostrador',
          icon: Icons.point_of_sale_outlined,
          builder: (_) => const SaleFormScreen(),
        ),
        HubAction(
          title: 'Historial de ventas',
          subtitle: 'Consultar movimientos recientes',
          icon: Icons.receipt_long_outlined,
          builder: (_) => const SalesScreen(),
        ),
        HubAction(
          title: 'Catálogo de Productos',
          subtitle: 'Gestionar productos y precios',
          icon: Icons.cake_outlined,
          builder: (_) => const ProductsScreen(),
        ),
      ],
    );
  }
}

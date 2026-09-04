import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Ventas',
      emptyTitle: 'Sin ventas',
      emptyMessage: 'Registra tus pedidos y ventas aquí.',
      emptyIcon: Icons.receipt_long_outlined,
      onAdd: () => _openForm(context),
      itemCount: store.sales.length,
      itemBuilder: (context, index) {
        final item = store.sales[index];
        return AppListTile(
          title: item.productName,
          subtitle: '${formatQuantity(item.quantity, '')} - ${formatMoney(item.total)}',
          leadingIcon: Icons.receipt_long_outlined,
          trailing: Text(
            item.soldAt.toString().substring(0, 10),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SaleFormScreen()),
    );
  }
}

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  Product? _selectedProduct;
  final _quantity = TextEditingController();
  final _total = TextEditingController();

  @override
  void dispose() {
    _quantity.dispose();
    _total.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return RelatosFormPage(
      title: 'Nueva venta',
      onSave: _save,
      children: [
        DropdownButtonFormField<Product>(
          value: _selectedProduct,
          decoration: const InputDecoration(labelText: 'Producto'),
          items: [
            for (final product in store.products)
              DropdownMenuItem(value: product, child: Text(product.name)),
          ],
          onChanged: (value) => setState(() => _selectedProduct = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cantidad'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _total,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Total de venta', prefixText: r'$ '),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final product = _selectedProduct;
    final quantity = parseDecimal(_quantity.text);
    final total = parseDecimal(_total.text);
    if (product == null || quantity == null || total == null) {
      await showRelatosError(context, RelatosException('Completa todos los campos.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.addSale(
        productId: product.id,
        quantity: quantity,
        total: total,
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }
}

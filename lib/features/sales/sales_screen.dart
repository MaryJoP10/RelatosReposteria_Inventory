import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/relatos_spacing.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Historial de Ventas',
      emptyTitle: 'Sin ingresos',
      emptyMessage: 'Las ventas registradas aparecerán aquí.',
      emptyIcon: Icons.receipt_long_outlined,
      itemCount: store.sales.length,
      itemBuilder: (context, index) {
        final item = store.sales[index];
        return AppListTile(
          title: item.productName,
          subtitle:
              '${formatQuantity(item.quantity, '')} - ${formatMoney(item.total)}',
          leadingIcon: Icons.receipt_long_outlined,
          trailing: Text(
            item.soldAt.toString().substring(0, 10),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}

class QuickSalesScreen extends StatelessWidget {
  const QuickSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    final availableProducts =
        store.products.where((p) => p.quantity > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Venta')),
      body: availableProducts.isEmpty
          ? const Center(child: Text('No hay productos con stock disponible.'))
          : ListView.separated(
              padding: const EdgeInsets.all(RelatosSpacing.page),
              itemCount: availableProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _QuickSaleItem(product: availableProducts[index]);
              },
            ),
    );
  }
}

class _QuickSaleItem extends StatefulWidget {
  const _QuickSaleItem({required this.product});

  final Product product;

  @override
  State<_QuickSaleItem> createState() => _QuickSaleItemState();
}

class _QuickSaleItemState extends State<_QuickSaleItem> {
  int _quantity = 1;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final price = widget.product.price;
    final total = price * _quantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Stock: ${formatQuantity(widget.product.quantity, widget.product.unit)} · ${formatMoney(price)} c/u',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMoney(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < widget.product.quantity
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _sell,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Vender'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sell() async {
    setState(() => _saving = true);
    final store = RelatosScope.of(context);
    try {
      await store.repository.addSale(
        productId: widget.product.id,
        quantity: _quantity.toDouble(),
        total: widget.product.price * _quantity,
      );
      await store.load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Venta de ${widget.product.name} registrada')),
        );
      }
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

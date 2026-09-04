import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Productos terminados',
      emptyTitle: 'Sin productos',
      emptyMessage: 'Toca + para registrar brownies, cupcakes u otros productos.',
      emptyIcon: Icons.cake_outlined,
      onAdd: () => _openForm(context),
      itemCount: store.products.length,
      itemBuilder: (context, index) {
        final item = store.products[index];
        return AppListTile(
          title: item.name,
          subtitle: '${formatQuantity(item.quantity, item.unit)} · ${formatMoney(item.price)}',
          leadingIcon: Icons.cake_outlined,
          onTap: () => _openForm(context, item: item),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, {Product? item}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: item)),
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '0');
  final _price = TextEditingController(text: '0');
  String _unit = 'unidades';

  @override
  void initState() {
    super.initState();
    final item = widget.product;
    if (item != null) {
      _name.text = item.name;
      _quantity.text = _formatValue(item.quantity);
      _unit = item.unit;
      _price.text = _formatValue(item.price);
    }
  }

  String _formatValue(double value) =>
      value.round() == value ? value.round().toString() : value.toString();

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RelatosFormPage(
      title: widget.product == null ? 'Nuevo producto' : 'Editar producto',
      onSave: _save,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _unit,
          decoration: const InputDecoration(labelText: 'Unidad'),
          items: [
            for (final unit in unitOptions)
              DropdownMenuItem(value: unit, child: Text(unit)),
          ],
          onChanged: (value) => setState(() => _unit = value ?? _unit),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cantidad disponible'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Precio de venta'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final quantity = parseDecimal(_quantity.text);
    final price = parseDecimal(_price.text);
    if (name.isEmpty || quantity == null || price == null) {
      await showRelatosError(
          context, RelatosException('Completa todos los campos.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.upsertProduct(
        Product(
          id: widget.product?.id ?? 0,
          name: name,
          unit: _unit,
          quantity: quantity,
          price: price,
        ),
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }
}

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/relatos_scope.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Compras',
      emptyTitle: 'Sin compras',
      emptyMessage: 'Toca + para registrar una compra de ingredientes.',
      emptyIcon: Icons.shopping_bag_outlined,
      onAdd: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
      ),
      itemCount: store.purchases.length,
      itemBuilder: (context, index) {
        final item = store.purchases[index];
        final ingredient = store.ingredientById(item.ingredientId);
        return AppListTile(
          title: ingredient?.name ?? 'Ingrediente',
          subtitle:
              '${formatQuantity(item.quantity, ingredient?.unit ?? '')} · ${formatMoney(item.totalCost)}',
          leadingIcon: Icons.shopping_bag_outlined,
        );
      },
    );
  }
}

class PurchaseFormScreen extends StatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  int? _ingredientId;
  final _quantity = TextEditingController();
  final _total = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _quantity.dispose();
    _total.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = RelatosScope.of(context).ingredients;
    return RelatosFormPage(
      title: 'Nueva compra',
      onSave: _save,
      children: [
        if (ingredients.isEmpty)
          const Text('Primero registra un ingrediente.')
        else
          DropdownButtonFormField<int>(
            initialValue: _ingredientId,
            decoration: const InputDecoration(labelText: 'Ingrediente'),
            items: [
              for (final item in ingredients)
                DropdownMenuItem(value: item.id, child: Text(item.name)),
            ],
            onChanged: (value) => setState(() => _ingredientId = value),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cantidad comprada'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _total,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Costo total'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Notas (opcional)'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final quantity = parseDecimal(_quantity.text);
    final total = parseDecimal(_total.text);
    if (_ingredientId == null || quantity == null || total == null) {
      await showRelatosError(context, RelatosException('Completa la compra.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.addPurchase(
        ingredientId: _ingredientId!,
        quantity: quantity,
        totalCost: total,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }
}

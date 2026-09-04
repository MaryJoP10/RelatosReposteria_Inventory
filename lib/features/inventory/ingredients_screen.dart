import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class IngredientsScreen extends StatelessWidget {
  const IngredientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Ingredientes',
      emptyTitle: 'Sin ingredientes',
      emptyMessage: 'Toca + para registrar harina, mantequilla y demás insumos.',
      emptyIcon: Icons.kitchen_outlined,
      onAdd: () => _openForm(context),
      itemCount: store.ingredients.length,
      itemBuilder: (context, index) {
        final item = store.ingredients[index];
        return AppListTile(
          title: item.name,
          subtitle: formatQuantity(item.quantity, item.unit),
          leadingIcon: Icons.kitchen_outlined,
          trailing: StatusChip(
            label: item.isLow ? 'Bajo' : 'OK',
            kind: item.isLow ? StatusChipKind.alert : StatusChipKind.success,
          ),
          onTap: () => _openForm(context, item: item),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, {Ingredient? item}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => IngredientFormScreen(ingredient: item)),
    );
  }
}

class IngredientFormScreen extends StatefulWidget {
  const IngredientFormScreen({super.key, this.ingredient});

  final Ingredient? ingredient;

  @override
  State<IngredientFormScreen> createState() => _IngredientFormScreenState();
}

class _IngredientFormScreenState extends State<IngredientFormScreen> {
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '0');
  final _minQuantity = TextEditingController(text: '0');
  String _unit = 'kg';

  @override
  void initState() {
    super.initState();
    final item = widget.ingredient;
    if (item != null) {
      _name.text = item.name;
      _quantity.text = _n(item.quantity);
      _minQuantity.text = _n(item.minQuantity);
      _unit = item.unit;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _minQuantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RelatosFormPage(
      title: widget.ingredient == null ? 'Nuevo ingrediente' : 'Editar ingrediente',
      onSave: _save,
      onDelete: widget.ingredient == null ? null : _delete,
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
          decoration: const InputDecoration(labelText: 'Cantidad actual'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _minQuantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Mínimo para alerta'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final quantity = parseDecimal(_quantity.text);
    final minQuantity = parseDecimal(_minQuantity.text);
    if (name.isEmpty || quantity == null || minQuantity == null) {
      await showRelatosError(context, RelatosException('Completa todos los campos.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.upsertIngredient(
        Ingredient(
          id: widget.ingredient?.id ?? 0,
          name: name,
          unit: _unit,
          quantity: quantity,
          minQuantity: minQuantity,
        ),
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }

  Future<void> _delete() async {
    final store = RelatosScope.of(context);
    try {
      await store.repository.deleteIngredient(widget.ingredient!.id);
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }

  String _n(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toString();
}

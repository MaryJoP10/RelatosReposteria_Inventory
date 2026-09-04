import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Recetas',
      emptyTitle: 'Sin recetas',
      emptyMessage: 'Toca + para registrar tus fórmulas de pasteles, galletas, etc.',
      emptyIcon: Icons.menu_book_outlined,
      onAdd: () => _openForm(context),
      itemCount: store.recipes.length,
      itemBuilder: (context, index) {
        final item = store.recipes[index];
        return AppListTile(
          title: item.name,
          subtitle: 'Rinde: ${formatQuantity(item.yieldQuantity, item.yieldUnit)}',
          leadingIcon: Icons.menu_book_outlined,
          onTap: () => _openForm(context, item: item),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, {Recipe? item}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeFormScreen(recipe: item)),
    );
  }
}

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _name = TextEditingController();
  final _yieldQuantity = TextEditingController(text: '1');
  final _notes = TextEditingController();
  String _yieldUnit = 'unidades';
  List<_RecipeLineEditor> _lines = [];

  @override
  void initState() {
    super.initState();
    final item = widget.recipe;
    if (item != null) {
      _name.text = item.name;
      _yieldQuantity.text = _n(item.yieldQuantity);
      _yieldUnit = item.yieldUnit;
      _notes.text = item.notes ?? '';
      _lines = item.lines.map((l) => _RecipeLineEditor(l.ingredientId, l.quantity)).toList();
    } else {
      _lines = [];
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _yieldQuantity.dispose();
    _notes.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    final ingredients = store.ingredients;

    return RelatosFormPage(
      title: widget.recipe == null ? 'Nueva receta' : 'Editar receta',
      onSave: _save,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre de la receta'),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _yieldQuantity,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Rinde (cantidad)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _yieldUnit,
                decoration: const InputDecoration(labelText: 'Unidad de rendimiento'),
                items: [
                  for (final unit in unitOptions)
                    DropdownMenuItem(value: unit, child: Text(unit)),
                ],
                onChanged: (value) => setState(() => _yieldUnit = value ?? _yieldUnit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Notas (opcional)'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Ingredientes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        if (_lines.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No hay ingredientes agregados.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        for (int i = 0; i < _lines.length; i++)
          _buildLine(context, i, ingredients),
      ],
    );
  }

  Widget _buildLine(BuildContext context, int index, List<Ingredient> ingredients) {
    final line = _lines[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: line.ingredientId == 0 ? null : line.ingredientId,
              decoration: const InputDecoration(labelText: 'Ingrediente'),
              items: [
                for (final ing in ingredients)
                  DropdownMenuItem(value: ing.id, child: Text(ing.name)),
              ],
              onChanged: (value) => setState(() => line.ingredientId = value ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: line.quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cant.'),
            ),
          ),
          IconButton(
            onPressed: () => _removeLine(index),
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            padding: const EdgeInsets.only(top: 12),
          ),
        ],
      ),
    );
  }

  void _addLine() {
    setState(() {
      _lines.add(_RecipeLineEditor(0, 0));
    });
  }

  void _removeLine(int index) {
    setState(() {
      final line = _lines.removeAt(index);
      line.dispose();
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final yieldQty = parseDecimal(_yieldQuantity.text);
    final notes = _notes.text.trim();

    if (name.isEmpty || yieldQty == null) {
      await showRelatosError(context, RelatosException('Completa el nombre y rendimiento.'));
      return;
    }

    final recipeLines = <RecipeLine>[];
    for (final line in _lines) {
      final qty = parseDecimal(line.quantityController.text);
      if (line.ingredientId == 0 || qty == null || qty <= 0) {
        await showRelatosError(
          context,
          RelatosException('Verifica los ingredientes y cantidades.'),
        );
        return;
      }
      recipeLines.add(RecipeLine(ingredientId: line.ingredientId, quantity: qty));
    }

    if (recipeLines.isEmpty) {
      await showRelatosError(context, RelatosException('Agrega al menos un ingrediente.'));
      return;
    }

    final store = RelatosScope.of(context);
    try {
      await store.repository.upsertRecipe(
        Recipe(
          id: widget.recipe?.id ?? 0,
          name: name,
          yieldQuantity: yieldQty,
          yieldUnit: _yieldUnit,
          notes: notes.isEmpty ? null : notes,
          lines: recipeLines,
        ),
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }

  String _n(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toString();
}

class _RecipeLineEditor {
  _RecipeLineEditor(this.ingredientId, double quantity)
      : quantityController = TextEditingController(
          text: quantity == 0 ? '' : (quantity == quantity.roundToDouble() ? quantity.round().toString() : quantity.toString()),
        );

  int ingredientId;
  final TextEditingController quantityController;

  void dispose() {
    quantityController.dispose();
  }
}

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class ProductionListScreen extends StatelessWidget {
  const ProductionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return EntityListScaffold(
      title: 'Historial de producción',
      emptyTitle: 'Sin producción',
      emptyMessage: 'Registra tus tandas de producción aquí.',
      emptyIcon: Icons.history,
      onAdd: () => _openForm(context),
      itemCount: store.productions.length,
      itemBuilder: (context, index) {
        final item = store.productions[index];
        final recipe = store.recipes.firstWhere((r) => r.id == item.recipeId, orElse: () => Recipe(id: 0, name: item.recipeName, yieldQuantity: 0, yieldUnit: '', lines: []));
        return AppListTile(
          title: item.recipeName,
          subtitle: formatQuantity(item.units, recipe.yieldUnit),
          leadingIcon: Icons.cookie_outlined,
          trailing: Text(
            item.producedAt.toString().substring(0, 10),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProductionFormScreen()),
    );
  }
}

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  Recipe? _selectedRecipe;
  final _batches = TextEditingController(text: '1');

  @override
  void dispose() {
    _batches.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    return RelatosFormPage(
      title: 'Nueva producción',
      onSave: _save,
      children: [
        DropdownButtonFormField<Recipe>(
          value: _selectedRecipe,
          decoration: const InputDecoration(labelText: 'Receta'),
          items: [
            for (final recipe in store.recipes)
              DropdownMenuItem(value: recipe, child: Text(recipe.name)),
          ],
          onChanged: (value) => setState(() => _selectedRecipe = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _batches,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Tandas (Batches)',
            helperText: 'Multiplicador de las cantidades de la receta.',
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final recipe = _selectedRecipe;
    final batches = parseDecimal(_batches.text);
    if (recipe == null || batches == null) {
      await showRelatosError(context, RelatosException('Selecciona una receta y cantidad.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.addProduction(
        recipeId: recipe.id,
        batches: batches,
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }
}

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);

    // Merge manual expenses and ingredient purchases
    final List<dynamic> allExpenses = [
      ...store.expenses,
      ...store.purchases,
    ];

    // Sort by date descending
    allExpenses.sort((a, b) {
      final dateA = a is Expense ? a.spentAt : (a as Purchase).purchasedAt;
      final dateB = b is Expense ? b.spentAt : (b as Purchase).purchasedAt;
      return dateB.compareTo(dateA);
    });

    return EntityListScaffold(
      title: 'Gastos',
      emptyTitle: 'Sin gastos',
      emptyMessage: 'Las compras y gastos registrados aparecerán aquí.',
      emptyIcon: Icons.north_east,
      itemCount: allExpenses.length,
      itemBuilder: (context, index) {
        final item = allExpenses[index];
        if (item is Expense) {
          return AppListTile(
            title: item.description,
            subtitle:
                '${item.category ?? 'Operación'} - ${formatMoney(item.amount)}',
            leadingIcon: Icons.payments_outlined,
            trailing: Text(
              item.spentAt.toString().substring(0, 10),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        } else {
          final purchase = item as Purchase;
          final ingredient = store.ingredientById(purchase.ingredientId);
          return AppListTile(
            title: 'Compra: ${ingredient?.name ?? 'Insumo'}',
            subtitle: 'Ingrediente - ${formatMoney(purchase.totalCost)}',
            leadingIcon: Icons.shopping_bag_outlined,
            trailing: Text(
              purchase.purchasedAt.toString().substring(0, 10),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
      },
    );
  }
}

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _category = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RelatosFormPage(
      title: 'Nuevo gasto',
      onSave: _save,
      children: [
        TextField(
          controller: _description,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Descripción'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Monto', prefixText: r'$ '),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _category,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Categoría (opcional)'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final description = _description.text.trim();
    final amount = parseDecimal(_amount.text);
    final category = _category.text.trim();
    if (description.isEmpty || amount == null) {
      await showRelatosError(context, RelatosException('Completa descripción y monto.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.addExpense(
        description: description,
        amount: amount,
        category: category.isEmpty ? null : category,
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }
}

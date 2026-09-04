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
    return EntityListScaffold(
      title: 'Gastos',
      emptyTitle: 'Sin gastos',
      emptyMessage: 'Registra tus gastos operativos aquí.',
      emptyIcon: Icons.north_east,
      onAdd: () => _openForm(context),
      itemCount: store.expenses.length,
      itemBuilder: (context, index) {
        final item = store.expenses[index];
        return AppListTile(
          title: item.description,
          subtitle: '${item.category ?? 'General'} - ${formatMoney(item.amount)}',
          leadingIcon: Icons.north_east,
          trailing: Text(
            item.spentAt.toString().substring(0, 10),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
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

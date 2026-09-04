import 'package:flutter/material.dart';

import '../theme/relatos_spacing.dart';
import 'empty_state.dart';

class EntityListScaffold extends StatelessWidget {
  const EntityListScaffold({
    super.key,
    required this.title,
    this.onAdd,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
    this.emptyIcon = Icons.add_circle_outline,
  });

  final String title;
  final VoidCallback? onAdd;
  final String emptyTitle;
  final String emptyMessage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: onAdd == null
          ? null
          : FloatingActionButton(
              onPressed: onAdd,
              tooltip: 'Agregar',
              child: const Icon(Icons.add),
            ),
      body: itemCount == 0
          ? EmptyState(
              title: emptyTitle,
              message: emptyMessage,
              icon: emptyIcon,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                RelatosSpacing.page,
                RelatosSpacing.md,
                RelatosSpacing.page,
                88,
              ),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: RelatosSpacing.md),
              itemBuilder: (context, index) {
                return Card(child: itemBuilder(context, index));
              },
            ),
    );
  }
}

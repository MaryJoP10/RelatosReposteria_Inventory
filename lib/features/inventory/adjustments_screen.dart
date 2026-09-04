import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/entity_list_scaffold.dart';
import '../../core/widgets/relatos_form_page.dart';
import '../../data/memory_repository.dart';
import '../../data/relatos_scope.dart';

class AdjustmentsScreen extends StatelessWidget {
  const AdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdjustmentFormScreen()),
        ),
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Usa + para corregir existencias por merma, conteo o error de captura. El ajuste queda aplicado al inventario.',
        ),
      ),
    );
  }
}

class AdjustmentFormScreen extends StatefulWidget {
  const AdjustmentFormScreen({super.key});

  @override
  State<AdjustmentFormScreen> createState() => _AdjustmentFormScreenState();
}

class _AdjustmentFormScreenState extends State<AdjustmentFormScreen> {
  String _target = 'ingredient';
  int? _itemId;
  final _delta = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _delta.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = RelatosScope.of(context);
    final items = _target == 'ingredient' ? store.ingredients : store.products;
    return RelatosFormPage(
      title: 'Nuevo ajuste',
      onSave: _save,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _target,
          decoration: const InputDecoration(labelText: 'Inventario'),
          items: const [
            DropdownMenuItem(value: 'ingredient', child: Text('Ingrediente')),
            DropdownMenuItem(value: 'product', child: Text('Producto terminado')),
          ],
          onChanged: (value) {
            setState(() {
              _target = value ?? _target;
              _itemId = null;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _itemId,
          decoration: const InputDecoration(labelText: 'Ítem'),
          items: [
            for (final item in items)
              DropdownMenuItem(
                value: item.id,
                child: Text(
                  item is dynamic && item.name is String
                      ? item.name as String
                      : '${item.id}',
                ),
              ),
          ],
          onChanged: (value) => setState(() => _itemId = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _delta,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Cantidad (+ o −)',
            helperText: 'Ejemplo: -0.5 para merma',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reason,
          decoration: const InputDecoration(labelText: 'Motivo'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final delta = parseDecimal(_delta.text);
    if (_itemId == null || delta == null) {
      await showRelatosError(context, RelatosException('Completa el ajuste.'));
      return;
    }
    final store = RelatosScope.of(context);
    try {
      await store.repository.addAdjustment(
        target: _target,
        itemId: _itemId!,
        delta: delta,
        reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      );
      await store.load();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) await showRelatosError(context, error);
    }
  }
}

class AdjustmentListPreview extends StatelessWidget {
  const AdjustmentListPreview({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppListTile(title: label);
  }
}

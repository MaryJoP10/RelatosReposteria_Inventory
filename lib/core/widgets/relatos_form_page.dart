import 'package:flutter/material.dart';

import '../theme/relatos_spacing.dart';

Future<void> showRelatosError(BuildContext context, Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('No se pudo guardar'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

const unitOptions = ['unidades', 'kg', 'g', 'L', 'ml', 'tazas'];

class RelatosFormPage extends StatelessWidget {
  const RelatosFormPage({
    super.key,
    required this.title,
    required this.onSave,
    required this.children,
  });

  final String title;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RelatosSpacing.page,
          RelatosSpacing.md,
          RelatosSpacing.page,
          RelatosSpacing.xxl,
        ),
        children: [
          ...children,
          const SizedBox(height: RelatosSpacing.xl),
          FilledButton(
            onPressed: onSave,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

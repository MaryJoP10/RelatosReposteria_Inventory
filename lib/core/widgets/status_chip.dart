import 'package:flutter/material.dart';

import '../theme/relatos_colors.dart';
import '../theme/relatos_spacing.dart';

enum StatusChipKind { success, alert, neutral }

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.kind = StatusChipKind.neutral,
  });

  final String label;
  final StatusChipKind kind;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (kind) {
      StatusChipKind.success => (
          RelatosColors.successContainer,
          RelatosColors.success,
        ),
      StatusChipKind.alert => (
          RelatosColors.alertContainer,
          RelatosColors.alert,
        ),
      StatusChipKind.neutral => (
          RelatosColors.primaryContainer,
          RelatosColors.onPrimaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RelatosSpacing.md,
        vertical: RelatosSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: RelatosRadii.chip,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

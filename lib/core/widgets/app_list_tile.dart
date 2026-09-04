import 'package:flutter/material.dart';

import '../theme/relatos_colors.dart';
import '../theme/relatos_spacing.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: leadingIcon == null
          ? null
          : CircleAvatar(
              backgroundColor: RelatosColors.primaryContainer,
              foregroundColor: RelatosColors.primaryDark,
              child: Icon(leadingIcon, size: 20),
            ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
      minVerticalPadding: RelatosSpacing.sm,
    );
  }
}

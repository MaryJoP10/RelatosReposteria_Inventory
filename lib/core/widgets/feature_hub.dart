import 'package:flutter/material.dart';

import '../theme/relatos_spacing.dart';
import 'app_list_tile.dart';
import 'empty_state.dart';

class HubAction {
  const HubAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class FeatureHubScreen extends StatelessWidget {
  const FeatureHubScreen({
    super.key,
    required this.title,
    required this.actions,
  });

  final String title;
  final List<HubAction> actions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RelatosSpacing.page),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RelatosSpacing.lg),
        for (final action in actions) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RelatosSpacing.lg,
                vertical: RelatosSpacing.sm,
              ),
              child: AppListTile(
                title: action.title,
                subtitle: action.subtitle,
                leadingIcon: action.icon,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: action.builder),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: RelatosSpacing.md),
        ],
      ],
    );
  }
}

class PlaceholderDetailScreen extends StatelessWidget {
  const PlaceholderDetailScreen({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        title: 'Próximamente',
        message: description,
        icon: Icons.bakery_dining_outlined,
      ),
    );
  }
}

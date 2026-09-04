import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/relatos_spacing.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../data/models.dart';
import '../../data/relatos_scope.dart';

class DashboardScreen extends StatelessWidget {
// ... (rest of DashboardScreen unchanged until _MetricsRow)
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = RelatosScope.of(context).dashboard;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= RelatosBreakpoints.wide;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                RelatosSpacing.page,
                RelatosSpacing.lg,
                RelatosSpacing.page,
                RelatosSpacing.xxl,
              ),
              sliver: SliverList.list(
                children: [
                  const BrandLogo(
                    showTagline: true,
                    size: BrandLogoSize.large,
                  ),
                  const SizedBox(height: RelatosSpacing.xl),
                  _MetricsRow(data: data, wide: wide),
                  const SizedBox(height: RelatosSpacing.lg),
                  _InventoryRow(data: data, wide: wide),
                  const SizedBox(height: RelatosSpacing.lg),
                  SectionCard(
                    title: 'Producción reciente',
                    child: data.recentProductions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(RelatosSpacing.md),
                            child: Text('No hay producciones recientes.'),
                          )
                        : Column(
                            children: [
                              for (var i = 0;
                                  i < data.recentProductions.length;
                                  i++) ...[
                                AppListTile(
                                  title: data.recentProductions[i].recipeName,
                                  subtitle:
                                      '${data.recentProductions[i].units} unidades',
                                  leadingIcon: Icons.bakery_dining_outlined,
                                  trailing: const StatusChip(
                                    label: 'Listo',
                                    kind: StatusChipKind.success,
                                  ),
                                ),
                                if (i < data.recentProductions.length - 1)
                                  const Divider(),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: RelatosSpacing.lg),
                  SectionCard(
                    title: 'Alertas de inventario',
                    child: data.lowStock.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(RelatosSpacing.md),
                            child: Text('Todo en orden en el inventario.'),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < data.lowStock.length; i++) ...[
                                AppListTile(
                                  title: data.lowStock[i].name,
                                  subtitle:
                                      'Stock actual: ${data.lowStock[i].quantity} ${data.lowStock[i].unit}',
                                  leadingIcon: Icons.warning_amber_rounded,
                                  trailing: const StatusChip(
                                    label: 'Bajo',
                                    kind: StatusChipKind.alert,
                                  ),
                                ),
                                if (i < data.lowStock.length - 1)
                                  const Divider(),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.data, required this.wide});

  final DashboardSnapshot data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(
        label: 'Ventas',
        value: formatMoney(data.salesTotal),
        icon: Icons.point_of_sale_outlined,
      ),
      MetricCard(
        label: 'Gastos',
        value: formatMoney(data.expensesTotal),
        icon: Icons.payments_outlined,
      ),
      MetricCard(
        label: 'Ganancia',
        value: formatMoney(data.profit),
        icon: Icons.trending_up_rounded,
        highlighted: true,
      ),
    ];

    if (wide) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: RelatosSpacing.md),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i < cards.length - 1) const SizedBox(height: RelatosSpacing.md),
        ],
      ],
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.data, required this.wide});

  final DashboardSnapshot data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final ingredients = MetricCard(
      label: 'Ingredientes',
      value: '${data.ingredientsCount} disponibles',
      icon: Icons.kitchen_outlined,
    );
    final products = MetricCard(
      label: 'Productos',
      value: '${data.finishedProductUnits.round()} unidades',
      icon: Icons.cake_outlined,
    );

    if (wide) {
      return Row(
        children: [
          Expanded(child: ingredients),
          const SizedBox(width: RelatosSpacing.md),
          Expanded(child: products),
        ],
      );
    }

    return Column(
      children: [
        ingredients,
        const SizedBox(height: RelatosSpacing.md),
        products,
      ],
    );
  }
}

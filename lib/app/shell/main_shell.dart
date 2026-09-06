import 'package:flutter/material.dart';

import '../../core/theme/relatos_spacing.dart';
import '../../core/widgets/brand_logo.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/finance/finance_hub_screen.dart';
import '../../features/inventory/inventory_hub_screen.dart';
import '../../features/production/production_hub_screen.dart';
import '../../features/sales/sales_hub_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2_rounded),
      label: 'Inventario',
    ),
    NavigationDestination(
      icon: Icon(Icons.bakery_dining_outlined),
      selectedIcon: Icon(Icons.bakery_dining),
      label: 'Producción',
    ),
    NavigationDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: 'Ventas',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Finanzas',
    ),
  ];

  static const _pages = [
    DashboardScreen(),
    InventoryHubScreen(),
    ProductionHubScreen(),
    SalesHubScreen(),
    FinanceHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= RelatosBreakpoints.wide;
        final body = IndexedStack(index: _index, children: _pages);

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  extended: constraints.maxWidth >= 1100,
                  onDestinationSelected: (value) {
                    setState(() => _index = value);
                  },
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: RelatosSpacing.lg),
                    child: BrandLogo(size: BrandLogoSize.compact),
                  ),
                  destinations: [
                    for (final dest in _destinations)
                      NavigationRailDestination(
                        icon: dest.icon,
                        selectedIcon: dest.selectedIcon,
                        label: Text(dest.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const BrandLogo(size: BrandLogoSize.compact)),
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 11),
            ),
            destinations: _destinations,
            onDestinationSelected: (value) {
              setState(() => _index = value);
            },
          ),
        );
      },
    );
  }
}

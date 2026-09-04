class DashboardSnapshot {
  const DashboardSnapshot({
    required this.sales,
    required this.expenses,
    required this.profit,
    required this.ingredientsAvailable,
    required this.finishedProducts,
    required this.recentProductions,
    required this.lowStockAlerts,
  });

  final String sales;
  final String expenses;
  final String profit;
  final int ingredientsAvailable;
  final int finishedProducts;
  final List<ProductionItem> recentProductions;
  final List<StockAlert> lowStockAlerts;
}

class ProductionItem {
  const ProductionItem({required this.name, required this.units});

  final String name;
  final int units;
}

class StockAlert {
  const StockAlert({required this.name, required this.detail});

  final String name;
  final String detail;
}

const dashboardMock = DashboardSnapshot(
  sales: r'$1.240.000',
  expenses: r'$480.000',
  profit: r'$760.000',
  ingredientsAvailable: 24,
  finishedProducts: 38,
  recentProductions: [
    ProductionItem(name: 'Brownies', units: 20),
    ProductionItem(name: 'Cupcakes', units: 12),
    ProductionItem(name: 'Galletas de avena', units: 30),
  ],
  lowStockAlerts: [
    StockAlert(name: 'Harina de trigo', detail: 'Quedan 1.2 kg'),
    StockAlert(name: 'Mantequilla', detail: 'Quedan 250 g'),
  ],
);

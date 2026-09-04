import 'package:flutter/foundation.dart';

import 'models.dart';
import 'repository.dart';

class RelatosStore extends ChangeNotifier {
  RelatosStore(this.repository);

  final RelatosRepository repository;

  List<Ingredient> ingredients = const [];
  List<Product> products = const [];
  List<Purchase> purchases = const [];
  List<Recipe> recipes = const [];
  List<Production> productions = const [];
  List<Sale> sales = const [];
  List<Expense> expenses = const [];
  DashboardSnapshot dashboard = const DashboardSnapshot(
    salesTotal: 0,
    expensesTotal: 0,
    ingredientsCount: 0,
    finishedProductUnits: 0,
    recentProductions: [],
    lowStock: [],
  );

  Future<void> load() async {
    ingredients = await repository.ingredients();
    products = await repository.products();
    purchases = await repository.purchases();
    recipes = await repository.recipes();
    productions = await repository.productions();
    sales = await repository.sales();
    expenses = await repository.expenses();
    dashboard = await repository.dashboard();
    notifyListeners();
  }

  Ingredient? ingredientById(int id) {
    for (final item in ingredients) {
      if (item.id == id) return item;
    }
    return null;
  }

  Product? productById(int id) {
    for (final item in products) {
      if (item.id == id) return item;
    }
    return null;
  }
}

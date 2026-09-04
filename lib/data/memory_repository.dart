import 'models.dart';
import 'repository.dart';

class RelatosException implements Exception {
  RelatosException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MemoryRelatosRepository implements RelatosRepository {
  int _nextId = 1;
  final List<Ingredient> _ingredients = [];
  final List<Product> _products = [];
  final List<Purchase> _purchases = [];
  final List<Recipe> _recipes = [];
  final List<Production> _productions = [];
  final List<Sale> _sales = [];
  final List<Expense> _expenses = [];

  int _id() => _nextId++;

  @override
  Future<List<Ingredient>> ingredients() async => List.unmodifiable(_ingredients);

  @override
  Future<Ingredient> upsertIngredient(Ingredient ingredient) async {
    if (ingredient.id == 0) {
      final created = ingredient.copyWith(id: _id());
      _ingredients.add(created);
      return created;
    }
    final index = _ingredients.indexWhere((item) => item.id == ingredient.id);
    if (index < 0) {
      throw RelatosException('Ingrediente no encontrado.');
    }
    _ingredients[index] = ingredient;
    return ingredient;
  }

  @override
  Future<void> deleteIngredient(int id) async {
    _ingredients.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Product>> products() async => List.unmodifiable(_products);

  @override
  Future<Product> upsertProduct(Product product) async {
    if (product.id == 0) {
      final created = product.copyWith(id: _id());
      _products.add(created);
      return created;
    }
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index < 0) {
      throw RelatosException('Producto no encontrado.');
    }
    _products[index] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    _products.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Purchase>> purchases() async =>
      List.unmodifiable(_purchases.reversed);

  @override
  Future<Purchase> addPurchase({
    required int ingredientId,
    required double quantity,
    required double totalCost,
    String? notes,
    DateTime? purchasedAt,
  }) async {
    final ingredient = _ingredient(ingredientId);
    final purchase = Purchase(
      id: _id(),
      ingredientId: ingredientId,
      quantity: quantity,
      totalCost: totalCost,
      purchasedAt: purchasedAt ?? DateTime.now(),
      notes: notes,
    );
    _purchases.add(purchase);
    _replaceIngredient(
      ingredient.copyWith(
        quantity: ingredient.quantity + quantity,
      ),
    );
    return purchase;
  }

  @override
  Future<List<Recipe>> recipes() async => List.unmodifiable(_recipes);

  @override
  Future<Recipe> upsertRecipe(Recipe recipe) async {
    if (recipe.id == 0) {
      final created = Recipe(
        id: _id(),
        name: recipe.name,
        yieldQuantity: recipe.yieldQuantity,
        yieldUnit: recipe.yieldUnit,
        notes: recipe.notes,
        lines: recipe.lines,
      );
      _recipes.add(created);
      return created;
    }
    final index = _recipes.indexWhere((item) => item.id == recipe.id);
    if (index < 0) {
      throw RelatosException('Receta no encontrada.');
    }
    _recipes[index] = recipe;
    return recipe;
  }

  @override
  Future<void> deleteRecipe(int id) async {
    _recipes.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Production>> productions() async =>
      List.unmodifiable(_productions.reversed);

  @override
  Future<Production> addProduction({
    required int recipeId,
    required double batches,
    DateTime? producedAt,
  }) async {
    final recipe = _recipe(recipeId);
    for (final line in recipe.lines) {
      final ingredient = _ingredient(line.ingredientId);
      final needed = line.quantity * batches;
      if (ingredient.quantity + 0.0001 < needed) {
        throw RelatosException(
          'No hay suficiente ${ingredient.name} para producir.',
        );
      }
      _replaceIngredient(
        ingredient.copyWith(quantity: ingredient.quantity - needed),
      );
    }

    final units = recipe.yieldQuantity * batches;
    final product = _productByName(recipe.name) ??
        await upsertProduct(
          Product(
            id: 0,
            name: recipe.name,
            unit: recipe.yieldUnit,
            quantity: 0,
            price: 0,
          ),
        );
    _replaceProduct(product.copyWith(quantity: product.quantity + units));

    final production = Production(
      id: _id(),
      recipeId: recipe.id,
      recipeName: recipe.name,
      units: units,
      producedAt: producedAt ?? DateTime.now(),
    );
    _productions.add(production);
    return production;
  }

  @override
  Future<List<Sale>> sales() async => List.unmodifiable(_sales.reversed);

  @override
  Future<Sale> addSale({
    required int productId,
    required double quantity,
    required double total,
    DateTime? soldAt,
  }) async {
    final product = _product(productId);
    if (product.quantity + 0.0001 < quantity) {
      throw RelatosException('No hay suficiente ${product.name} para vender.');
    }
    _replaceProduct(product.copyWith(quantity: product.quantity - quantity));
    final sale = Sale(
      id: _id(),
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      total: total,
      soldAt: soldAt ?? DateTime.now(),
    );
    _sales.add(sale);
    return sale;
  }

  @override
  Future<List<Expense>> expenses() async => List.unmodifiable(_expenses.reversed);

  @override
  Future<Expense> addExpense({
    required String description,
    required double amount,
    String? category,
    DateTime? spentAt,
  }) async {
    final expense = Expense(
      id: _id(),
      description: description,
      amount: amount,
      spentAt: spentAt ?? DateTime.now(),
      category: category,
    );
    _expenses.add(expense);
    return expense;
  }

  @override
  Future<void> addAdjustment({
    required String target,
    required int itemId,
    required double delta,
    String? reason,
  }) async {
    if (target == 'ingredient') {
      final item = _ingredient(itemId);
      _replaceIngredient(item.copyWith(quantity: item.quantity + delta));
      return;
    }
    final item = _product(itemId);
    _replaceProduct(item.copyWith(quantity: item.quantity + delta));
  }

  @override
  Future<DashboardSnapshot> dashboard() async {
    return DashboardSnapshot(
      salesTotal: _sales.fold(0.0, (sum, item) => sum + item.total),
      expensesTotal: _expenses.fold(0.0, (sum, item) => sum + item.amount) +
          _purchases.fold(0.0, (sum, item) => sum + item.totalCost),
      ingredientsCount: _ingredients.length,
      finishedProductUnits:
          _products.fold(0.0, (sum, item) => sum + item.quantity),
      recentProductions: _productions.reversed.take(5).toList(),
      lowStock: _ingredients.where((item) => item.isLow).toList(),
    );
  }

  Ingredient _ingredient(int id) {
    return _ingredients.firstWhere(
      (item) => item.id == id,
      orElse: () => throw RelatosException('Ingrediente no encontrado.'),
    );
  }

  Product _product(int id) {
    return _products.firstWhere(
      (item) => item.id == id,
      orElse: () => throw RelatosException('Producto no encontrado.'),
    );
  }

  Product? _productByName(String name) {
    for (final item in _products) {
      if (item.name.toLowerCase() == name.toLowerCase()) return item;
    }
    return null;
  }

  Recipe _recipe(int id) {
    return _recipes.firstWhere(
      (item) => item.id == id,
      orElse: () => throw RelatosException('Receta no encontrada.'),
    );
  }

  void _replaceIngredient(Ingredient ingredient) {
    final index = _ingredients.indexWhere((item) => item.id == ingredient.id);
    _ingredients[index] = ingredient;
  }

  void _replaceProduct(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    _products[index] = product;
  }
}

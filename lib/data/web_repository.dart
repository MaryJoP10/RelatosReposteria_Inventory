import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'repository.dart';

class WebRelatosRepository implements RelatosRepository {
  WebRelatosRepository._(this._prefs, this._data);

  final SharedPreferencesAsync _prefs;
  final Map<String, dynamic> _data;

  static const String _storageKey = 'relatos_web_database';

  static Future<WebRelatosRepository> open() async {
    final prefs = SharedPreferencesAsync();

    final raw = await prefs.getString(_storageKey);

    Map<String, dynamic> data;

    if (raw == null || raw.isEmpty) {
      data = _emptyDatabase();
    } else {
      try {
        data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        data = _emptyDatabase();
      }
    }

    return WebRelatosRepository._(prefs, data);
  }

  static Map<String, dynamic> _emptyDatabase() {
    return {
      'ingredients': <dynamic>[],
      'products': <dynamic>[],
      'purchases': <dynamic>[],
      'recipes': <dynamic>[],
      'recipe_lines': <dynamic>[],
      'productions': <dynamic>[],
      'sales': <dynamic>[],
      'expenses': <dynamic>[],
      'next_ids': {
        'ingredients': 1,
        'products': 1,
        'purchases': 1,
        'recipes': 1,
        'productions': 1,
        'sales': 1,
        'expenses': 1,
      },
    };
  }

  Future<void> _save() async {
    await _prefs.setString(_storageKey, jsonEncode(_data));
  }

  List<Map<String, dynamic>> _list(String key) {
    final value = _data[key];

    if (value == null) {
      _data[key] = <dynamic>[];
      return [];
    }

    return (value as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  int _nextId(String table) {
    final nextIds = Map<String, dynamic>.from(_data['next_ids'] as Map);

    final id = (nextIds[table] as num?)?.toInt() ?? 1;

    nextIds[table] = id + 1;
    _data['next_ids'] = nextIds;

    return id;
  }

  DateTime _date(dynamic value) {
    return DateTime.parse(value as String);
  }

  // ============================================================
  // INGREDIENTS
  // ============================================================

  @override
  Future<List<Ingredient>> ingredients() async {
    final rows = _list('ingredients');

    rows.sort(
      (a, b) => (a['name'] as String).toLowerCase().compareTo(
        (b['name'] as String).toLowerCase(),
      ),
    );

    return rows.map((row) {
      return Ingredient(
        id: row['id'] as int,
        name: row['name'] as String,
        unit: row['unit'] as String,
        quantity: (row['quantity'] as num).toDouble(),
        minQuantity: (row['minQuantity'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<Ingredient> upsertIngredient(Ingredient ingredient) async {
    final rows = _list('ingredients');

    if (ingredient.id == 0) {
      final created = ingredient.copyWith(id: _nextId('ingredients'));

      rows.add({
        'id': created.id,
        'name': created.name,
        'unit': created.unit,
        'quantity': created.quantity,
        'minQuantity': created.minQuantity,
      });

      _data['ingredients'] = rows;
      await _save();

      return created;
    }

    final index = rows.indexWhere((row) => row['id'] == ingredient.id);

    if (index >= 0) {
      rows[index] = {
        'id': ingredient.id,
        'name': ingredient.name,
        'unit': ingredient.unit,
        'quantity': ingredient.quantity,
        'minQuantity': ingredient.minQuantity,
      };

      _data['ingredients'] = rows;
      await _save();
    }

    return ingredient;
  }

  @override
  Future<void> deleteIngredient(int id) async {
    final rows = _list('ingredients');

    rows.removeWhere((row) => row['id'] == id);

    _data['ingredients'] = rows;

    await _save();
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  @override
  Future<List<Product>> products() async {
    final rows = _list('products');

    rows.sort(
      (a, b) => (a['name'] as String).toLowerCase().compareTo(
        (b['name'] as String).toLowerCase(),
      ),
    );

    return rows.map((row) {
      return Product(
        id: row['id'] as int,
        name: row['name'] as String,
        unit: row['unit'] as String,
        quantity: (row['quantity'] as num).toDouble(),
        price: (row['price'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  @override
  Future<Product> upsertProduct(Product product) async {
    final rows = _list('products');

    if (product.id == 0) {
      final created = product.copyWith(id: _nextId('products'));

      rows.add({
        'id': created.id,
        'name': created.name,
        'unit': created.unit,
        'quantity': created.quantity,
        'price': created.price,
      });

      _data['products'] = rows;
      await _save();

      return created;
    }

    final index = rows.indexWhere((row) => row['id'] == product.id);

    if (index >= 0) {
      rows[index] = {
        'id': product.id,
        'name': product.name,
        'unit': product.unit,
        'quantity': product.quantity,
        'price': product.price,
      };

      _data['products'] = rows;
      await _save();
    }

    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    final rows = _list('products');

    rows.removeWhere((row) => row['id'] == id);

    _data['products'] = rows;

    await _save();
  }

  // ============================================================
  // PURCHASES
  // ============================================================

  @override
  Future<List<Purchase>> purchases() async {
    final rows = _list('purchases');

    rows.sort(
      (a, b) => _date(b['purchasedAt']).compareTo(_date(a['purchasedAt'])),
    );

    return rows.map((row) {
      return Purchase(
        id: row['id'] as int,
        ingredientId: row['ingredientId'] as int,
        quantity: (row['quantity'] as num).toDouble(),
        totalCost: (row['totalCost'] as num).toDouble(),
        purchasedAt: _date(row['purchasedAt']),
        notes: row['notes'] as String?,
      );
    }).toList();
  }

  @override
  Future<Purchase> addPurchase({
    required int ingredientId,
    required double quantity,
    required double totalCost,
    String? notes,
    DateTime? purchasedAt,
  }) async {
    final ingredients = _list('ingredients');

    final ingredientIndex = ingredients.indexWhere(
      (row) => row['id'] == ingredientId,
    );

    if (ingredientIndex < 0) {
      throw Exception('Ingrediente no encontrado.');
    }

    final ingredient = ingredients[ingredientIndex];

    ingredient['quantity'] =
        (ingredient['quantity'] as num).toDouble() + quantity;

    final purchase = Purchase(
      id: _nextId('purchases'),
      ingredientId: ingredientId,
      quantity: quantity,
      totalCost: totalCost,
      purchasedAt: purchasedAt ?? DateTime.now(),
      notes: notes,
    );

    final purchases = _list('purchases');

    purchases.add({
      'id': purchase.id,
      'ingredientId': purchase.ingredientId,
      'quantity': purchase.quantity,
      'totalCost': purchase.totalCost,
      'purchasedAt': purchase.purchasedAt.toIso8601String(),
      'notes': purchase.notes,
    });

    _data['ingredients'] = ingredients;
    _data['purchases'] = purchases;

    await _save();

    return purchase;
  }

  @override
  Future<void> deletePurchase(int id) async {
    final purchases = _list('purchases');

    final index = purchases.indexWhere((row) => row['id'] == id);

    if (index < 0) {
      return;
    }

    final purchase = purchases[index];

    final ingredients = _list('ingredients');

    final ingredientIndex = ingredients.indexWhere(
      (row) => row['id'] == purchase['ingredientId'],
    );

    if (ingredientIndex >= 0) {
      ingredients[ingredientIndex]['quantity'] =
          (ingredients[ingredientIndex]['quantity'] as num).toDouble() -
          (purchase['quantity'] as num).toDouble();
    }

    purchases.removeAt(index);

    _data['ingredients'] = ingredients;
    _data['purchases'] = purchases;

    await _save();
  }

  // ============================================================
  // RECIPES
  // ============================================================

  @override
  Future<List<Recipe>> recipes() async {
    final recipes = _list('recipes');
    final lines = _list('recipe_lines');

    recipes.sort(
      (a, b) => (a['name'] as String).toLowerCase().compareTo(
        (b['name'] as String).toLowerCase(),
      ),
    );

    return recipes.map((recipe) {
      final recipeId = recipe['id'] as int;

      final recipeLines = lines
          .where((line) => line['recipeId'] == recipeId)
          .map(
            (line) => RecipeLine(
              ingredientId: line['ingredientId'] as int,
              quantity: (line['quantity'] as num).toDouble(),
            ),
          )
          .toList();

      return Recipe(
        id: recipeId,
        name: recipe['name'] as String,
        yieldQuantity: (recipe['yieldQuantity'] as num).toDouble(),
        yieldUnit: recipe['yieldUnit'] as String,
        lines: recipeLines,
        notes: recipe['notes'] as String?,
      );
    }).toList();
  }

  @override
  Future<Recipe> upsertRecipe(Recipe recipe) async {
    final recipes = _list('recipes');
    final lines = _list('recipe_lines');

    int recipeId = recipe.id;

    if (recipeId == 0) {
      recipeId = _nextId('recipes');
    }

    final row = {
      'id': recipeId,
      'name': recipe.name,
      'yieldQuantity': recipe.yieldQuantity,
      'yieldUnit': recipe.yieldUnit,
      'notes': recipe.notes,
    };

    final index = recipes.indexWhere((item) => item['id'] == recipeId);

    if (index >= 0) {
      recipes[index] = row;
    } else {
      recipes.add(row);
    }

    lines.removeWhere((line) => line['recipeId'] == recipeId);

    for (final line in recipe.lines) {
      lines.add({
        'recipeId': recipeId,
        'ingredientId': line.ingredientId,
        'quantity': line.quantity,
      });
    }

    _data['recipes'] = recipes;
    _data['recipe_lines'] = lines;

    await _save();

    return Recipe(
      id: recipeId,
      name: recipe.name,
      yieldQuantity: recipe.yieldQuantity,
      yieldUnit: recipe.yieldUnit,
      lines: recipe.lines,
      notes: recipe.notes,
    );
  }

  @override
  Future<void> deleteRecipe(int id) async {
    final recipes = _list('recipes');
    final lines = _list('recipe_lines');

    recipes.removeWhere((row) => row['id'] == id);

    lines.removeWhere((row) => row['recipeId'] == id);

    _data['recipes'] = recipes;
    _data['recipe_lines'] = lines;

    await _save();
  }

  // ============================================================
  // PRODUCTIONS
  // ============================================================

  @override
  Future<List<Production>> productions() async {
    final rows = _list('productions');

    rows.sort(
      (a, b) => _date(b['producedAt']).compareTo(_date(a['producedAt'])),
    );

    return rows.map((row) {
      return Production(
        id: row['id'] as int,
        recipeId: row['recipeId'] as int,
        recipeName: row['recipeName'] as String,
        units: (row['units'] as num).toDouble(),
        producedAt: _date(row['producedAt']),
      );
    }).toList();
  }

  @override
  Future<Production> addProduction({
    required int recipeId,
    required double batches,
    DateTime? producedAt,
  }) async {
    final recipes = _list('recipes');

    final recipeIndex = recipes.indexWhere((row) => row['id'] == recipeId);

    if (recipeIndex < 0) {
      throw Exception('Receta no encontrada.');
    }

    final recipe = recipes[recipeIndex];

    final lines = _list('recipe_lines');

    final recipeLines = lines
        .where((line) => line['recipeId'] == recipeId)
        .toList();

    final ingredients = _list('ingredients');

    // ------------------------------------------------------------
    // 1. Comprobar toda la materia prima antes de descontar nada.
    // ------------------------------------------------------------

    for (final line in recipeLines) {
      final ingredientId = line['ingredientId'] as int;

      final ingredientIndex = ingredients.indexWhere(
        (row) => row['id'] == ingredientId,
      );

      if (ingredientIndex < 0) {
        throw Exception('No se encontró uno de los ingredientes de la receta.');
      }

      final requiredQuantity = (line['quantity'] as num).toDouble() * batches;

      final availableQuantity =
          (ingredients[ingredientIndex]['quantity'] as num).toDouble();

      // Misma tolerancia utilizada por SQLite.
      if (availableQuantity + 0.0001 < requiredQuantity) {
        throw Exception(
          'No hay suficiente ${ingredients[ingredientIndex]['name']}.',
        );
      }
    }

    // ------------------------------------------------------------
    // 2. Descontar ingredientes.
    // ------------------------------------------------------------

    for (final line in recipeLines) {
      final ingredientId = line['ingredientId'] as int;

      final ingredientIndex = ingredients.indexWhere(
        (row) => row['id'] == ingredientId,
      );

      final requiredQuantity = (line['quantity'] as num).toDouble() * batches;

      ingredients[ingredientIndex]['quantity'] =
          (ingredients[ingredientIndex]['quantity'] as num).toDouble() -
          requiredQuantity;
    }

    // ------------------------------------------------------------
    // 3. Añadir producto terminado.
    //
    // IMPORTANTE:
    // Buscamos el producto ignorando mayúsculas/minúsculas,
    // igual que SQLite con LOWER(name).
    // ------------------------------------------------------------

    final products = _list('products');

    final recipeName = recipe['name'] as String;
    final recipeNameNormalized = recipeName.trim().toLowerCase();

    final yieldQuantity = (recipe['yieldQuantity'] as num).toDouble();

    final unitsProduced = yieldQuantity * batches;

    final productIndex = products.indexWhere(
      (product) =>
          (product['name'] as String).trim().toLowerCase() ==
          recipeNameNormalized,
    );

    if (productIndex >= 0) {
      // EL PRODUCTO YA EXISTE.
      //
      // Conservamos absolutamente todo lo que ya tenía:
      // - id
      // - nombre
      // - unidad
      // - precio
      //
      // Solamente aumentamos el stock.

      products[productIndex]['quantity'] =
          (products[productIndex]['quantity'] as num).toDouble() +
          unitsProduced;
    } else {
      // EL PRODUCTO NO EXISTE.
      //
      // En este caso sí se crea automáticamente con precio 0.
      // Después el usuario puede asignarle su precio.

      products.add({
        'id': _nextId('products'),
        'name': recipeName,
        'unit': recipe['yieldUnit'],
        'quantity': unitsProduced,
        'price': 0.0,
      });
    }

    // ------------------------------------------------------------
    // 4. Registrar producción.
    // ------------------------------------------------------------

    final production = Production(
      id: _nextId('productions'),
      recipeId: recipeId,
      recipeName: recipeName,
      units: unitsProduced,
      producedAt: producedAt ?? DateTime.now(),
    );

    final productions = _list('productions');

    productions.add({
      'id': production.id,
      'recipeId': production.recipeId,
      'recipeName': production.recipeName,
      'units': production.units,
      'producedAt': production.producedAt.toIso8601String(),
    });

    _data['ingredients'] = ingredients;
    _data['products'] = products;
    _data['productions'] = productions;

    await _save();

    return production;
  }

  // ============================================================
  // SALES
  // ============================================================

  @override
  Future<List<Sale>> sales() async {
    final rows = _list('sales');

    rows.sort((a, b) => _date(b['soldAt']).compareTo(_date(a['soldAt'])));

    return rows.map((row) {
      return Sale(
        id: row['id'] as int,
        productId: row['productId'] as int,
        productName: row['productName'] as String,
        quantity: (row['quantity'] as num).toDouble(),
        total: (row['total'] as num).toDouble(),
        soldAt: _date(row['soldAt']),
      );
    }).toList();
  }

  @override
  Future<Sale> addSale({
    required int productId,
    required double quantity,
    required double total,
    DateTime? soldAt,
  }) async {
    final products = _list('products');

    final productIndex = products.indexWhere((row) => row['id'] == productId);

    if (productIndex < 0) {
      throw Exception('Producto no encontrado.');
    }

    final product = products[productIndex];

    final available = (product['quantity'] as num).toDouble();

    // Misma tolerancia utilizada por SQLite.
    if (available + 0.0001 < quantity) {
      throw Exception('No hay suficiente producto disponible.');
    }

    product['quantity'] = available - quantity;

    final sale = Sale(
      id: _nextId('sales'),
      productId: productId,
      productName: product['name'] as String,
      quantity: quantity,
      total: total,
      soldAt: soldAt ?? DateTime.now(),
    );

    final sales = _list('sales');

    sales.add({
      'id': sale.id,
      'productId': sale.productId,
      'productName': sale.productName,
      'quantity': sale.quantity,
      'total': sale.total,
      'soldAt': sale.soldAt.toIso8601String(),
    });

    _data['products'] = products;
    _data['sales'] = sales;

    await _save();

    return sale;
  }

  @override
  Future<void> deleteSale(int id) async {
    final sales = _list('sales');

    final index = sales.indexWhere((row) => row['id'] == id);

    if (index < 0) {
      return;
    }

    final sale = sales[index];

    final products = _list('products');

    final productIndex = products.indexWhere(
      (row) => row['id'] == sale['productId'],
    );

    if (productIndex >= 0) {
      products[productIndex]['quantity'] =
          (products[productIndex]['quantity'] as num).toDouble() +
          (sale['quantity'] as num).toDouble();
    }

    sales.removeAt(index);

    _data['products'] = products;
    _data['sales'] = sales;

    await _save();
  }

  // ============================================================
  // EXPENSES
  // ============================================================

  @override
  Future<List<Expense>> expenses() async {
    final rows = _list('expenses');

    return rows.map((row) {
      return Expense(
        id: row['id'] as int,
        description: row['description'] as String,
        amount: (row['amount'] as num).toDouble(),
        spentAt: _date(row['spentAt']),
        category: row['category'] as String?,
      );
    }).toList();
  }

  @override
  Future<Expense> addExpense({
    required String description,
    required double amount,
    String? category,
    DateTime? spentAt,
  }) async {
    final expense = Expense(
      id: _nextId('expenses'),
      description: description,
      amount: amount,
      spentAt: spentAt ?? DateTime.now(),
      category: category,
    );

    final expenses = _list('expenses');

    expenses.add({
      'id': expense.id,
      'description': expense.description,
      'amount': expense.amount,
      'spentAt': expense.spentAt.toIso8601String(),
      'category': expense.category,
    });

    _data['expenses'] = expenses;

    await _save();

    return expense;
  }

  @override
  Future<void> deleteExpense(int id) async {
    final expenses = _list('expenses');

    expenses.removeWhere((row) => row['id'] == id);

    _data['expenses'] = expenses;

    await _save();
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  @override
  Future<DashboardSnapshot> dashboard() async {
    final sales = _list('sales');
    final expenses = _list('expenses');
    final purchases = _list('purchases');

    final salesTotal = sales.fold<double>(
      0,
      (sum, row) => sum + (row['total'] as num).toDouble(),
    );

    // Igual que SQLite:
    // gastos registrados + compras de ingredientes.
    final expensesTotal =
        expenses.fold<double>(
          0,
          (sum, row) => sum + (row['amount'] as num).toDouble(),
        ) +
        purchases.fold<double>(
          0,
          (sum, row) => sum + (row['totalCost'] as num).toDouble(),
        );

    final allIngredients = await ingredients();
    final allProducts = await products();
    final recentProductions = await productions();

    final lowStock = allIngredients
        .where((ingredient) => ingredient.isLow)
        .toList();

    final finishedProductUnits = allProducts.fold<double>(
      0,
      (sum, product) => sum + product.quantity,
    );

    return DashboardSnapshot(
      salesTotal: salesTotal,
      expensesTotal: expensesTotal,
      ingredientsCount: allIngredients.length,
      finishedProductUnits: finishedProductUnits,
      recentProductions: recentProductions.take(5).toList(),
      lowStock: lowStock,
    );
  }
}

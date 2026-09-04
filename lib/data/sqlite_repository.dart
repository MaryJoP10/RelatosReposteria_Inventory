import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models.dart';
import 'repository.dart';

class RelatosException implements Exception {
  RelatosException(this.message);
  final String message;
  @override
  String toString() => message;
}

class SqliteRelatosRepository implements RelatosRepository {
  SqliteRelatosRepository(this._db);

  final Database _db;

  static Future<SqliteRelatosRepository> open() async {
    final db = await openDatabase(
      p.join(await getDatabasesPath(), 'relatos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            unit TEXT NOT NULL,
            quantity REAL NOT NULL DEFAULT 0,
            minQuantity REAL NOT NULL DEFAULT 0,
            unitCost REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            unit TEXT NOT NULL,
            quantity REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ingredientId INTEGER NOT NULL,
            quantity REAL NOT NULL,
            totalCost REAL NOT NULL,
            purchasedAt TEXT NOT NULL,
            notes TEXT,
            FOREIGN KEY (ingredientId) REFERENCES ingredients(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            yieldQuantity REAL NOT NULL,
            yieldUnit TEXT NOT NULL,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE recipe_lines (
            recipeId INTEGER NOT NULL,
            ingredientId INTEGER NOT NULL,
            quantity REAL NOT NULL,
            FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE,
            FOREIGN KEY (ingredientId) REFERENCES ingredients(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE productions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipeId INTEGER NOT NULL,
            recipeName TEXT NOT NULL,
            units REAL NOT NULL,
            producedAt TEXT NOT NULL,
            FOREIGN KEY (recipeId) REFERENCES recipes(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER NOT NULL,
            productName TEXT NOT NULL,
            quantity REAL NOT NULL,
            total REAL NOT NULL,
            soldAt TEXT NOT NULL,
            FOREIGN KEY (productId) REFERENCES products(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            spentAt TEXT NOT NULL,
            category TEXT
          )
        ''');
      },
    );
    return SqliteRelatosRepository(db);
  }

  @override
  Future<List<Ingredient>> ingredients() async {
    final rows = await _db.query('ingredients', orderBy: 'name COLLATE NOCASE');
    return rows.map(_ingredientFrom).toList();
  }

  @override
  Future<Ingredient> upsertIngredient(Ingredient ingredient) async {
    final values = {
      'name': ingredient.name,
      'unit': ingredient.unit,
      'quantity': ingredient.quantity,
      'minQuantity': ingredient.minQuantity,
      'unitCost': ingredient.unitCost,
    };
    if (ingredient.id == 0) {
      final id = await _db.insert('ingredients', values);
      return ingredient.copyWith(id: id);
    }
    await _db.update(
      'ingredients',
      values,
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
    return ingredient;
  }

  @override
  Future<void> deleteIngredient(int id) async {
    await _db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Product>> products() async {
    final rows = await _db.query('products', orderBy: 'name COLLATE NOCASE');
    return rows.map(_productFrom).toList();
  }

  @override
  Future<Product> upsertProduct(Product product) async {
    final values = {
      'name': product.name,
      'unit': product.unit,
      'quantity': product.quantity,
    };
    if (product.id == 0) {
      final id = await _db.insert('products', values);
      return product.copyWith(id: id);
    }
    await _db.update(
      'products',
      values,
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Purchase>> purchases() async {
    final rows = await _db.query('purchases', orderBy: 'purchasedAt DESC');
    return rows.map((row) => Purchase(
      id: row['id'] as int,
      ingredientId: row['ingredientId'] as int,
      quantity: (row['quantity'] as num).toDouble(),
      totalCost: (row['totalCost'] as num).toDouble(),
      purchasedAt: DateTime.parse(row['purchasedAt'] as String),
      notes: row['notes'] as String?,
    )).toList();
  }

  @override
  Future<Purchase> addPurchase({
    required int ingredientId,
    required double quantity,
    required double totalCost,
    String? notes,
    DateTime? purchasedAt,
  }) async {
    return _db.transaction((txn) async {
      final ingredient = await _ingredientById(txn, ingredientId);
      final at = purchasedAt ?? DateTime.now();
      final id = await txn.insert('purchases', {
        'ingredientId': ingredientId,
        'quantity': quantity,
        'totalCost': totalCost,
        'purchasedAt': at.toIso8601String(),
        'notes': notes,
      });
      final unitCost = quantity == 0 ? ingredient.unitCost : totalCost / quantity;
      await txn.update(
        'ingredients',
        {
          'quantity': ingredient.quantity + quantity,
          'unitCost': unitCost,
        },
        where: 'id = ?',
        whereArgs: [ingredientId],
      );
      return Purchase(
        id: id,
        ingredientId: ingredientId,
        quantity: quantity,
        totalCost: totalCost,
        purchasedAt: at,
        notes: notes,
      );
    });
  }

  @override
  Future<List<Recipe>> recipes() async {
    final rows = await _db.query('recipes', orderBy: 'name COLLATE NOCASE');
    final result = <Recipe>[];
    for (final row in rows) {
      result.add(await _recipeFrom(row));
    }
    return result;
  }

  @override
  Future<Recipe> upsertRecipe(Recipe recipe) async {
    return _db.transaction((txn) async {
      final values = {
        'name': recipe.name,
        'yieldQuantity': recipe.yieldQuantity,
        'yieldUnit': recipe.yieldUnit,
        'notes': recipe.notes,
      };
      late final int id;
      if (recipe.id == 0) {
        id = await txn.insert('recipes', values);
      } else {
        id = recipe.id;
        await txn.update('recipes', values, where: 'id = ?', whereArgs: [id]);
        await txn.delete('recipe_lines', where: 'recipeId = ?', whereArgs: [id]);
      }
      for (final line in recipe.lines) {
        await txn.insert('recipe_lines', {
          'recipeId': id,
          'ingredientId': line.ingredientId,
          'quantity': line.quantity,
        });
      }
      return Recipe(
        id: id,
        name: recipe.name,
        yieldQuantity: recipe.yieldQuantity,
        yieldUnit: recipe.yieldUnit,
        notes: recipe.notes,
        lines: recipe.lines,
      );
    });
  }

  @override
  Future<void> deleteRecipe(int id) async {
    await _db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Production>> productions() async {
    final rows = await _db.query('productions', orderBy: 'producedAt DESC');
    return rows.map((row) => Production(
      id: row['id'] as int,
      recipeId: row['recipeId'] as int,
      recipeName: row['recipeName'] as String,
      units: (row['units'] as num).toDouble(),
      producedAt: DateTime.parse(row['producedAt'] as String),
    )).toList();
  }

  @override
  Future<Production> addProduction({
    required int recipeId,
    required double batches,
    DateTime? producedAt,
  }) async {
    return _db.transaction((txn) async {
      final recipeRow = await txn.query('recipes', where: 'id = ?', whereArgs: [recipeId]);
      if (recipeRow.isEmpty) {
        throw RelatosException('Receta no encontrada.');
      }
      final recipe = await _recipeFrom(recipeRow.first, txn: txn);
      for (final line in recipe.lines) {
        final ingredient = await _ingredientById(txn, line.ingredientId);
        final needed = line.quantity * batches;
        if (ingredient.quantity + 0.0001 < needed) {
          throw RelatosException('No hay suficiente ${ingredient.name} para producir.');
        }
        await txn.update(
          'ingredients',
          {'quantity': ingredient.quantity - needed},
          where: 'id = ?',
          whereArgs: [ingredient.id],
        );
      }

      final units = recipe.yieldQuantity * batches;
      final existing = await txn.query('products', where: 'LOWER(name) = LOWER(?)', whereArgs: [recipe.name]);
      if (existing.isEmpty) {
        await txn.insert('products', {
          'name': recipe.name,
          'unit': recipe.yieldUnit,
          'quantity': units,
        });
      } else {
        final product = _productFrom(existing.first);
        await txn.update(
          'products',
          {'quantity': product.quantity + units},
          where: 'id = ?',
          whereArgs: [product.id],
        );
      }

      final at = producedAt ?? DateTime.now();
      final id = await txn.insert('productions', {
        'recipeId': recipeId,
        'recipeName': recipe.name,
        'units': units,
        'producedAt': at.toIso8601String(),
      });
      return Production(
        id: id,
        recipeId: recipeId,
        recipeName: recipe.name,
        units: units,
        producedAt: at,
      );
    });
  }

  @override
  Future<List<Sale>> sales() async {
    final rows = await _db.query('sales', orderBy: 'soldAt DESC');
    return rows.map((row) => Sale(
      id: row['id'] as int,
      productId: row['productId'] as int,
      productName: row['productName'] as String,
      quantity: (row['quantity'] as num).toDouble(),
      total: (row['total'] as num).toDouble(),
      soldAt: DateTime.parse(row['soldAt'] as String),
    )).toList();
  }

  @override
  Future<Sale> addSale({
    required int productId,
    required double quantity,
    required double total,
    DateTime? soldAt,
  }) async {
    return _db.transaction((txn) async {
      final product = await _productById(txn, productId);
      if (product.quantity + 0.0001 < quantity) {
        throw RelatosException('No hay suficiente ${product.name} para vender.');
      }
      await txn.update(
        'products',
        {'quantity': product.quantity - quantity},
        where: 'id = ?',
        whereArgs: [productId],
      );
      final at = soldAt ?? DateTime.now();
      final id = await txn.insert('sales', {
        'productId': productId,
        'productName': product.name,
        'quantity': quantity,
        'total': total,
        'soldAt': at.toIso8601String(),
      });
      return Sale(
        id: id,
        productId: productId,
        productName: product.name,
        quantity: quantity,
        total: total,
        soldAt: at,
      );
    });
  }

  @override
  Future<List<Expense>> expenses() async {
    final rows = await _db.query('expenses', orderBy: 'spentAt DESC');
    return rows.map((row) => Expense(
      id: row['id'] as int,
      description: row['description'] as String,
      amount: (row['amount'] as num).toDouble(),
      spentAt: DateTime.parse(row['spentAt'] as String),
      category: row['category'] as String?,
    )).toList();
  }

  @override
  Future<Expense> addExpense({
    required String description,
    required double amount,
    String? category,
    DateTime? spentAt,
  }) async {
    final at = spentAt ?? DateTime.now();
    final id = await _db.insert('expenses', {
      'description': description,
      'amount': amount,
      'spentAt': at.toIso8601String(),
      'category': category,
    });
    return Expense(
      id: id,
      description: description,
      amount: amount,
      spentAt: at,
      category: category,
    );
  }

  @override
  Future<void> addAdjustment({
    required String target,
    required int itemId,
    required double delta,
    String? reason,
  }) async {
    await _db.transaction((txn) async {
      if (target == 'ingredient') {
        final item = await _ingredientById(txn, itemId);
        await txn.update(
          'ingredients',
          {'quantity': item.quantity + delta},
          where: 'id = ?',
          whereArgs: [itemId],
        );
      } else {
        final item = await _productById(txn, itemId);
        await txn.update(
          'products',
          {'quantity': item.quantity + delta},
          where: 'id = ?',
          whereArgs: [itemId],
        );
      }
    });
  }

  @override
  Future<DashboardSnapshot> dashboard() async {
    final salesTotalRows = await _db.rawQuery('SELECT SUM(total) as value FROM sales');
    final expensesTotalRows = await _db.rawQuery('SELECT SUM(amount) as value FROM expenses');
    final purchasesTotalRows = await _db.rawQuery('SELECT SUM(totalCost) as value FROM purchases');
    final productUnitsRows = await _db.rawQuery('SELECT SUM(quantity) as value FROM products');
    final ingredientsCountRows = await _db.rawQuery('SELECT COUNT(*) as value FROM ingredients');

    final salesTotal = (salesTotalRows.first['value'] as num?)?.toDouble() ?? 0.0;
    final expensesTotal = ((expensesTotalRows.first['value'] as num?)?.toDouble() ?? 0.0) +
        ((purchasesTotalRows.first['value'] as num?)?.toDouble() ?? 0.0);
    final ingredientsCount = (ingredientsCountRows.first['value'] as int?) ?? 0;
    final finishedProductUnits = (productUnitsRows.first['value'] as num?)?.toDouble() ?? 0.0;

    final recentProductions = await productions();
    final allIngredients = await ingredients();
    final lowStock = allIngredients.where((i) => i.isLow).toList();

    return DashboardSnapshot(
      salesTotal: salesTotal,
      expensesTotal: expensesTotal,
      ingredientsCount: ingredientsCount,
      finishedProductUnits: finishedProductUnits,
      recentProductions: recentProductions.take(5).toList(),
      lowStock: lowStock,
    );
  }

  Ingredient _ingredientFrom(Map<String, Object?> row) {
    return Ingredient(
      id: row['id'] as int,
      name: row['name'] as String,
      unit: row['unit'] as String,
      quantity: (row['quantity'] as num).toDouble(),
      minQuantity: (row['minQuantity'] as num).toDouble(),
      unitCost: (row['unitCost'] as num).toDouble(),
    );
  }

  Product _productFrom(Map<String, Object?> row) {
    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      unit: row['unit'] as String,
      quantity: (row['quantity'] as num).toDouble(),
    );
  }

  Future<Recipe> _recipeFrom(Map<String, Object?> row, {DatabaseExecutor? txn}) async {
    final executor = txn ?? _db;
    final id = row['id'] as int;
    final lines = await executor.query('recipe_lines', where: 'recipeId = ?', whereArgs: [id]);
    return Recipe(
      id: id,
      name: row['name'] as String,
      yieldQuantity: (row['yieldQuantity'] as num).toDouble(),
      yieldUnit: row['yieldUnit'] as String,
      notes: row['notes'] as String?,
      lines: lines.map((line) => RecipeLine(
        ingredientId: line['ingredientId'] as int,
        quantity: (line['quantity'] as num).toDouble(),
      )).toList(),
    );
  }

  Future<Ingredient> _ingredientById(DatabaseExecutor txn, int id) async {
    final rows = await txn.query('ingredients', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) throw RelatosException('Ingrediente no encontrado.');
    return _ingredientFrom(rows.first);
  }

  Future<Product> _productById(DatabaseExecutor txn, int id) async {
    final rows = await txn.query('products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) throw RelatosException('Producto no encontrado.');
    return _productFrom(rows.first);
  }
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minQuantity,
    required this.unitCost,
  });

  final int id;
  final String name;
  final String unit;
  final double quantity;
  final double minQuantity;
  final double unitCost;

  bool get isLow => quantity <= minQuantity;

  Ingredient copyWith({
    int? id,
    String? name,
    String? unit,
    double? quantity,
    double? minQuantity,
    double? unitCost,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
  });

  final int id;
  final String name;
  final String unit;
  final double quantity;

  Product copyWith({int? id, String? name, String? unit, double? quantity}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Purchase {
  const Purchase({
    required this.id,
    required this.ingredientId,
    required this.quantity,
    required this.totalCost,
    required this.purchasedAt,
    this.notes,
  });

  final int id;
  final int ingredientId;
  final double quantity;
  final double totalCost;
  final DateTime purchasedAt;
  final String? notes;
}

class RecipeLine {
  const RecipeLine({
    required this.ingredientId,
    required this.quantity,
  });

  final int ingredientId;
  final double quantity;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.yieldQuantity,
    required this.yieldUnit,
    required this.lines,
    this.notes,
  });

  final int id;
  final String name;
  final double yieldQuantity;
  final String yieldUnit;
  final List<RecipeLine> lines;
  final String? notes;
}

class Production {
  const Production({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.units,
    required this.producedAt,
  });

  final int id;
  final int recipeId;
  final String recipeName;
  final double units;
  final DateTime producedAt;
}

class Sale {
  const Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.total,
    required this.soldAt,
  });

  final int id;
  final int productId;
  final String productName;
  final double quantity;
  final double total;
  final DateTime soldAt;
}

class Expense {
  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.spentAt,
    this.category,
  });

  final int id;
  final String description;
  final double amount;
  final DateTime spentAt;
  final String? category;
}

class StockAdjustment {
  const StockAdjustment({
    required this.id,
    required this.target,
    required this.itemId,
    required this.delta,
    required this.adjustedAt,
    this.reason,
  });

  final int id;
  final String target;
  final int itemId;
  final double delta;
  final DateTime adjustedAt;
  final String? reason;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.salesTotal,
    required this.expensesTotal,
    required this.ingredientsCount,
    required this.finishedProductUnits,
    required this.recentProductions,
    required this.lowStock,
  });

  final double salesTotal;
  final double expensesTotal;
  final int ingredientsCount;
  final double finishedProductUnits;
  final List<Production> recentProductions;
  final List<Ingredient> lowStock;

  double get profit => salesTotal - expensesTotal;
}

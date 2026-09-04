import 'models.dart';

abstract class RelatosRepository {
  Future<List<Ingredient>> ingredients();
  Future<Ingredient> upsertIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(int id);

  Future<List<Product>> products();
  Future<Product> upsertProduct(Product product);
  Future<void> deleteProduct(int id);

  Future<List<Purchase>> purchases();
  Future<Purchase> addPurchase({
    required int ingredientId,
    required double quantity,
    required double totalCost,
    String? notes,
    DateTime? purchasedAt,
  });

  Future<List<Recipe>> recipes();
  Future<Recipe> upsertRecipe(Recipe recipe);
  Future<void> deleteRecipe(int id);

  Future<List<Production>> productions();
  Future<Production> addProduction({
    required int recipeId,
    required double batches,
    DateTime? producedAt,
  });

  Future<List<Sale>> sales();
  Future<Sale> addSale({
    required int productId,
    required double quantity,
    required double total,
    DateTime? soldAt,
  });

  Future<List<Expense>> expenses();
  Future<Expense> addExpense({
    required String description,
    required double amount,
    String? category,
    DateTime? spentAt,
  });

  Future<void> addAdjustment({
    required String target,
    required int itemId,
    required double delta,
    String? reason,
  });

  Future<DashboardSnapshot> dashboard();
}

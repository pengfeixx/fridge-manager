import 'package:fridge_manager/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Stream<List<Recipe>> watchAll();
  Future<Recipe?> getById(int id);
  Future<int> add(Recipe recipe);
  Future<void> seedIfEmpty();
}

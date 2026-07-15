import 'package:fridge_manager/data/database/daos/recipe_dao.dart';
import 'package:fridge_manager/data/database/seed/recipe_seed.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';
import 'package:fridge_manager/domain/repositories/recipe_repository.dart';

class LocalRecipeRepository implements RecipeRepository {
  final RecipeDao _dao;
  const LocalRecipeRepository(this._dao);

  @override
  Stream<List<Recipe>> watchAll() => _dao.watchAll();

  @override
  Future<Recipe?> getById(int id) => _dao.getById(id);

  @override
  Future<int> add(Recipe recipe) => _dao.insertRecipe(recipe);

  @override
  Future<void> seedIfEmpty() => _dao.seedIfEmpty(kRecipeSeed);
}

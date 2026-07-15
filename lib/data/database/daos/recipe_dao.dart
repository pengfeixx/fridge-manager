import 'package:drift/drift.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/tables.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

part 'recipe_dao.g.dart';

@DriftAccessor(tables: [RecipesTable, RecipeIngredientsTable])
class RecipeDao extends DatabaseAccessor<AppDatabase> with _$RecipeDaoMixin {
  RecipeDao(super.db);

  Future<List<Recipe>> all() async {
    final recipes = await select(recipesTable).get();
    return Future.wait(recipes.map(_loadIngredients));
  }

  Stream<List<Recipe>> watchAll() async* {
    await for (final _ in select(recipesTable).watch()) {
      yield await all();
    }
  }

  Future<Recipe?> getById(int id) async {
    final row = await (select(recipesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _loadIngredients(row);
  }

  Future<int> insertRecipe(Recipe r) async {
    final id = await into(recipesTable).insert(
      RecipesTableCompanion.insert(
        title: r.title,
        steps: r.steps.join('\n'),
        tags: Value(r.tags.join(',')),
        source: Value(r.source.name),
      ),
    );
    for (final ing in r.ingredients) {
      await into(recipeIngredientsTable).insert(
        RecipeIngredientsTableCompanion.insert(
          recipeId: id,
          foodName: ing.foodName,
          amount: ing.amount,
          unit: ing.unit,
          categoryId: Value(ing.categoryId),
        ),
      );
    }
    return id;
  }

  /// 首次启动播种；若已有菜谱则跳过。
  Future<void> seedIfEmpty(List<Recipe> seeds) async {
    final existing = await select(recipesTable).get();
    if (existing.isNotEmpty) return;
    for (final r in seeds) {
      await insertRecipe(r);
    }
  }

  Future<Recipe> _loadIngredients(RecipesTableData row) async {
    final ings = await (select(recipeIngredientsTable)
          ..where((t) => t.recipeId.equals(row.id)))
        .map((r) => RecipeIngredient(
              id: r.id,
              foodName: r.foodName,
              amount: r.amount,
              unit: r.unit,
              categoryId: r.categoryId,
            ))
        .get();
    return Recipe(
      id: row.id,
      title: row.title,
      ingredients: ings,
      steps: row.steps.split('\n'),
      tags: row.tags.isEmpty ? [] : row.tags.split(','),
      source: row.source == 'ai' ? RecipeSource.ai : RecipeSource.local,
    );
  }
}

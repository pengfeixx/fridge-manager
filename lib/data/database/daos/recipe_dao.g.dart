// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_dao.dart';

// ignore_for_file: type=lint
mixin _$RecipeDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecipesTableTable get recipesTable => attachedDatabase.recipesTable;
  $RecipeIngredientsTableTable get recipeIngredientsTable =>
      attachedDatabase.recipeIngredientsTable;
  RecipeDaoManager get managers => RecipeDaoManager(this);
}

class RecipeDaoManager {
  final _$RecipeDaoMixin _db;
  RecipeDaoManager(this._db);
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db.attachedDatabase, _db.recipesTable);
  $$RecipeIngredientsTableTableTableManager get recipeIngredientsTable =>
      $$RecipeIngredientsTableTableTableManager(
          _db.attachedDatabase, _db.recipeIngredientsTable);
}

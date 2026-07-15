import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/daos/family_member_dao.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/database/daos/recipe_dao.dart';
import 'package:fridge_manager/data/repositories/local_family_repository.dart';
import 'package:fridge_manager/data/repositories/local_food_repository.dart';
import 'package:fridge_manager/data/repositories/local_recipe_repository.dart';
import 'package:fridge_manager/domain/repositories/family_repository.dart';
import 'package:fridge_manager/domain/repositories/food_repository.dart';
import 'package:fridge_manager/domain/repositories/recipe_repository.dart';

/// 数据库单例（生产用文件库）。测试时可 override 为 .memory()。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.file();
  ref.onDispose(db.close);
  return db;
});

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return LocalFoodRepository(FoodItemDao(ref.watch(appDatabaseProvider)));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return LocalRecipeRepository(RecipeDao(ref.watch(appDatabaseProvider)));
});

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return LocalFamilyRepository(FamilyMemberDao(ref.watch(appDatabaseProvider)));
});

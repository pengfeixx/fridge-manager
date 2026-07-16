import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/data/database/daos/family_member_dao.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/database/daos/recipe_dao.dart';
import 'package:fridge_manager/data/services/local_backup_service.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

final backupServiceProvider = Provider<LocalBackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalBackupService(
    FoodItemDao(db),
    RecipeDao(db),
    FamilyMemberDao(db),
    MealLogDao(db),
  );
});

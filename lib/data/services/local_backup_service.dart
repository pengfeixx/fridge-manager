import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path_provider/path_provider.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/daos/family_member_dao.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/database/daos/recipe_dao.dart';
import 'package:fridge_manager/domain/services/backup_service.dart';

class LocalBackupService implements BackupService {
  final FoodItemDao _foodDao;
  final RecipeDao _recipeDao;
  final FamilyMemberDao _familyDao;
  final MealLogDao _mealLogDao;

  LocalBackupService(
      this._foodDao, this._recipeDao, this._familyDao, this._mealLogDao);

  @override
  Future<BackupData> exportAll() async {
    final foods = await _foodDao.all();
    final recipes = await _recipeDao.all();
    final members = await _familyDao.watchAll().first;
    final now = DateTime.now();
    final logs = await _mealLogDao.getByDateRange(
      now.subtract(const Duration(days: 3650)),
      now,
    );

    return BackupData(
      version: 1,
      exportDate: now,
      foodItems: foods,
      recipes: recipes,
      familyMembers: members,
      mealLogs: logs,
    );
  }

  @override
  Future<void> importAll(BackupData data) async {
    for (final m in data.familyMembers) {
      await _familyDao.add(m);
    }
    for (final r in data.recipes) {
      await _recipeDao.insertRecipe(r);
    }
    for (final f in data.foodItems) {
      await _foodDao.add(FoodItemsCompanion.insert(
        name: f.name,
        categoryId: f.categoryId,
        quantity: f.quantity,
        unit: f.unit,
        storage: f.storage,
        addedDate: f.addedDate,
        shelfLifeDays: f.shelfLifeDays,
        status: Value(f.status.name),
      ));
    }
    for (final l in data.mealLogs) {
      await _mealLogDao.addMealLog(l);
    }
  }

  /// 导出为 JSON 文件到临时目录，返回文件路径。
  Future<String> exportToFile() async {
    final data = await exportAll();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/fridge_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonEncode(data.toJson()));
    return file.path;
  }
}

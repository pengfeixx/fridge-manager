import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:fridge_manager/data/database/tables.dart';
import 'package:fridge_manager/domain/entities/enums.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [FoodItems, FoodCategories, ShelfLifeRules, RecipesTable, RecipeIngredientsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 生产用：应用文档目录下 fridge.db
  factory AppDatabase.file() {
    return AppDatabase(LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
        File(p.join(dir.path, 'fridge.db')),
      );
    }));
  }

  /// 测试用：纯内存
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

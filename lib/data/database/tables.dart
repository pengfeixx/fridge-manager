import 'package:drift/drift.dart';
import 'package:fridge_manager/domain/entities/enums.dart';

/// 在 [FoodItems.storage] 列上做 `Storage` <-> `String` 映射。
///
/// 使生成的 [FoodItemsCompanion] / [FoodItemData] 直接以 [Storage] 枚举类型
/// 暴露该字段，避免在 DAO/调用方反复手写 `.name` / `Storage.parse`。
class StorageConverter extends TypeConverter<Storage, String> {
  const StorageConverter();

  @override
  Storage fromSql(String fromDb) => Storage.parse(fromDb);

  @override
  String toSql(Storage value) => value.name;
}

@DataClassName('FoodItemData')
class FoodItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get categoryId => integer()();
  RealColumn get quantity => real()();
  TextColumn get unit => text().withLength(max: 10)();
  TextColumn get storage => text().map(const StorageConverter())(); // Storage.name
  DateTimeColumn get addedDate => dateTime()();
  IntColumn get shelfLifeDays => integer()();
  TextColumn get status =>
      text().withDefault(const Constant('inStock'))(); // FoodStatus.name
  TextColumn get note => text().nullable()();
}

class FoodCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get chilledDefaultDays => integer()();
  IntColumn get frozenDefaultDays => integer()();
  IntColumn get roomDefaultDays => integer()();
}

class ShelfLifeRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get foodName => text()();
  TextColumn get aliases => text().withDefault(const Constant(''))(); // 逗号分隔
  TextColumn get storage => text()();
  IntColumn get defaultDays => integer()();
}

@DataClassName('RecipesTableData')
class RecipesTable extends Table {
  @override
  String get tableName => 'recipes';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get steps => text()(); // 步骤用 \n 分隔
  TextColumn get tags =>
      text().withDefault(const Constant(''))(); // 逗号分隔
  TextColumn get source => text().withDefault(const Constant('local'))();
}

@DataClassName('RecipeIngredientsTableData')
class RecipeIngredientsTable extends Table {
  @override
  String get tableName => 'recipe_ingredients';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId => integer()();
  TextColumn get foodName => text()();
  RealColumn get amount => real()();
  TextColumn get unit => text()();
  IntColumn get categoryId => integer().nullable()();
}

@DataClassName('FamilyMemberData')
class FamilyMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get gender => text().withDefault(const Constant('other'))();
  TextColumn get dietaryTags => text().withDefault(const Constant(''))();
  TextColumn get allergies => text().withDefault(const Constant(''))();
}

@DataClassName('MealLogData')
class MealLogsTable extends Table {
  @override
  String get tableName => 'meal_logs';
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()(); // breakfast/lunch/dinner/snack
}

@DataClassName('MealEntryData')
class MealEntriesTable extends Table {
  @override
  String get tableName => 'meal_entries';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealLogId => integer()();
  TextColumn get category => text()(); // NutritionCategory.name
  RealColumn get amountGram => real()();
  TextColumn get description => text().nullable()();
}

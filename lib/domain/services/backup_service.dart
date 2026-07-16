import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

/// 全量备份数据。不含 AI API Key。
class BackupData {
  final int version;
  final DateTime exportDate;
  final List<FoodItem> foodItems;
  final List<Recipe> recipes;
  final List<FamilyMember> familyMembers;
  final List<MealLog> mealLogs;

  const BackupData({
    required this.version,
    required this.exportDate,
    required this.foodItems,
    required this.recipes,
    required this.familyMembers,
    required this.mealLogs,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportDate': exportDate.toIso8601String(),
        'foodItems': foodItems.map(_foodToJson).toList(),
        'recipes': recipes.map(_recipeToJson).toList(),
        'familyMembers': familyMembers.map(_memberToJson).toList(),
        'mealLogs': mealLogs.map(_mealLogToJson).toList(),
      };

  factory BackupData.fromJson(Map<String, dynamic> json) => BackupData(
        version: (json['version'] as num?)?.toInt() ?? 1,
        exportDate:
            DateTime.tryParse(json['exportDate'] as String? ?? '') ??
                DateTime.now(),
        foodItems: (json['foodItems'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(_foodFromJson)
            .toList(),
        recipes: (json['recipes'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(_recipeFromJson)
            .toList(),
        familyMembers: (json['familyMembers'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(_memberFromJson)
            .toList(),
        mealLogs: (json['mealLogs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(_mealLogFromJson)
            .toList(),
      );

  static Map<String, dynamic> _foodToJson(FoodItem f) => {
        'name': f.name,
        'categoryId': f.categoryId,
        'quantity': f.quantity,
        'unit': f.unit,
        'storage': f.storage.name,
        'addedDate': f.addedDate.toIso8601String(),
        'shelfLifeDays': f.shelfLifeDays,
        'status': f.status.name,
        'note': f.note,
      };
  static FoodItem _foodFromJson(Map<String, dynamic> m) => FoodItem(
        name: m['name'] as String? ?? '',
        categoryId: m['categoryId'] as int? ?? 0,
        quantity: (m['quantity'] as num?)?.toDouble() ?? 1,
        unit: m['unit'] as String? ?? '份',
        storage: Storage.parse(m['storage'] as String? ?? 'chilled'),
        addedDate:
            DateTime.tryParse(m['addedDate'] as String? ?? '') ?? DateTime.now(),
        shelfLifeDays: m['shelfLifeDays'] as int? ?? 7,
        status: FoodStatus.values.firstWhere(
          (s) => s.name == (m['status'] as String? ?? 'inStock'),
          orElse: () => FoodStatus.inStock,
        ),
        note: m['note'] as String?,
      );

  static Map<String, dynamic> _recipeToJson(Recipe r) => {
        'title': r.title,
        'ingredients': r.ingredients
            .map((i) => {
                  'name': i.foodName,
                  'amount': i.amount,
                  'unit': i.unit,
                })
            .toList(),
        'steps': r.steps,
        'tags': r.tags,
        'source': r.source.name,
      };
  static Recipe _recipeFromJson(Map<String, dynamic> m) => Recipe(
        title: m['title'] as String? ?? '',
        ingredients: (m['ingredients'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map((i) => RecipeIngredient(
                  foodName: i['name'] as String? ?? '',
                  amount: (i['amount'] as num?)?.toDouble() ?? 1,
                  unit: i['unit'] as String? ?? 'g',
                ))
            .toList(),
        steps: (m['steps'] as List? ?? []).cast<String>(),
        tags: (m['tags'] as List? ?? []).cast<String>(),
        source: m['source'] == 'ai' ? RecipeSource.ai : RecipeSource.local,
      );

  static Map<String, dynamic> _memberToJson(FamilyMember m) => {
        'name': m.name,
        'age': m.age,
        'gender': m.gender.name,
        'dietaryTags': m.dietaryTags,
        'allergies': m.allergies,
      };
  static FamilyMember _memberFromJson(Map<String, dynamic> m) => FamilyMember(
        name: m['name'] as String? ?? '',
        age: m['age'] as int? ?? 0,
        gender: Gender.values.firstWhere(
          (g) => g.name == (m['gender'] as String? ?? 'other'),
          orElse: () => Gender.other,
        ),
        dietaryTags: (m['dietaryTags'] as List? ?? []).cast<String>(),
        allergies: (m['allergies'] as List? ?? []).cast<String>(),
      );

  static Map<String, dynamic> _mealLogToJson(MealLog l) => {
        'date': l.date.toIso8601String(),
        'mealType': l.mealType.name,
        'entries': l.entries
            .map((e) => {
                  'category': e.category.name,
                  'amountGram': e.amountGram,
                })
            .toList(),
      };
  static MealLog _mealLogFromJson(Map<String, dynamic> m) => MealLog(
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        mealType: MealType.values.firstWhere(
          (t) => t.name == (m['mealType'] as String? ?? 'dinner'),
          orElse: () => MealType.dinner,
        ),
        entries: (m['entries'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map((e) => MealEntry(
                  category: NutritionCategory.values.firstWhere(
                    (c) =>
                        c.name == (e['category'] as String? ?? 'vegetables'),
                    orElse: () => NutritionCategory.vegetables,
                  ),
                  amountGram: (e['amountGram'] as num?)?.toDouble() ?? 0,
                ))
            .toList(),
      );
}

/// 备份服务抽象接口。
abstract class BackupService {
  Future<BackupData> exportAll();
  Future<void> importAll(BackupData data);
}

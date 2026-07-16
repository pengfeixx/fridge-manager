import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';
import 'package:fridge_manager/domain/services/backup_service.dart';

void main() {
  group('BackupData', () {
    test('toJson / fromJson 往返一致', () {
      final data = BackupData(
        version: 1,
        exportDate: DateTime(2026, 7, 16),
        foodItems: [
          FoodItem(
              name: '白菜',
              categoryId: 0,
              quantity: 2,
              unit: '颗',
              storage: Storage.chilled,
              addedDate: DateTime(2026, 7, 15),
              shelfLifeDays: 7),
        ],
        recipes: [
          const Recipe(
            title: '测试菜',
            ingredients: [
              RecipeIngredient(foodName: '白菜', amount: 1, unit: '颗'),
            ],
            steps: ['步骤1'],
          ),
        ],
        familyMembers: [
          const FamilyMember(name: '爸', age: 40, gender: Gender.male),
        ],
        mealLogs: [
          MealLog(
            date: DateTime(2026, 7, 16),
            mealType: MealType.lunch,
            entries: [
              const MealEntry(
                  category: NutritionCategory.vegetables, amountGram: 200),
            ],
          ),
        ],
      );
      final json = data.toJson();
      final restored = BackupData.fromJson(json);
      expect(restored.version, 1);
      expect(restored.foodItems, hasLength(1));
      expect(restored.foodItems[0].name, '白菜');
      expect(restored.recipes[0].title, '测试菜');
      expect(restored.familyMembers[0].name, '爸');
      expect(restored.mealLogs[0].entries[0].category,
          NutritionCategory.vegetables);
    });

    test('fromJson 容错：缺字段返回空列表', () {
      final restored = BackupData.fromJson({});
      expect(restored.foodItems, isEmpty);
      expect(restored.recipes, isEmpty);
      expect(restored.familyMembers, isEmpty);
      expect(restored.mealLogs, isEmpty);
    });

    test('toJson 不含 apiKey（安全）', () {
      final data = BackupData(
        version: 1,
        exportDate: DateTime.now(),
        foodItems: [],
        recipes: [],
        familyMembers: [],
        mealLogs: [],
      );
      final json = data.toJson();
      expect(json.containsKey('apiKey'), isFalse);
      expect(json.containsKey('aiConfig'), isFalse);
    });
  });
}

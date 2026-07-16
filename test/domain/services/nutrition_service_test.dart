import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/services/nutrition_service.dart';

void main() {
  final members = [
    const FamilyMember(name: '爸', age: 40, gender: Gender.male),
    const FamilyMember(name: '妈', age: 38, gender: Gender.female),
    const FamilyMember(name: '娃', age: 8, gender: Gender.male),
  ];

  group('dailyRecommendPerCategory', () {
    test('各成员推荐量之和', () {
      final result = NutritionService.dailyRecommendPerCategory(
        members, kNutritionGuideSeed);
      // 爸(40,男)+妈(38,女)+娃(8,男)
      // 谷薯: 300 + 250 + 250 = 800
      expect(result[NutritionCategory.grains], 800);
      // 蔬菜: 500 + 400 + 400 = 1300
      expect(result[NutritionCategory.vegetables], 1300);
    });

    test('无成员返回全 0', () {
      final result = NutritionService.dailyRecommendPerCategory(
        [], kNutritionGuideSeed);
      for (final v in result.values) {
        expect(v, 0);
      }
    });
  });

  group('weeklyGap', () {
    test('缺口 = 推荐量×7 − 实际摄入 − 库存', () {
      final daily = <NutritionCategory, int>{
        NutritionCategory.vegetables: 1000, // 每天需 1000g
      };
      final weekLogs = [
        MealLog(date: DateTime(2026, 7, 14), mealType: MealType.lunch, entries: [
          const MealEntry(category: NutritionCategory.vegetables, amountGram: 300),
        ]),
        MealLog(date: DateTime(2026, 7, 15), mealType: MealType.dinner, entries: [
          const MealEntry(category: NutritionCategory.vegetables, amountGram: 200),
        ]),
      ];
      // 本周已吃 500g 蔬菜, 库存有 300g
      // 需求 = 1000*7 = 7000, 缺口 = 7000 - 500 - 300 = 6200
      final gap = NutritionService.weeklyGap(
        daily, weekLogs, {NutritionCategory.vegetables: 300});
      expect(gap[NutritionCategory.vegetables], 6200);
    });

    test('盈余时缺口为 0（下限 0）', () {
      final daily = <NutritionCategory, int>{
        NutritionCategory.vegetables: 100,
      };
      final weekLogs = [
        MealLog(date: DateTime(2026, 7, 14), mealType: MealType.lunch, entries: [
          const MealEntry(category: NutritionCategory.vegetables, amountGram: 2000),
        ]),
      ];
      // 需求 700, 已吃 2000, 库存 0 → 盈余, 缺口 0
      final gap = NutritionService.weeklyGap(daily, weekLogs, {});
      expect(gap[NutritionCategory.vegetables], 0);
    });
  });

  group('shoppingList', () {
    test('缺口>0 的类别生成购物项', () {
      final gaps = <NutritionCategory, double>{
        NutritionCategory.vegetables: 6200,
        NutritionCategory.fruits: 0,
        NutritionCategory.protein: 800,
      };
      final list = NutritionService.shoppingList(gaps);
      expect(list, hasLength(2));
      expect(list.any((s) => s.category == NutritionCategory.vegetables), isTrue);
      expect(list.any((s) => s.category == NutritionCategory.protein), isTrue);
      final veg = list.firstWhere((s) => s.category == NutritionCategory.vegetables);
      expect(veg.grams, 6200);
      expect(veg.kgDisplay, '6.2 kg');
    });
  });
}

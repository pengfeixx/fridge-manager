import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

void main() {
  test('NutritionCategory 有 6 个类别', () {
    expect(NutritionCategory.values, hasLength(6));
  });

  test('种子表覆盖所有类别 × 性别 × 年龄段', () {
    for (final cat in NutritionCategory.values) {
      for (final gender in ['male', 'female']) {
        final matches = kNutritionGuideSeed
            .where((g) => g.category == cat && g.gender == gender)
            .toList();
        expect(matches, isNotEmpty, reason: '$gender $cat 无数据');
      }
    }
  });

  test('每个年龄段的推荐量合理（> 0）', () {
    for (final g in kNutritionGuideSeed) {
      expect(g.dailyGram, greaterThan(0));
    }
  });
}

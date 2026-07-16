import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

/// 购物建议项。
class ShoppingItem {
  final NutritionCategory category;
  final double grams;
  const ShoppingItem(this.category, this.grams);

  String get kgDisplay =>
      grams >= 1000 ? '${(grams / 1000).toStringAsFixed(1)} kg' : '${grams.round()} g';
}

/// 营养计算引擎——纯函数，无副作用。
class NutritionService {
  NutritionService._();

  /// 找到某成员在某类别的每日推荐量。
  static int _lookupDaily(
      FamilyMember member, NutritionCategory cat, List<NutritionGuide> guides) {
    final g = member.gender;
    final genderStr = g == Gender.male ? 'male' : g == Gender.female ? 'female' : 'female';
    final match = guides
        .where((guide) =>
            guide.category == cat &&
            guide.gender == genderStr &&
            member.age >= guide.ageMin &&
            member.age <= guide.ageMax)
        .toList();
    if (match.isEmpty) return 0;
    // 多条匹配取平均。
    return (match.map((m) => m.dailyGram).reduce((a, b) => a + b) / match.length).round();
  }

  /// 计算家庭每日各类别推荐量之和。
  static Map<NutritionCategory, int> dailyRecommendPerCategory(
      List<FamilyMember> members, List<NutritionGuide> guides) {
    final result = <NutritionCategory, int>{};
    for (final cat in NutritionCategory.values) {
      result[cat] = members
          .map((m) => _lookupDaily(m, cat, guides))
          .fold(0, (a, b) => a + b);
    }
    return result;
  }

  /// 计算本周各类别缺口。
  /// gap = dailyRecommend × 7 − weekActual − stockAvailable（下限 0）。
  static Map<NutritionCategory, double> weeklyGap(
    Map<NutritionCategory, int> dailyRecommend,
    List<MealLog> weekLogs,
    Map<NutritionCategory, double> stockAvailable,
  ) {
    final result = <NutritionCategory, double>{};
    // 汇总本周实际摄入。
    final actual = <NutritionCategory, double>{};
    for (final log in weekLogs) {
      for (final entry in log.entries) {
        actual[entry.category] = (actual[entry.category] ?? 0) + entry.amountGram;
      }
    }
    for (final cat in NutritionCategory.values) {
      final need = (dailyRecommend[cat] ?? 0) * 7.0;
      final eaten = actual[cat] ?? 0;
      final stock = stockAvailable[cat] ?? 0;
      final gap = need - eaten - stock;
      result[cat] = gap < 0 ? 0 : gap;
    }
    return result;
  }

  /// 从缺口生成购物清单（只含缺口>0的类别）。
  static List<ShoppingItem> shoppingList(Map<NutritionCategory, double> gaps) {
    return gaps.entries
        .where((e) => e.value > 0)
        .map((e) => ShoppingItem(e.key, e.value))
        .toList()
      ..sort((a, b) => b.grams.compareTo(a.grams));
  }
}

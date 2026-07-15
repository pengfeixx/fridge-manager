import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';

class ScoredRecipe {
  final Recipe recipe;
  final double coverage; // 0~1，已有食材比例
  final double score;
  const ScoredRecipe(this.recipe, this.coverage, this.score);
}

class RecommendationService {
  RecommendationService._();

  static const double _nearExpiryBoost = 0.5;

  /// 返回按 score 降序排序的推荐结果；忌口/过敏硬过滤。
  static List<ScoredRecipe> recommend(
    List<Recipe> recipes,
    List<FoodItem> inStockItems,
    List<FamilyMember> members,
    DateTime now,
  ) {
    final stockNames =
        inStockItems.map((i) => i.name.trim()).toSet();
    // 为每个库存食材记录是否临近过期
    final nearNames = inStockItems
        .where((i) =>
            ShelfLifeService.expiryLevel(i, now) == ExpiryLevel.near)
        .map((i) => i.name.trim())
        .toSet();

    final result = <ScoredRecipe>[];
    for (final r in recipes) {
      if (_isBlocked(r, members)) continue;
      final needed = r.ingredients.map((e) => e.foodName.trim()).toList();
      if (needed.isEmpty) continue;
      final haveCount = needed.where((n) => stockNames.contains(n)).length;
      final coverage = haveCount / needed.length;
      if (coverage == 0) continue; // 一点食材都没有则不推荐
      final nearHits =
          needed.where((n) => nearNames.contains(n)).length;
      final nearRatio = nearHits / needed.length;
      final score = coverage + nearRatio * _nearExpiryBoost;
      result.add(ScoredRecipe(r, coverage, score));
    }
    result.sort((a, b) => b.score.compareTo(a.score));
    return result;
  }

  /// 菜谱标签命中任一成员忌口，或食材命中任一成员过敏原 → 阻断。
  static bool _isBlocked(Recipe r, List<FamilyMember> members) {
    for (final m in members) {
      for (final tag in m.dietaryTags) {
        if (r.tags.any((t) => t.contains(tag) || tag.contains(t))) return true;
      }
      for (final allergy in m.allergies) {
        if (r.ingredients
            .any((ing) => ing.foodName.contains(allergy) || allergy.contains(ing.foodName))) {
          return true;
        }
      }
    }
    return false;
  }
}

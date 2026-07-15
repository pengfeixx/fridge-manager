import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';
import 'package:fridge_manager/domain/services/recommendation_service.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

/// 当前推荐排序结果（菜谱 × 在库食材 × 家庭成员）。
///
/// 仅监听菜谱流：菜谱变化时重新拉取三个仓库的当前快照并打分。
/// 库存/家庭成员的实时联动可在后续阶段用 rxdart combineLatest 增强。
final recommendationProvider = StreamProvider<List<ScoredRecipe>>((ref) async* {
  final recipeRepo = ref.watch(recipeRepositoryProvider);
  final foodRepo = ref.watch(foodRepositoryProvider);
  final familyRepo = ref.watch(familyRepositoryProvider);

  await for (final recipes in recipeRepo.watchAll()) {
    final stock = await foodRepo.watchInStock().first;
    final members = await familyRepo.watchAll().first;
    yield RecommendationService.recommend(recipes, stock, members, DateTime.now());
  }
});

final recipeByIdProvider =
    FutureProvider.family<Recipe?, int>((ref, id) async {
  return ref.watch(recipeRepositoryProvider).getById(id);
});

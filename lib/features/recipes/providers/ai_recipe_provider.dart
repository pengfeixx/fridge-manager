import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';
import 'package:fridge_manager/features/recipes/providers/recipe_providers.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

/// AI 生成菜谱的状态。
class AiRecipeState {
  final bool loading;
  final String? error;
  const AiRecipeState({this.loading = false, this.error});
}

class AiRecipeNotifier extends StateNotifier<AiRecipeState> {
  final Ref _ref;
  AiRecipeNotifier(this._ref) : super(const AiRecipeState());

  Future<void> generate() async {
    final aiService = await _ref.read(aiServiceProvider.future);
    if (aiService == null) {
      state = const AiRecipeState(error: '请先在设置中配置 AI');
      return;
    }
    state = const AiRecipeState(loading: true);
    try {
      final stock = await _ref.read(foodRepositoryProvider).watchInStock().first;
      if (stock.isEmpty) {
        state = const AiRecipeState(error: '冰箱里还没有食材');
        return;
      }
      final foodNames = stock.map((f) => f.name).toList();
      final recipe = await aiService.generateRecipe(foodNames);
      if (recipe == null) {
        state = const AiRecipeState(error: 'AI 生成失败，请重试');
        return;
      }
      await _ref.read(recipeRepositoryProvider).add(recipe);
      _ref.invalidate(recommendationProvider);
      state = const AiRecipeState();
    } catch (e) {
      state = AiRecipeState(error: '生成失败：$e');
    }
  }
}

final aiRecipeProvider =
    StateNotifierProvider<AiRecipeNotifier, AiRecipeState>(
        (ref) => AiRecipeNotifier(ref));

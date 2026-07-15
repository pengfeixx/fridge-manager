import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';
import 'package:fridge_manager/features/recipes/providers/recipe_providers.dart';

class RecipeDetailPage extends ConsumerWidget {
  final int id;
  const RecipeDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecipe = ref.watch(recipeByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('菜谱详情')),
      body: asyncRecipe.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (recipe) {
          if (recipe == null) return const Center(child: Text('菜谱不存在'));
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text(recipe.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final t in recipe.tags) Chip(label: Text(t)),
            ]),
            const SizedBox(height: 16),
            Text('用料', style: Theme.of(context).textTheme.titleMedium),
            for (final ing in recipe.ingredients)
              Text('• ${ing.foodName}  ${ing.amount}${ing.unit}'),
            const SizedBox(height: 16),
            Text('步骤', style: Theme.of(context).textTheme.titleMedium),
            for (var i = 0; i < recipe.steps.length; i++)
              Text('${i + 1}. ${recipe.steps[i]}'),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.restaurant),
              label: const Text('做这道菜（扣减食材）'),
              onPressed: () => _cook(context, ref,
                  recipe.ingredients.map((e) => e.foodName).toList()),
            ),
          ]);
        },
      ),
    );
  }

  /// 简化扣减：把菜谱涉及的、与库存同名的在库食材标记为 used。
  Future<void> _cook(BuildContext context, WidgetRef ref, List<String> names) async {
    final repo = ref.read(foodRepositoryProvider);
    final stock = await repo.watchInStock().first;
    final matched = stock.where((s) => names.contains(s.name.trim())).toList();
    for (final m in matched) {
      await repo.setStatus(m.id!, FoodStatus.used);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已扣减 ${matched.length} 种食材')),
      );
    }
    ref.invalidate(recommendationProvider);
  }
}

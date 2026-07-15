import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
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

  /// 扣减食材：对每个菜谱用料，在库存中找到**第一个**同名在库食材并标记为
  /// used（每种用料仅消耗一份）。执行前弹窗确认，列出将要消耗的食材。
  Future<void> _cook(BuildContext context, WidgetRef ref, List<String> names) async {
    final repo = ref.read(foodRepositoryProvider);
    final stock = await repo.watchInStock().first;
    // 每个用料名称只匹配第一条同名库存（去重，避免同一名称匹配多条）。
    final consumedNames = <String>{};
    final toConsume = <FoodItem>[];
    for (final name in names) {
      final trimmed = name.trim();
      if (!consumedNames.add(trimmed)) continue; // 同名用料只扣一份
      final match = stock.cast<FoodItem?>().firstWhere(
        (s) => s!.name.trim() == trimmed,
        orElse: () => null,
      );
      if (match != null) {
        toConsume.add(match);
      }
    }

    if (!context.mounted) return;
    if (toConsume.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('库存中没有匹配的食材，无法扣减')),
      );
      return;
    }

    final summary = toConsume
        .map((m) => '${m.name} x${_formatQty(m.quantity)}${m.unit}')
        .join('、');
    final missing = names
        .map((n) => n.trim())
        .toSet()
        .difference(consumedNames)
        .toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认扣减食材'),
        content: Text.rich(TextSpan(children: [
          const TextSpan(text: '将消耗以下食材：\n'),
          TextSpan(
              text: summary,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (missing.isNotEmpty) ...[
            const TextSpan(text: '\n\n缺少（已跳过）：\n'),
            TextSpan(
                text: missing.join('、'),
                style: TextStyle(color: Colors.orange[700])),
          ],
        ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认')),
        ],
      ),
    );
    if (confirmed != true) return;

    for (final m in toConsume) {
      await repo.setStatus(m.id!, FoodStatus.used);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已扣减 ${toConsume.length} 种食材')),
      );
    }
    ref.invalidate(recommendationProvider);
  }

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();
}

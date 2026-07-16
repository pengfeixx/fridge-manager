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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('菜谱详情')),
      body: asyncRecipe.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (recipe) {
          if (recipe == null) return const Center(child: Text('菜谱不存在'));
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (recipe.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in recipe.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: scheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _SectionCard(
                icon: Icons.shopping_basket_outlined,
                title: '用料',
                child: Column(
                  children: [
                    for (final ing in recipe.ingredients)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(ing.foodName,
                                style: const TextStyle(fontSize: 15)),
                            const Spacer(),
                            Text(
                              '${_fmtAmt(ing.amount)}${ing.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.format_list_numbered_rounded,
                title: '步骤',
                child: Column(
                  children: [
                    for (var i = 0; i < recipe.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recipe.steps[i],
                                style: const TextStyle(
                                    fontSize: 15, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.restaurant_rounded),
                label: const Text('做这道菜'),
                onPressed: () => _cook(context, ref,
                    recipe.ingredients.map((e) => e.foodName).toList()),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cook(
      BuildContext context, WidgetRef ref, List<String> names) async {
    final repo = ref.read(foodRepositoryProvider);
    final stock = await repo.watchInStock().first;
    final consumedNames = <String>{};
    final toConsume = <FoodItem>[];
    for (final name in names) {
      final trimmed = name.trim();
      if (!consumedNames.add(trimmed)) continue;
      final match = stock.cast<FoodItem?>().firstWhere(
        (s) => s!.name.trim() == trimmed,
        orElse: () => null,
      );
      if (match != null) toConsume.add(match);
    }

    if (!context.mounted) return;
    if (toConsume.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('库存中没有匹配的食材，无法扣减')),
      );
      return;
    }

    final summary = toConsume
        .map((m) => '${m.name} x${_fmtAmt(m.quantity)}${m.unit}')
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
        SnackBar(
          content: Text('已扣减 ${toConsume.length} 种食材'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    ref.invalidate(recommendationProvider);
  }

  String _fmtAmt(double a) =>
      a == a.roundToDouble() ? a.toInt().toString() : a.toStringAsFixed(1);
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  )),
            ]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/features/recipes/providers/ai_recipe_provider.dart';
import 'package:fridge_manager/features/recipes/providers/recipe_providers.dart';

class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReco = ref.watch(recommendationProvider);
    final aiState = ref.watch(aiRecipeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('今日推荐')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ai_recipe',
        onPressed: aiState.loading
            ? null
            : () async {
                await ref.read(aiRecipeProvider.notifier).generate();
                if (!context.mounted) return;
                final result = ref.read(aiRecipeProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.error ?? 'AI 已生成新菜谱')),
                );
              },
        icon: aiState.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome_rounded),
        label: const Text('AI 推荐菜谱'),
      ),
      body: asyncReco.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState(
              icon: Icons.restaurant_menu_rounded,
              title: '暂无推荐菜谱',
              subtitle: '先往冰箱添加一些食材\n系统会根据已有食材为你推荐菜谱',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.go('/recipes/${s.recipe.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _CoverageRing(coverage: s.coverage, color: scheme.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.recipe.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (s.recipe.tags.isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      for (final tag in s.recipe.tags.take(3))
                                        _Tag(label: tag),
                                    ],
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  '需要 ${s.recipe.ingredients.length} 种食材',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: scheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CoverageRing extends StatelessWidget {
  final double coverage;
  final Color color;
  const _CoverageRing({required this.coverage, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (coverage * 100).round();
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: coverage,
            strokeWidth: 4,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(pct == 100
                ? const Color(0xFF2E7D32)
                : color),
          ),
          Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: scheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: scheme.outline),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: scheme.outline, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

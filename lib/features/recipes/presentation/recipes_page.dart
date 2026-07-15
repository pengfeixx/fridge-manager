import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/features/recipes/providers/recipe_providers.dart';

class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReco = ref.watch(recommendationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('今日推荐')),
      body: asyncReco.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('暂无匹配菜谱，先往冰箱加些食材吧'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${(s.coverage * 100).round()}%'),
                ),
                title: Text(s.recipe.title),
                subtitle: Text(
                    '食材已有 ${(s.coverage * 100).round()}% · ${s.recipe.tags.join(' / ')}'),
                onTap: () => context.go('/recipes/${s.recipe.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

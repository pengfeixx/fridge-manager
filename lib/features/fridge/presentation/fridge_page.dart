import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/features/fridge/presentation/widgets/food_item_tile.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class FridgePage extends ConsumerWidget {
  const FridgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(foodRepositoryProvider);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('我的冰箱')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('添加食材'),
        onPressed: () => context.go('/fridge/add'),
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: repo.watchInStock(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('冰箱空空如也，点右下角添加食材'));
          }
          final grouped = <Storage, List<FoodItem>>{};
          for (final it in items) {
            grouped.putIfAbsent(it.storage, () => []).add(it);
          }
          return ListView(
            children: [
              for (final storage in Storage.values)
                if (grouped.containsKey(storage)) ...[
                  ListTile(
                    title: Text(storage.label,
                        style: Theme.of(context).textTheme.titleMedium),
                    dense: true,
                  ),
                  for (final it in grouped[storage]!)
                    FoodItemTile(
                      item: it,
                      now: now,
                      onEdit: () =>
                          context.go('/fridge/add', extra: it),
                      onUsed: () =>
                          repo.setStatus(it.id!, FoodStatus.used),
                      onDiscard: () =>
                          repo.setStatus(it.id!, FoodStatus.discarded),
                      onDelete: () => repo.delete(it.id!),
                    ),
                ],
            ],
          );
        },
      ),
    );
  }
}

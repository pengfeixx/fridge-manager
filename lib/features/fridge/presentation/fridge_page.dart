import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/core/theme/app_theme.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';
import 'package:fridge_manager/features/fridge/presentation/widgets/food_item_tile.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class FridgePage extends ConsumerWidget {
  const FridgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(foodRepositoryProvider);
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的冰箱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded),
            tooltip: '语音录入',
            onPressed: () => context.push('/voice'),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded),
            tooltip: '拍照识图',
            onPressed: () => context.push('/scan'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'AI 设置',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('添加食材'),
        onPressed: () => context.go('/fridge/add'),
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: repo.watchInStock(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _EmptyState(
              icon: Icons.kitchen_rounded,
              title: '冰箱空空如也',
              subtitle: '点击右下角按钮，添加你的第一个食材吧',
            );
          }

          final expired = items
              .where((i) =>
                  ShelfLifeService.expiryLevel(i, now) == ExpiryLevel.expired)
              .length;
          final near = items
              .where((i) =>
                  ShelfLifeService.expiryLevel(i, now) == ExpiryLevel.near)
              .length;

          final grouped = <Storage, List<FoodItem>>{};
          for (final it in items) {
            grouped.putIfAbsent(it.storage, () => []).add(it);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              if (expired > 0 || near > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      if (expired > 0)
                        _StatChip(
                          label: '$expired 件已过期',
                          color: AppTheme.expiryColor(ExpiryLevel.expired),
                          bgColor:
                              AppTheme.expiryBg(ExpiryLevel.expired),
                        ),
                      if (expired > 0 && near > 0) const SizedBox(width: 8),
                      if (near > 0)
                        _StatChip(
                          label: '$near 件临期',
                          color: AppTheme.expiryColor(ExpiryLevel.near),
                          bgColor: AppTheme.expiryBg(ExpiryLevel.near),
                        ),
                    ],
                  ),
                ),
              for (final storage in Storage.values)
                if (grouped.containsKey(storage)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Row(
                      children: [
                        Icon(AppTheme.storageIcon(storage.label),
                            size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${storage.label} · ${grouped[storage]!.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  const _StatChip(
      {required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
                    fontSize: 14, color: scheme.outline)),
          ],
        ),
      ),
    );
  }
}

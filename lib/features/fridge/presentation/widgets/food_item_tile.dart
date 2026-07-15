import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';
import 'package:fridge_manager/core/theme/app_theme.dart';

class FoodItemTile extends ConsumerWidget {
  final FoodItem item;
  final DateTime now;
  final VoidCallback onEdit;
  final VoidCallback onUsed;
  final VoidCallback onDiscard;
  final VoidCallback onDelete;

  const FoodItemTile({
    super.key,
    required this.item,
    required this.now,
    required this.onEdit,
    required this.onUsed,
    required this.onDiscard,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ShelfLifeService.expiryLevel(item, now);
    final remaining = ShelfLifeService.remainingDays(item, now);
    final subtitle = remaining < 0
        ? '已过期 ${-remaining} 天'
        : remaining == 0
            ? '今天到期'
            : '剩余 $remaining 天';
    return ListTile(
      leading: CircleAvatar(backgroundColor: AppTheme.expiryColor(level)),
      title: Text('${item.name}  ${item.quantity}${item.unit}'),
      subtitle: Text(subtitle),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') onEdit();
          if (v == 'used') onUsed();
          if (v == 'discard') onDiscard();
          if (v == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('编辑')),
          PopupMenuItem(value: 'used', child: Text('标记用完')),
          PopupMenuItem(value: 'discard', child: Text('标记丢弃')),
          PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
    );
  }
}

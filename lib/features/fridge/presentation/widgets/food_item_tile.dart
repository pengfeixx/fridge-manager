import 'package:flutter/material.dart';
import 'package:fridge_manager/core/theme/app_theme.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';

class FoodItemTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final level = ShelfLifeService.expiryLevel(item, now);
    final remaining = ShelfLifeService.remainingDays(item, now);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.expiryColor(level),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_fmtQty(item.quantity)}${item.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _ExpiryBadge(level: level, remaining: remaining),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: scheme.onSurfaceVariant),
                  onSelected: (v) {
                    switch (v) {
                      case 'used':
                        onUsed();
                      case 'discard':
                        onDiscard();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'used',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('标记用完'),
                        ])),
                    const PopupMenuItem(
                        value: 'discard',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 20),
                          SizedBox(width: 8),
                          Text('标记丢弃'),
                        ])),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.remove_circle_outline,
                              size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
}

class _ExpiryBadge extends StatelessWidget {
  final ExpiryLevel level;
  final int remaining;

  const _ExpiryBadge({required this.level, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final text = remaining < 0
        ? '已过期 ${-remaining} 天'
        : remaining == 0
            ? '今天到期'
            : '剩余 $remaining 天';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.expiryBg(level),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level == ExpiryLevel.expired
                ? Icons.error_outline
                : level == ExpiryLevel.near
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
            size: 14,
            color: AppTheme.expiryColor(level),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.expiryColor(level),
            ),
          ),
        ],
      ),
    );
  }
}

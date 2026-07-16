import 'package:flutter/material.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

class CategoryBar extends StatelessWidget {
  final NutritionCategory category;
  final int dailyRecommend;
  final double weeklyActual;
  final double weeklyGap;
  const CategoryBar({
    super.key,
    required this.category,
    required this.dailyRecommend,
    required this.weeklyActual,
    required this.weeklyGap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weeklyNeed = dailyRecommend * 7.0;
    final actualRatio =
        weeklyNeed > 0 ? (weeklyActual / weeklyNeed).clamp(0.0, 1.0) : 0.0;
    final isGap = weeklyGap > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(category.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(category.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  '每日推荐 ${dailyRecommend}g',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: actualRatio,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    isGap ? scheme.primary : const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Text(
                  '本周 ${weeklyActual.round()}g / ${(dailyRecommend * 7)}g',
                  style:
                      TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
                const Spacer(),
                if (isGap)
                  Text('缺 ${weeklyGap.round()}g',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary))
                else
                  Text('已达标',
                      style: TextStyle(
                          fontSize: 11, color: const Color(0xFF2E7D32))),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

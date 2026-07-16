import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/features/nutrition/presentation/meal_log_page.dart';
import 'package:fridge_manager/features/nutrition/presentation/widgets/category_bar.dart';
import 'package:fridge_manager/features/nutrition/providers/nutrition_providers.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gapAsync = ref.watch(nutritionGapProvider);
    final dailyAsync = ref.watch(dailyRecommendProvider);
    final logsAsync = ref.watch(weeklyLogsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('营养分析')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('记录饮食'),
        onPressed: () => showMealLogPage(context, ref)
            .then((_) => ref.invalidate(nutritionGapProvider)),
      ),
      body: dailyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (daily) {
          return gapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('出错：$e')),
            data: (gaps) {
              return logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('出错：$e')),
                data: (logs) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      // 标题区
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('本周营养摄入（参考膳食指南）',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant)),
                      ),
                      // 6 类别条形图
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              for (final cat in NutritionCategory.values)
                                CategoryBar(
                                  category: cat,
                                  dailyRecommend: daily[cat] ?? 0,
                                  weeklyActual: _getWeeklyActual(logs, cat),
                                  weeklyGap: gaps[cat] ?? 0,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 买菜建议入口
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('买菜建议',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant)),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.shopping_cart_rounded,
                              color: scheme.primary),
                          title: const Text('查看本周购物建议'),
                          subtitle: Text(
                              '有 ${gaps.values.where((g) => g > 0).length} 类食材需要补充'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/nutrition/shopping'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 本周记录
                      if (logs.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('本周饮食记录',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurfaceVariant)),
                        ),
                        for (final log in logs)
                          Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: scheme.primaryContainer,
                                child: Text(_mealEmoji(log.mealType),
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              title: Text(
                                  '${log.date.month}/${log.date.day} · ${_mealLabel(log.mealType)}'),
                              subtitle: Text(log.entries
                                  .map((e) =>
                                      '${e.category.emoji}${e.category.label} ${e.amountGram.round()}g')
                                  .join('  ')),
                            ),
                          ),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  double _getWeeklyActual(List<MealLog> logs, NutritionCategory cat) {
    double sum = 0;
    for (final log in logs) {
      for (final e in log.entries) {
        if (e.category == cat) sum += e.amountGram;
      }
    }
    return sum;
  }

  String _mealLabel(MealType type) => switch (type) {
        MealType.breakfast => '早餐',
        MealType.lunch => '午餐',
        MealType.dinner => '晚餐',
        MealType.snack => '加餐',
      };

  String _mealEmoji(MealType type) => switch (type) {
        MealType.breakfast => '☀️',
        MealType.lunch => '🍱',
        MealType.dinner => '🌙',
        MealType.snack => '🍎',
      };
}

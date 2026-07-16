import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/data/repositories/local_meal_log_repository.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/repositories/meal_log_repository.dart';
import 'package:fridge_manager/domain/services/nutrition_service.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

final mealLogRepositoryProvider = Provider<MealLogRepository>((ref) {
  return LocalMealLogRepository(MealLogDao(ref.watch(appDatabaseProvider)));
});

/// 本周日期范围（周一到今天）。
DateTime _weekStart(DateTime now) {
  final d = DateTime(now.year, now.month, now.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

/// 本周饮食记录。
final weeklyLogsProvider = StreamProvider((ref) {
  final repo = ref.watch(mealLogRepositoryProvider);
  final start = _weekStart(DateTime.now());
  return repo.watchByDateRange(start, DateTime.now());
});

/// 家庭每日各类别推荐量。CategoryBar 与缺口计算共用，确保一致。
final dailyRecommendProvider =
    FutureProvider<Map<NutritionCategory, int>>((ref) async {
  final members = await ref.watch(familyRepositoryProvider).watchAll().first;
  return NutritionService.dailyRecommendPerCategory(
      members, kNutritionGuideSeed);
});

/// 本周各类别营养缺口。
final nutritionGapProvider =
    FutureProvider<Map<NutritionCategory, double>>((ref) async {
  final daily = await ref.watch(dailyRecommendProvider.future);
  final logs = await ref.watch(weeklyLogsProvider.future);
  final stock = await ref.watch(foodRepositoryProvider).watchInStock().first;

  // 估算库存各类别可用量（按食材数量粗略归类）。
  final stockByCat = <NutritionCategory, double>{};
  for (final item in stock) {
    // 简化：按食材名称关键词归类。
    final cat = _guessCategory(item.name);
    stockByCat[cat] =
        (stockByCat[cat] ?? 0) + _estimateGrams(item.quantity, item.unit);
  }
  return NutritionService.weeklyGap(daily, logs, stockByCat);
});

/// 购物清单。
final shoppingListProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  final gaps = await ref.watch(nutritionGapProvider.future);
  return NutritionService.shoppingList(gaps);
});

/// 食材数量→克数的粗略估算。
/// g/克 直接取数量；kg 乘 1000；个/盒/袋/份 等按 100g 估算。
double _estimateGrams(double quantity, String unit) {
  switch (unit) {
    case 'g':
    case '克':
      return quantity;
    case 'kg':
      return quantity * 1000;
    default:
      return quantity * 100;
  }
}

/// 食材名称→营养类别的粗略推断。
NutritionCategory _guessCategory(String name) {
  final veg = [
    '菜',
    '菠菜',
    '白菜',
    '西兰花',
    '生菜',
    '胡萝卜',
    '土豆',
    '番茄',
    '西红柿',
    '茄子',
    '黄瓜',
    '洋葱',
    '豆角',
    '蘑菇'
  ];
  final meat = ['猪肉', '牛肉', '鸡肉', '鸭', '鱼', '虾', '蛋', '排骨', '里脊', '五花'];
  final fruit = ['苹果', '香蕉', '橙', '葡萄', '西瓜', '梨', '芒果', '草莓', '蓝莓'];
  final dairy = ['牛奶', '酸奶', '奶酪', '豆腐', '豆浆', '豆干', '黄豆'];
  final grain = ['米', '面', '面包', '馒头', '面条', '燕麦', '玉米', '红薯'];
  for (final k in veg) {
    if (name.contains(k)) return NutritionCategory.vegetables;
  }
  for (final k in meat) {
    if (name.contains(k)) return NutritionCategory.protein;
  }
  for (final k in fruit) {
    if (name.contains(k)) return NutritionCategory.fruits;
  }
  for (final k in dairy) {
    if (name.contains(k)) return NutritionCategory.dairy;
  }
  for (final k in grain) {
    if (name.contains(k)) return NutritionCategory.grains;
  }
  return NutritionCategory.vegetables; // 默认归蔬菜
}

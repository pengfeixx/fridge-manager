import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/shelf_life_rule.dart';

/// 临期分级，用于 UI 三色与提醒。
enum ExpiryLevel { safe, near, expired }

class ShelfLifeService {
  ShelfLifeService._();

  /// 仅按日期（不含时间）计算剩余天数；now 由调用方传入便于测试。
  static int remainingDays(FoodItem item, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final expire = item.expireDate;
    return expire.difference(today).inDays;
  }

  /// 剩余 0 天及以下视为过期；1~3 天为临期(near)；>3 为安全。
  static ExpiryLevel expiryLevel(FoodItem item, DateTime now,
      {int nearThreshold = 3}) {
    final r = remainingDays(item, now);
    if (r <= 0) return ExpiryLevel.expired;
    if (r <= nearThreshold) return ExpiryLevel.near;
    return ExpiryLevel.safe;
  }

  /// 在规则表中按 名称/别名 + 存储位置 匹配默认保质期；未命中返回 null。
  static int? matchRule(
      String foodName, Storage storage, List<ShelfLifeRule> rules) {
    final name = foodName.trim();
    for (final r in rules) {
      if (r.storage != storage) continue;
      if (r.foodName == name || r.aliases.contains(name)) return r.defaultDays;
    }
    return null;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/shelf_life_rule.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';

FoodItem _item({int shelfLife = 7, int daysAgo = 0}) => FoodItem(
      name: '白菜',
      categoryId: 1,
      quantity: 1,
      unit: '颗',
      storage: Storage.chilled,
      addedDate: DateTime(2026, 7, 15).subtract(Duration(days: daysAgo)),
      shelfLifeDays: shelfLife,
    );

void main() {
  final now = DateTime(2026, 7, 15); // 固定"今天"便于断言

  group('remainingDays', () {
    test('买来当天剩余 = 全部保质期', () {
      expect(ShelfLifeService.remainingDays(_item(daysAgo: 0), now), 7);
    });
    test('过期后返回负数', () {
      expect(ShelfLifeService.remainingDays(_item(daysAgo: 10), now), -3);
    });
    test('恰好到期日当天剩余 0', () {
      expect(ShelfLifeService.remainingDays(_item(daysAgo: 7), now), 0);
    });
  });

  group('expiryLevel', () {
    test('剩余>3 为 safe', () {
      expect(ShelfLifeService.expiryLevel(_item(daysAgo: 0), now),
          ExpiryLevel.safe);
    });
    test('剩余 1~3 为 near', () {
      expect(ShelfLifeService.expiryLevel(_item(daysAgo: 5, shelfLife: 7), now),
          ExpiryLevel.near);
    });
    test('剩余 0 为 expired（边界）', () {
      expect(ShelfLifeService.expiryLevel(_item(daysAgo: 7, shelfLife: 7), now),
          ExpiryLevel.expired);
    });
    test('负数为 expired', () {
      expect(ShelfLifeService.expiryLevel(_item(daysAgo: 9, shelfLife: 7), now),
          ExpiryLevel.expired);
    });
  });

  group('matchRule', () {
    final rules = [
      const ShelfLifeRule(foodName: '白菜', aliases: ['大白菜', '小白菜'], storage: Storage.chilled, defaultDays: 7),
      const ShelfLifeRule(foodName: '白菜', storage: Storage.frozen, defaultDays: 60),
      const ShelfLifeRule(foodName: '猪肉', aliases: ['猪五花'], storage: Storage.chilled, defaultDays: 3),
    ];
    test('按名称命中返回默认天数', () {
      expect(ShelfLifeService.matchRule('白菜', Storage.chilled, rules), 7);
    });
    test('按别名命中', () {
      expect(ShelfLifeService.matchRule('小白菜', Storage.chilled, rules), 7);
    });
    test('同名不同存储位置区分', () {
      expect(ShelfLifeService.matchRule('白菜', Storage.frozen, rules), 60);
    });
    test('未命中返回 null', () {
      expect(ShelfLifeService.matchRule('芒果', Storage.chilled, rules), isNull);
    });
  });
}

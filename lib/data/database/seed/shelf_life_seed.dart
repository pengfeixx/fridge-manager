import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/shelf_life_rule.dart';

/// 内置常见食材保质期参考表（参考通用经验值，用户可在 UI 修改）。
const List<ShelfLifeRule> kShelfLifeSeed = [
  // 叶菜
  ShelfLifeRule(foodName: '白菜', aliases: ['大白菜', '小白菜'], storage: Storage.chilled, defaultDays: 7),
  ShelfLifeRule(foodName: '菠菜', storage: Storage.chilled, defaultDays: 3),
  ShelfLifeRule(foodName: '生菜', storage: Storage.chilled, defaultDays: 4),
  ShelfLifeRule(foodName: '西兰花', aliases: ['绿菜花'], storage: Storage.chilled, defaultDays: 5),
  // 根茎
  ShelfLifeRule(foodName: '胡萝卜', storage: Storage.chilled, defaultDays: 14),
  ShelfLifeRule(foodName: '土豆', aliases: ['马铃薯'], storage: Storage.room, defaultDays: 30),
  ShelfLifeRule(foodName: '洋葱', storage: Storage.room, defaultDays: 30),
  // 肉类
  ShelfLifeRule(foodName: '猪肉', aliases: ['猪五花', '里脊'], storage: Storage.chilled, defaultDays: 3),
  ShelfLifeRule(foodName: '猪肉', storage: Storage.frozen, defaultDays: 90),
  ShelfLifeRule(foodName: '鸡肉', aliases: ['鸡腿', '鸡胸'], storage: Storage.chilled, defaultDays: 2),
  ShelfLifeRule(foodName: '鸡肉', storage: Storage.frozen, defaultDays: 90),
  ShelfLifeRule(foodName: '牛肉', storage: Storage.chilled, defaultDays: 4),
  ShelfLifeRule(foodName: '牛肉', storage: Storage.frozen, defaultDays: 120),
  // 水产
  ShelfLifeRule(foodName: '鱼', aliases: ['鲈鱼', '鲫鱼'], storage: Storage.chilled, defaultDays: 1),
  ShelfLifeRule(foodName: '虾', storage: Storage.chilled, defaultDays: 1),
  // 蛋奶豆
  ShelfLifeRule(foodName: '鸡蛋', storage: Storage.chilled, defaultDays: 30),
  ShelfLifeRule(foodName: '豆腐', storage: Storage.chilled, defaultDays: 5),
  ShelfLifeRule(foodName: '牛奶', storage: Storage.chilled, defaultDays: 7),
];

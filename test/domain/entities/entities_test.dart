import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';

void main() {
  test('Storage.parse 支持中文与英文', () {
    expect(Storage.parse('冷藏'), Storage.chilled);
    expect(Storage.parse('冷冻'), Storage.frozen);
    expect(Storage.parse('常温'), Storage.room);
    expect(Storage.parse('chilled'), Storage.chilled);
    expect(Storage.parse('frozen'), Storage.frozen);
    expect(Storage.parse('room'), Storage.room);
  });

  test('Storage.label 返回中文', () {
    expect(Storage.chilled.label, '冷藏');
    expect(Storage.frozen.label, '冷冻');
    expect(Storage.room.label, '常温');
  });

  test('FoodStatus.values 覆盖三种状态', () {
    expect(FoodStatus.values, hasLength(3));
  });

  test('FoodItem.expireDate 为 addedDate + shelfLifeDays', () {
    final item = FoodItem(
      name: '牛奶',
      categoryId: 1,
      quantity: 1,
      unit: '盒',
      storage: Storage.chilled,
      addedDate: DateTime(2026, 1, 1),
      shelfLifeDays: 7,
    );
    expect(item.expireDate, DateTime(2026, 1, 8));
  });

  test('FoodItem.expireDate 在 shelfLifeDays 为 0 时等于 addedDate', () {
    final item = FoodItem(
      name: '生菜',
      categoryId: 2,
      quantity: 1,
      unit: '颗',
      storage: Storage.room,
      addedDate: DateTime(2026, 1, 1),
      shelfLifeDays: 0,
    );
    expect(item.expireDate, item.addedDate);
  });
}

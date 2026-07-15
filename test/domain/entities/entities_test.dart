import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/entities/enums.dart';

void main() {
  test('Storage.parse 支持中文与英文', () {
    expect(Storage.parse('冷藏'), Storage.chilled);
    expect(Storage.parse('冷冻'), Storage.frozen);
    expect(Storage.parse('常温'), Storage.room);
    expect(Storage.parse('chilled'), Storage.chilled);
  });

  test('Storage.label 返回中文', () {
    expect(Storage.chilled.label, '冷藏');
    expect(Storage.frozen.label, '冷冻');
    expect(Storage.room.label, '常温');
  });

  test('FoodStatus.values 覆盖三种状态', () {
    expect(FoodStatus.values, hasLength(3));
  });
}

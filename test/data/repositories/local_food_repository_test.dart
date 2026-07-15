import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/repositories/local_food_repository.dart';
import 'package:fridge_manager/domain/entities/enums.dart';

void main() {
  late LocalFoodRepository repo;
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
    repo = LocalFoodRepository(FoodItemDao(db));
  });
  tearDown(() => db.close());

  test('addWithDefaultShelfLife 用规则填默认保质期', () async {
    await repo.addWithDefaultShelfLife(
      name: '白菜', categoryId: 1, quantity: 1, unit: '颗',
      storage: Storage.chilled, addedDate: DateTime(2026, 7, 15),
    );
    final list = await repo.watchInStock().first;
    expect(list.single.name, '白菜');
    expect(list.single.shelfLifeDays, 7); // 种子表白菜冷藏默认 7 天
  });

  test('无匹配规则时回退到类别默认 7 天', () async {
    await repo.addWithDefaultShelfLife(
      name: '火星蔬菜', categoryId: 99, quantity: 1, unit: '个',
      storage: Storage.room, addedDate: DateTime(2026, 7, 15),
    );
    final list = await repo.watchInStock().first;
    expect(list.single.shelfLifeDays, 7);
  });

  test('setStatus 后不再出现在在库列表', () async {
    await repo.addWithDefaultShelfLife(
      name: '白菜', categoryId: 1, quantity: 1, unit: '颗',
      storage: Storage.chilled, addedDate: DateTime(2026, 7, 15));
    final id = (await repo.watchInStock().first).single.id!;
    await repo.setStatus(id, FoodStatus.used);
    expect(await repo.watchInStock().first, isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/domain/entities/enums.dart';

void main() {
  late AppDatabase db;
  late FoodItemDao dao;

  setUp(() {
    db = AppDatabase.memory();
    dao = FoodItemDao(db);
  });
  tearDown(() => db.close());

  test('add 后 getById 可取回，且 status 默认 inStock', () async {
    final id = await dao.add(FoodItemsCompanion.insert(
      name: '白菜',
      categoryId: 1,
      quantity: 1,
      unit: '颗',
      storage: Storage.chilled,
      addedDate: DateTime(2026, 7, 10),
      shelfLifeDays: 7,
    ));
    final got = await dao.getById(id);
    expect(got.name, '白菜');
    expect(got.status, FoodStatus.inStock);
  });

  test('watchInStock 只返回在库项', () async {
    final id = await dao.add(FoodItemsCompanion.insert(
      name: '猪肉', categoryId: 2, quantity: 500, unit: 'g',
      storage: Storage.chilled, addedDate: DateTime(2026, 7, 14),
      shelfLifeDays: 3,
    ));
    await dao.add(FoodItemsCompanion.insert(
      name: '豆腐', categoryId: 3, quantity: 1, unit: '盒',
      storage: Storage.chilled, addedDate: DateTime(2026, 7, 15),
      shelfLifeDays: 5,
    ));
    await dao.updateStatus(id, FoodStatus.used);

    final list = await dao.watchInStock().first;
    expect(list, hasLength(1));
    expect(list.single.name, '豆腐');
  });
}

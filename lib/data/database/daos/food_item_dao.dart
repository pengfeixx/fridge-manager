import 'package:drift/drift.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/tables.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';

part 'food_item_dao.g.dart';

@DriftAccessor(tables: [FoodItems])
class FoodItemDao extends DatabaseAccessor<AppDatabase> with _$FoodItemDaoMixin {
  FoodItemDao(super.db);

  Stream<List<FoodItem>> watchInStock() {
    final q = select(foodItems)
      ..where((t) => t.status.equals('inStock'))
      ..orderBy([(t) => OrderingTerm(expression: t.addedDate)]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<FoodItem> getById(int id) async {
    final row =
        await (select(foodItems)..where((t) => t.id.equals(id))).getSingle();
    return _toDomain(row);
  }

  Future<List<FoodItem>> all() => select(foodItems).map(_toDomain).get();

  Future<int> add(FoodItemsCompanion c) => into(foodItems).insert(c);

  Future<int> updateRow(FoodItem item) =>
      (update(foodItems)..where((t) => t.id.equals(item.id!)))
          .write(_toCompanionUpdate(item));

  Future<void> updateStatus(int id, FoodStatus status) =>
      (update(foodItems)..where((t) => t.id.equals(id)))
          .write(FoodItemsCompanion(status: Value(status.name)));

  Future<int> remove(int id) =>
      (delete(foodItems)..where((t) => t.id.equals(id))).go();

  FoodItem _toDomain(FoodItemData r) => FoodItem(
        id: r.id,
        name: r.name,
        categoryId: r.categoryId,
        quantity: r.quantity,
        unit: r.unit,
        storage: r.storage,
        addedDate: r.addedDate,
        shelfLifeDays: r.shelfLifeDays,
        status: FoodStatus.values.firstWhere(
          (s) => s.name == r.status,
          orElse: () => FoodStatus.inStock,
        ),
        note: r.note,
      );

  FoodItemsCompanion _toCompanionUpdate(FoodItem i) => FoodItemsCompanion(
        name: Value(i.name),
        categoryId: Value(i.categoryId),
        quantity: Value(i.quantity),
        unit: Value(i.unit),
        storage: Value(i.storage),
        addedDate: Value(i.addedDate),
        shelfLifeDays: Value(i.shelfLifeDays),
        note: Value(i.note),
      );
}

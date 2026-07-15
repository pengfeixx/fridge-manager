import 'package:fridge_manager/data/database/app_database.dart' hide ShelfLifeRule;
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/database/seed/shelf_life_seed.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/shelf_life_rule.dart';
import 'package:fridge_manager/domain/repositories/food_repository.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';

class LocalFoodRepository implements FoodRepository {
  final FoodItemDao _dao;
  const LocalFoodRepository(this._dao);

  /// 未命中规则时的兜底默认天数。
  static const int _fallbackDays = 7;

  @override
  Stream<List<FoodItem>> watchInStock() => _dao.watchInStock();

  @override
  Future<FoodItem> getById(int id) => _dao.getById(id);

  @override
  Future<int> addWithDefaultShelfLife({
    required String name,
    required int categoryId,
    required double quantity,
    required String unit,
    required Storage storage,
    required DateTime addedDate,
  }) {
    final days = ShelfLifeService.matchRule(name, storage, kShelfLifeSeed) ??
        _fallbackDays;
    return _dao.add(FoodItemsCompanion.insert(
      name: name,
      categoryId: categoryId,
      quantity: quantity,
      unit: unit,
      storage: storage,
      addedDate: addedDate,
      shelfLifeDays: days,
    ));
  }

  @override
  Future<void> update(FoodItem item) => _dao.updateRow(item);

  @override
  Future<void> setStatus(int id, FoodStatus status) =>
      _dao.updateStatus(id, status);

  @override
  Future<void> delete(int id) => _dao.remove(id);

  @override
  List<ShelfLifeRule> getShelfLifeRules() => kShelfLifeSeed;
}

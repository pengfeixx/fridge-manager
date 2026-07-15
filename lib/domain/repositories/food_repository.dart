import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/shelf_life_rule.dart';

abstract class FoodRepository {
  Stream<List<FoodItem>> watchInStock();
  Future<FoodItem> getById(int id);
  Future<int> addWithDefaultShelfLife({
    required String name,
    required int categoryId,
    required double quantity,
    required String unit,
    required Storage storage,
    required DateTime addedDate,
  });
  Future<void> update(FoodItem item);
  Future<void> setStatus(int id, FoodStatus status);
  Future<void> delete(int id);
  List<ShelfLifeRule> getShelfLifeRules();
}

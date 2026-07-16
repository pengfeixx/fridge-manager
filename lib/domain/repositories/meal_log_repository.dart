import 'package:fridge_manager/domain/entities/meal_log.dart';

abstract class MealLogRepository {
  Future<List<MealLog>> getByDateRange(DateTime start, DateTime end);
  Stream<List<MealLog>> watchByDateRange(DateTime start, DateTime end);
  Future<int> add(MealLog log);
  Future<void> delete(int id);
}

import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/repositories/meal_log_repository.dart';

class LocalMealLogRepository implements MealLogRepository {
  final MealLogDao _dao;
  const LocalMealLogRepository(this._dao);

  @override
  Future<List<MealLog>> getByDateRange(DateTime start, DateTime end) =>
      _dao.getByDateRange(start, end);

  @override
  Stream<List<MealLog>> watchByDateRange(DateTime start, DateTime end) =>
      _dao.watchByDateRange(start, end);

  @override
  Future<int> add(MealLog log) => _dao.addMealLog(log);

  @override
  Future<void> delete(int id) async => _dao.remove(id);
}

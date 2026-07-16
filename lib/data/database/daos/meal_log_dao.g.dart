// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log_dao.dart';

// ignore_for_file: type=lint
mixin _$MealLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealLogsTableTable get mealLogsTable => attachedDatabase.mealLogsTable;
  $MealEntriesTableTable get mealEntriesTable =>
      attachedDatabase.mealEntriesTable;
  MealLogDaoManager get managers => MealLogDaoManager(this);
}

class MealLogDaoManager {
  final _$MealLogDaoMixin _db;
  MealLogDaoManager(this._db);
  $$MealLogsTableTableTableManager get mealLogsTable =>
      $$MealLogsTableTableTableManager(_db.attachedDatabase, _db.mealLogsTable);
  $$MealEntriesTableTableTableManager get mealEntriesTable =>
      $$MealEntriesTableTableTableManager(
          _db.attachedDatabase, _db.mealEntriesTable);
}

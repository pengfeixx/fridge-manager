import 'package:drift/drift.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/tables.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

part 'meal_log_dao.g.dart';

@DriftAccessor(tables: [MealLogsTable, MealEntriesTable])
class MealLogDao extends DatabaseAccessor<AppDatabase> with _$MealLogDaoMixin {
  MealLogDao(super.db);

  Future<List<MealLog>> getByDateRange(DateTime start, DateTime end) async {
    final logs = await (select(mealLogsTable)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .get();
    return Future.wait(logs.map(_loadEntries));
  }

  Stream<List<MealLog>> watchByDateRange(DateTime start, DateTime end) {
    final q = select(mealLogsTable)
      ..where((t) => t.date.isBetweenValues(start, end));
    return q.watch().asyncMap((rows) => Future.wait(rows.map(_loadEntries)));
  }

  Future<int> addMealLog(MealLog log) async {
    final id = await into(mealLogsTable).insert(MealLogsTableCompanion.insert(
      date: log.date,
      mealType: log.mealType.name,
    ));
    for (final e in log.entries) {
      await into(mealEntriesTable).insert(MealEntriesTableCompanion.insert(
        mealLogId: id,
        category: e.category.name,
        amountGram: e.amountGram,
        description: Value(e.description),
      ));
    }
    return id;
  }

  Future<int> remove(int id) async {
    await (delete(mealEntriesTable)..where((t) => t.mealLogId.equals(id))).go();
    return (delete(mealLogsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<MealLog> _loadEntries(MealLogData row) async {
    final entries = await (select(mealEntriesTable)
          ..where((t) => t.mealLogId.equals(row.id)))
        .map((e) => MealEntry(
              id: e.id,
              category: NutritionCategory.values.firstWhere(
                (c) => c.name == e.category,
                orElse: () => NutritionCategory.grains,
              ),
              amountGram: e.amountGram,
              description: e.description,
            ))
        .get();
    return MealLog(
      id: row.id,
      date: row.date,
      mealType: MealType.values.firstWhere(
        (m) => m.name == row.mealType,
        orElse: () => MealType.dinner,
      ),
      entries: entries,
    );
  }
}

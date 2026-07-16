import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/repositories/local_meal_log_repository.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

void main() {
  late LocalMealLogRepository repo;
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
    repo = LocalMealLogRepository(MealLogDao(db));
  });
  tearDown(() => db.close());

  test('add 后可按日期范围查回', () async {
    final date = DateTime(2026, 7, 16);
    await repo.add(MealLog(
      date: date,
      mealType: MealType.lunch,
      entries: [
        const MealEntry(category: NutritionCategory.vegetables, amountGram: 200),
        const MealEntry(category: NutritionCategory.protein, amountGram: 150),
      ],
    ));
    final logs = await repo.getByDateRange(
      DateTime(2026, 7, 16),
      DateTime(2026, 7, 17),
    );
    expect(logs, hasLength(1));
    expect(logs[0].entries, hasLength(2));
    expect(logs[0].entries[0].category, NutritionCategory.vegetables);
  });

  test('delete 后查不到', () async {
    final id = await repo.add(MealLog(
      date: DateTime(2026, 7, 16),
      mealType: MealType.dinner,
      entries: const [
        MealEntry(category: NutritionCategory.grains, amountGram: 100),
      ],
    ));
    await repo.delete(id);
    final logs = await repo.getByDateRange(
      DateTime(2026, 7, 1),
      DateTime(2026, 7, 31),
    );
    expect(logs, isEmpty);
  });
}

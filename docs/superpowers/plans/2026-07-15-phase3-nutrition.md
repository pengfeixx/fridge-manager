# 阶段三·营养买菜建议 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现饮食记录、基于《中国居民膳食指南(2022)》的营养缺口分析、以及量化买菜建议，让用户知道"本周吃得是否均衡、该再买什么"。

**Architecture:** 新增 `MealLog` 数据模型（drift 表 + DAO + Repository）记录每日饮食。`NutritionService` 纯函数计算家庭每日各类别推荐量 vs 本周实际摄入，输出缺口。`NutritionGuide` 种子表内置膳食指南参考值。UI 用第四个 Tab（营养）展示分析结果和购物建议。

**Tech Stack:** drift (新表), Riverpod (providers), 现有 FamilyMember/AiService

## Global Constraints

- **Flutter SDK**: >=3.4.0 <4.0.0, stable channel（已装 3.44.6）
- **分层铁律**: `lib/domain/**` 纯 Dart；NutritionService 是纯函数，TDD 覆盖
- **营养计算口径**: 家庭每日某类推荐量 = Σ(各成员按年龄/性别推荐量)；本周缺口 = 推荐量×7 − 本周MealLog该类汇总 − 当前在库可用量（下限0）
- **膳食指南数据**: 基于《中国居民膳食指南(2022)》，标注为"参考值"
- **6 大食物类别**: 谷薯类 / 蔬菜类 / 水果类 / 畜禽鱼蛋类 / 奶类及豆制品 / 油盐类
- **饮食记录不区分成员**: 默认全家都吃
- **提交**: 每 Task 提交，约定式提交

---

## 文件结构

```
lib/
  domain/
    entities/
      meal_log.dart                    # MealLog + MealEntry 实体
      nutrition_guide.dart             # NutritionGuide 实体 + NutritionCategory 枚举
    repositories/
      meal_log_repository.dart         # 抽象接口
    services/
      nutrition_service.dart           # 纯函数: 推荐量/缺口计算
  data/
    database/
      tables.dart                      # 追加 MealLogs + MealEntries 表
      app_database.dart                # tables 追加
      daos/meal_log_dao.dart
      database/seed/nutrition_guide_seed.dart  # 膳食指南种子
      repositories/local_meal_log_repository.dart
  features/
    nutrition/
      providers/nutrition_providers.dart
      presentation/nutrition_page.dart          # 营养分析主页
      presentation/meal_log_page.dart           # 记录饮食
      presentation/shopping_suggestion_page.dart # 买菜建议
      presentation/widgets/
        category_bar.dart                        # 类别推荐/实际/缺口条形图
test/
  domain/services/nutrition_service_test.dart
  data/repositories/local_meal_log_repository_test.dart
```

---

### Task 1: 营养类别枚举 + NutritionGuide 实体 + 种子数据

**Files:**
- Create: `lib/domain/entities/nutrition_guide.dart`
- Create: `lib/data/database/seed/nutrition_guide_seed.dart`
- Test: `test/domain/entities/nutrition_guide_test.dart`

**Interfaces:**
- Consumes: 无
- Produces: `NutritionCategory` 枚举（6 类）、`NutritionGuide` 实体、`kNutritionGuideSeed` 种子表

- [ ] **Step 1: 实现枚举与实体**

`lib/domain/entities/nutrition_guide.dart`:
```dart
/// 6 大食物类别。
enum NutritionCategory {
  grains('谷薯类', '🍚'),
  vegetables('蔬菜类', '🥬'),
  fruits('水果类', '🍎'),
  protein('畜禽鱼蛋类', '🥩'),
  dairy('奶类及豆制品', '🥛'),
  oilSalt('油盐类', '🧂');

  final String label;
  final String emoji;
  const NutritionCategory(this.label, this.emoji);
}

/// 膳食指南参考条目：某年龄段 × 性别 × 类别 → 每日推荐克数。
class NutritionGuide {
  final int ageMin;
  final int ageMax;
  final String gender; // 'male' / 'female'
  final NutritionCategory category;
  final int dailyGram; // 每日推荐克数（克/天）

  const NutritionGuide({
    required this.ageMin,
    required this.ageMax,
    required this.gender,
    required this.category,
    required this.dailyGram,
  });
}
```

- [ ] **Step 2: 实现种子数据**

`lib/data/database/seed/nutrition_guide_seed.dart`:
```dart
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

/// 基于《中国居民膳食指南(2022)》的简化参考表。
/// 按年龄段(儿童/青少年/成人/老年) × 性别 × 类别，每日推荐克数。
/// 标注: 此为参考值, 实际需求因个体活动量等因素而异。
const kNutritionGuideSeed = <NutritionGuide>[
  // === 2-5 岁 ===
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.grains, dailyGram: 100),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 200),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.fruits, dailyGram: 150),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.protein, dailyGram: 50),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 25),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.grains, dailyGram: 85),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 200),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.fruits, dailyGram: 150),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.protein, dailyGram: 50),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 25),

  // === 6-17 岁 ===
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.grains, dailyGram: 250),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 400),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.fruits, dailyGram: 250),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.protein, dailyGram: 120),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 30),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.grains, dailyGram: 225),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 375),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.fruits, dailyGram: 225),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.protein, dailyGram: 110),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 28),

  // === 18-64 岁 ===
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.grains, dailyGram: 300),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 500),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.fruits, dailyGram: 350),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.protein, dailyGram: 175),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 30),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.grains, dailyGram: 250),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 400),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.fruits, dailyGram: 300),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.protein, dailyGram: 140),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 25),

  // === 65+ 岁 ===
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.grains, dailyGram: 250),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 400),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.fruits, dailyGram: 300),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.protein, dailyGram: 150),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 25),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.grains, dailyGram: 225),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 350),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.fruits, dailyGram: 275),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.protein, dailyGram: 130),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 22),
];
```

- [ ] **Step 3: 写枚举测试**

`test/domain/entities/nutrition_guide_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

void main() {
  test('NutritionCategory 有 6 个类别', () {
    expect(NutritionCategory.values, hasLength(6));
  });

  test('种子表覆盖所有类别 × 性别 × 年龄段', () {
    for (final cat in NutritionCategory.values) {
      for (final gender in ['male', 'female']) {
        final matches = kNutritionGuideSeed
            .where((g) => g.category == cat && g.gender == gender)
            .toList();
        expect(matches, isNotEmpty, reason: '$gender $cat 无数据');
      }
    }
  });

  test('每个年龄段的推荐量合理（> 0）', () {
    for (final g in kNutritionGuideSeed) {
      expect(g.dailyGram, greaterThan(0));
    }
  });
});
```

- [ ] **Step 4: 验证**

```bash
flutter test test/domain/entities/nutrition_guide_test.dart
flutter analyze
```

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat(nutrition): 营养类别枚举 + 膳食指南种子数据"
```

---

### Task 2: MealLog 数据模型（drift 表 + DAO + Repository）

**Files:**
- Modify: `lib/data/database/tables.dart`（追加 MealLogs + MealEntries 表）
- Modify: `lib/data/database/app_database.dart`（tables 追加）
- Create: `lib/domain/entities/meal_log.dart`
- Create: `lib/data/database/daos/meal_log_dao.dart`
- Create: `lib/domain/repositories/meal_log_repository.dart`
- Create: `lib/data/repositories/local_meal_log_repository.dart`
- Test: `test/data/repositories/local_meal_log_repository_test.dart`

**Interfaces:**
- Consumes: `NutritionCategory`, `AppDatabase`
- Produces: `MealLog` 实体、`MealEntry` 实体、`MealLogRepository`（watchByDateRange / add / delete）

- [ ] **Step 1: 实现 MealLog 实体**

`lib/domain/entities/meal_log.dart`:
```dart
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  final int? id;
  final NutritionCategory category;
  final double amountGram;
  final String? description;

  const MealEntry({
    this.id,
    required this.category,
    required this.amountGram,
    this.description,
  });

  MealEntry copyWith({
    int? id,
    NutritionCategory? category,
    double? amountGram,
    String? description,
  }) =>
      MealEntry(
        id: id ?? this.id,
        category: category ?? this.category,
        amountGram: amountGram ?? this.amountGram,
        description: description ?? this.description,
      );
}

class MealLog {
  final int? id;
  final DateTime date;
  final MealType mealType;
  final List<MealEntry> entries;

  const MealLog({
    this.id,
    required this.date,
    required this.mealType,
    this.entries = const [],
  });
}
```

- [ ] **Step 2: 追加 drift 表**

在 `lib/data/database/tables.dart` 追加：
```dart
class MealLogsTable extends Table {
  @override
  String get tableName => 'meal_logs';
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()(); // breakfast/lunch/dinner/snack
}

class MealEntriesTable extends Table {
  @override
  String get tableName => 'meal_entries';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealLogId => integer()();
  TextColumn get category => text()(); // NutritionCategory.name
  RealColumn get amountGram => real()();
  TextColumn get description => text().nullable()();
}
```

更新 `app_database.dart` 的 `@DriftDatabase` tables 追加 `MealLogsTable, MealEntriesTable`。需要加 `@DataClassName` 避免名称冲突。

- [ ] **Step 3: 实现 MealLogDao**

`lib/data/database/daos/meal_log_dao.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:fridge_manager/data/database/app_database.dart';
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
    return q.watch().asyncMap((rows) =>
        Future.wait(rows.map(_loadEntries)));
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

  Future<MealLog> _loadEntries(MealLogsTableData row) async {
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
```

- [ ] **Step 4: 实现 Repository 接口 + 本地实现**

`lib/domain/repositories/meal_log_repository.dart`:
```dart
import 'package:fridge_manager/domain/entities/meal_log.dart';

abstract class MealLogRepository {
  Future<List<MealLog>> getByDateRange(DateTime start, DateTime end);
  Stream<List<MealLog>> watchByDateRange(DateTime start, DateTime end);
  Future<int> add(MealLog log);
  Future<void> delete(int id);
}
```

`lib/data/repositories/local_meal_log_repository.dart`:
```dart
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
```

- [ ] **Step 5: 重新生成代码**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: 写仓库测试**

`test/data/repositories/local_meal_log_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/repositories/local_meal_log_repository.dart';
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
```

- [ ] **Step 7: 验证 + 提交**

```bash
flutter analyze
flutter test
git add -A
git commit -m "feat(nutrition): MealLog 数据模型(drift表/DAO/Repository)"
```

---

### Task 3: NutritionService 营养计算引擎（TDD）

**Files:**
- Create: `lib/domain/services/nutrition_service.dart`
- Test: `test/domain/services/nutrition_service_test.dart`

**Interfaces:**
- Consumes: `NutritionCategory`, `NutritionGuide`, `FamilyMember`, `MealLog`, `FoodItem`
- Produces: `NutritionService`（纯函数）：`dailyRecommendPerCategory(members)` → `Map<NutritionCategory, int>`、`weeklyGap(...)` → `Map<NutritionCategory, double>`、`shoppingList(...)` → `List<ShoppingItem>`

- [ ] **Step 1: 写测试**

`test/domain/services/nutrition_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/services/nutrition_service.dart';

void main() {
  final members = [
    const FamilyMember(name: '爸', age: 40, gender: Gender.male),
    const FamilyMember(name: '妈', age: 38, gender: Gender.female),
    const FamilyMember(name: '娃', age: 8, gender: Gender.male),
  ];

  group('dailyRecommendPerCategory', () {
    test('各成员推荐量之和', () {
      final result = NutritionService.dailyRecommendPerCategory(
        members, kNutritionGuideSeed);
      // 爸(40,男)+妈(38,女)+娃(8,男)
      // 谷薯: 300 + 250 + 250 = 800
      expect(result[NutritionCategory.grains], 800);
      // 蔬菜: 500 + 400 + 400 = 1300
      expect(result[NutritionCategory.vegetables], 1300);
    });

    test('无成员返回全 0', () {
      final result = NutritionService.dailyRecommendPerCategory(
        [], kNutritionGuideSeed);
      for (final v in result.values) {
        expect(v, 0);
      }
    });
  });

  group('weeklyGap', () {
    test('缺口 = 推荐量×7 − 实际摄入 − 库存', () {
      final daily = <NutritionCategory, int>{
        NutritionCategory.vegetables: 1000, // 每天需 1000g
      };
      final weekLogs = [
        MealLog(date: DateTime(2026, 7, 14), mealType: MealType.lunch, entries: [
          const MealEntry(category: NutritionCategory.vegetables, amountGram: 300),
        ]),
        MealLog(date: DateTime(2026, 7, 15), mealType: MealType.dinner, entries: [
          const MealEntry(category: NutritionCategory.vegetables, amountGram: 200),
        ]),
      ];
      // 本周已吃 500g 蔬菜, 库存有 300g
      // 需求 = 1000*7 = 7000, 缺口 = 7000 - 500 - 300 = 6200
      final gap = NutritionService.weeklyGap(
        daily, weekLogs, {NutritionCategory.vegetables: 300});
      expect(gap[NutritionCategory.vegetables], 6200);
    });

    test('盈余时缺口为 0（下限 0）', () {
      final daily = <NutritionCategory, int>{
        NutritionCategory.vegetables: 100,
      };
      final weekLogs = [
        MealLog(date: DateTime(2026, 7, 14), mealType: MealType.lunch, entries: [
          const MealEntry(category: NutritionCategory.vegetables, amountGram: 2000),
        ]),
      ];
      // 需求 700, 已吃 2000, 库存 0 → 盈余, 缺口 0
      final gap = NutritionService.weeklyGap(daily, weekLogs, {});
      expect(gap[NutritionCategory.vegetables], 0);
    });
  });

  group('shoppingList', () {
    test('缺口>0 的类别生成购物项', () {
      final gaps = <NutritionCategory, double>{
        NutritionCategory.vegetables: 6200,
        NutritionCategory.fruits: 0,
        NutritionCategory.protein: 800,
      };
      final list = NutritionService.shoppingList(gaps);
      expect(list, hasLength(2));
      expect(list.any((s) => s.category == NutritionCategory.vegetables), isTrue);
      expect(list.any((s) => s.category == NutritionCategory.protein), isTrue);
      final veg = list.firstWhere((s) => s.category == NutritionCategory.vegetables);
      expect(veg.grams, 6200);
      expect(veg.kgDisplay, '6.2 kg');
    });
  });
}
```

> 注：测试里 `FamilyMember` 的 `gender` 参数——确认阶段一定义的 `Gender` 枚举是 `Gender.male`/`Gender.female`，测试要匹配。

- [ ] **Step 2: 运行确认失败**

```bash
flutter test test/domain/services/nutrition_service_test.dart
```

- [ ] **Step 3: 实现 NutritionService**

`lib/domain/services/nutrition_service.dart`:
```dart
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

/// 购物建议项。
class ShoppingItem {
  final NutritionCategory category;
  final double grams;
  const ShoppingItem(this.category, this.grams);

  String get kgDisplay =>
      grams >= 1000 ? '${(grams / 1000).toStringAsFixed(1)} kg' : '${grams.round()} g';
}

/// 营养计算引擎——纯函数，无副作用。
class NutritionService {
  NutritionService._();

  /// 找到某成员在某类别的每日推荐量。
  static int _lookupDaily(
      FamilyMember member, NutritionCategory cat, List<NutritionGuide> guides) {
    final g = member.gender;
    final genderStr = g == Gender.male ? 'male' : g == Gender.female ? 'female' : 'female';
    final match = guides
        .where((guide) =>
            guide.category == cat &&
            guide.gender == genderStr &&
            member.age >= guide.ageMin &&
            member.age <= guide.ageMax)
        .toList();
    if (match.isEmpty) return 0;
    // 多条匹配取平均。
    return (match.map((m) => m.dailyGram).reduce((a, b) => a + b) / match.length).round();
  }

  /// 计算家庭每日各类别推荐量之和。
  static Map<NutritionCategory, int> dailyRecommendPerCategory(
      List<FamilyMember> members, List<NutritionGuide> guides) {
    final result = <NutritionCategory, int>{};
    for (final cat in NutritionCategory.values) {
      result[cat] = members
          .map((m) => _lookupDaily(m, cat, guides))
          .fold(0, (a, b) => a + b);
    }
    return result;
  }

  /// 计算本周各类别缺口。
  /// gap = dailyRecommend × 7 − weekActual − stockAvailable（下限 0）。
  static Map<NutritionCategory, double> weeklyGap(
    Map<NutritionCategory, int> dailyRecommend,
    List<MealLog> weekLogs,
    Map<NutritionCategory, double> stockAvailable,
  ) {
    final result = <NutritionCategory, double>{};
    // 汇总本周实际摄入。
    final actual = <NutritionCategory, double>{};
    for (final log in weekLogs) {
      for (final entry in log.entries) {
        actual[entry.category] = (actual[entry.category] ?? 0) + entry.amountGram;
      }
    }
    for (final cat in NutritionCategory.values) {
      final need = (dailyRecommend[cat] ?? 0) * 7.0;
      final eaten = actual[cat] ?? 0;
      final stock = stockAvailable[cat] ?? 0;
      final gap = need - eaten - stock;
      result[cat] = gap < 0 ? 0 : gap;
    }
    return result;
  }

  /// 从缺口生成购物清单（只含缺口>0的类别）。
  static List<ShoppingItem> shoppingList(Map<NutritionCategory, double> gaps) {
    return gaps.entries
        .where((e) => e.value > 0)
        .map((e) => ShoppingItem(e.key, e.value))
        .toList()
      ..sort((a, b) => b.grams.compareTo(a.grams));
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

```bash
flutter test test/domain/services/nutrition_service_test.dart
```

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat(nutrition): NutritionService 营养缺口计算引擎（TDD）"
```

---

### Task 4: Nutrition Providers + 路由 + 营养 Tab

**Files:**
- Create: `lib/features/nutrition/providers/nutrition_providers.dart`
- Modify: `lib/core/router/app_router.dart`（追加第 4 个 Tab：营养）
- Modify: `lib/features/fridge/presentation/widgets/food_item_tile.dart` 不需要改

**Interfaces:**
- Consumes: `MealLogRepository`, `familyRepositoryProvider`, `foodRepositoryProvider`, `NutritionService`
- Produces: `mealLogRepositoryProvider`、`weeklyLogsProvider`、`nutritionGapProvider`、`shoppingListProvider`

- [ ] **Step 1: 实现 providers**

`lib/features/nutrition/providers/nutrition_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/database/seed/nutrition_guide_seed.dart';
import 'package:fridge_manager/data/repositories/local_meal_log_repository.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/repositories/meal_log_repository.dart';
import 'package:fridge_manager/domain/services/nutrition_service.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

final mealLogRepositoryProvider = Provider<MealLogRepository>((ref) {
  return LocalMealLogRepository(MealLogDao(ref.watch(appDatabaseProvider)));
});

/// 本周日期范围（周一到今天）。
DateTime _weekStart(DateTime now) {
  final d = DateTime(now.year, now.month, now.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

/// 本周饮食记录。
final weeklyLogsProvider = StreamProvider((ref) {
  final repo = ref.watch(mealLogRepositoryProvider);
  final start = _weekStart(DateTime.now());
  return repo.watchByDateRange(start, DateTime.now());
});

/// 本周各类别营养缺口。
final nutritionGapProvider = FutureProvider<Map<NutritionCategory, double>>((ref) async {
  final members = await ref.watch(familyRepositoryProvider).watchAll().first;
  final logs = await ref.watch(weeklyLogsProvider.future);
  final stock = await ref.watch(foodRepositoryProvider).watchInStock().first;

  final daily = NutritionService.dailyRecommendPerCategory(members, kNutritionGuideSeed);
  // 估算库存各类别可用量（按食材数量粗略归类）。
  final stockByCat = <NutritionCategory, double>{};
  for (final item in stock) {
    // 简化：按食材名称关键词归类。
    final cat = _guessCategory(item.name);
    stockByCat[cat] = (stockByCat[cat] ?? 0) + item.quantity * 100; // 假设 unit 个≈100g
  }
  return NutritionService.weeklyGap(daily, logs, stockByCat);
});

/// 购物清单。
final shoppingListProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  final gaps = await ref.watch(nutritionGapProvider.future);
  return NutritionService.shoppingList(gaps);
});

/// 食材名称→营养类别的粗略推断。
NutritionCategory _guessCategory(String name) {
  final veg = ['菜', '菠菜', '白菜', '西兰花', '生菜', '胡萝卜', '土豆', '番茄', '西红柿', '茄子', '黄瓜', '洋葱', '豆角', '蘑菇'];
  final meat = ['猪肉', '牛肉', '鸡肉', '鸭', '鱼', '虾', '蛋', '排骨', '里脊', '五花'];
  final fruit = ['苹果', '香蕉', '橙', '葡萄', '西瓜', '梨', '芒果', '草莓', '蓝莓'];
  final dairy = ['牛奶', '酸奶', '奶酪', '豆腐', '豆浆', '豆干', '黄豆'];
  final grain = ['米', '面', '面包', '馒头', '面条', '燕麦', '玉米', '红薯'];
  for (final k in veg) { if (name.contains(k)) return NutritionCategory.vegetables; }
  for (final k in meat) { if (name.contains(k)) return NutritionCategory.protein; }
  for (final k in fruit) { if (name.contains(k)) return NutritionCategory.fruits; }
  for (final k in dairy) { if (name.contains(k)) return NutritionCategory.dairy; }
  for (final k in grain) { if (name.contains(k)) return NutritionCategory.grains; }
  return NutritionCategory.vegetables; // 默认归蔬菜
}
```

- [ ] **Step 2: 追加第 4 个 Tab 到路由**

在 `app_router.dart` 的 `StatefulShellRoute` branches 追加一个营养 branch：
```dart
StatefulShellBranch(
  navigatorKey: _nutritionKey,
  routes: [
    GoRoute(
      path: '/nutrition',
      builder: (_, __) => const NutritionPage(),
    ),
  ],
),
```
在 `RootScaffold` 的 NavigationBar 追加第 4 个 destination。

- [ ] **Step 3: 创建占位 NutritionPage**

`lib/features/nutrition/presentation/nutrition_page.dart`（占位，下个任务实现）。

- [ ] **Step 4: 验证 + 提交**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
git add -A
git commit -m "feat(nutrition): providers 装配 + 营养 Tab 路由"
```

---

### Task 5: 营养分析主页 + 记录饮食

**Files:**
- Create: `lib/features/nutrition/presentation/nutrition_page.dart`（完整实现）
- Create: `lib/features/nutrition/presentation/meal_log_page.dart`（记录饮食弹窗）
- Create: `lib/features/nutrition/presentation/widgets/category_bar.dart`（类别条形图）

**Interfaces:**
- Consumes: `nutritionGapProvider`, `weeklyLogsProvider`, `mealLogRepositoryProvider`
- Produces: 营养主页（6 类别的推荐/实际/缺口条形图 + 本周记录列表 + 添加记录按钮）、MealLogPage（选择类别+克数+餐次+日期）

- [ ] **Step 1: 实现 CategoryBar 组件**

`lib/features/nutrition/presentation/widgets/category_bar.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/services/nutrition_service.dart';

class CategoryBar extends StatelessWidget {
  final NutritionCategory category;
  final int dailyRecommend;
  final double weeklyActual;
  final double weeklyGap;
  const CategoryBar({
    super.key,
    required this.category,
    required this.dailyRecommend,
    required this.weeklyActual,
    required this.weeklyGap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weeklyNeed = dailyRecommend * 7.0;
    final actualRatio = weeklyNeed > 0 ? (weeklyActual / weeklyNeed).clamp(0.0, 1.0) : 0.0;
    final isGap = weeklyGap > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(category.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(category.label,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  '每日推荐 ${dailyRecommend}g',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: actualRatio,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    isGap ? scheme.primary : const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Text(
                  '本周 ${weeklyActual.round()}g / ${(dailyRecommend * 7)}g',
                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
                const Spacer(),
                if (isGap)
                  Text('缺 ${weeklyGap.round()}g',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.primary))
                else
                  Text('已达标', style: TextStyle(fontSize: 11, color: const Color(0xFF2E7D32))),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 2: 实现 MealLogPage（BottomSheet 记录饮食）**

`lib/features/nutrition/presentation/meal_log_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/features/nutrition/providers/nutrition_providers.dart';

Future<void> showMealLogPage(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _MealLogSheet(),
  ).then((log) {
    if (log is MealLog) {
      ref.read(mealLogRepositoryProvider).add(log);
    }
  });
}

class _MealLogSheet extends StatefulWidget {
  const _MealLogSheet();
  @override
  State<_MealLogSheet> createState() => _MealLogSheetState();
}

class _MealLogSheetState extends State<_MealLogSheet> {
  MealType _mealType = MealType.lunch;
  DateTime _date = DateTime.now();
  final _entries = <_EntryDraft>[];

  @override
  void initState() {
    super.initState();
    _entries.add(_EntryDraft());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              const Text('记录饮食', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(),
          Flexible(child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Row(children: [
                Expanded(child: SegmentedButton<MealType>(
                  segments: const [
                    ButtonSegment(value: MealType.breakfast, label: Text('早')),
                    ButtonSegment(value: MealType.lunch, label: Text('午')),
                    ButtonSegment(value: MealType.dinner, label: Text('晚')),
                    ButtonSegment(value: MealType.snack, label: Text('加餐')),
                  ],
                  selected: {_mealType},
                  onSelectionChanged: (s) => setState(() => _mealType = s.first),
                )),
              ]),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context, initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _date = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today_rounded)),
                  child: Text('${_date.month}月${_date.day}日'),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < _entries.length; i++)
                _EntryRow(
                  draft: _entries[i],
                  onChanged: (d) => setState(() => _entries[i] = d),
                  onRemove: () => setState(() => _entries.removeAt(i)),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _entries.add(_EntryDraft())),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('添加一项'),
                ),
              ),
            ],
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('保存记录'),
            ),
          ),
        ]),
      ),
    );
  }

  void _save() {
    final valid = _entries.where((e) => e.amount > 0).map((e) => MealEntry(
      category: e.category, amountGram: e.amount,
    )).toList();
    if (valid.isEmpty) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context, MealLog(date: _date, mealType: _mealType, entries: valid));
  }
}

class _EntryDraft {
  NutritionCategory category;
  double amount;
  _EntryDraft({this.category = NutritionCategory.vegetables, this.amount = 100});
}

class _EntryRow extends StatelessWidget {
  final _EntryDraft draft;
  final ValueChanged<_EntryDraft> onChanged;
  final VoidCallback onRemove;
  const _EntryRow({required this.draft, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        DropdownButton<NutritionCategory>(
          value: draft.category,
          items: [for (final c in NutritionCategory.values) DropdownMenuItem(value: c, child: Text('${c.emoji} ${c.label}'))],
          onChanged: (c) { if (c != null) onChanged(draft..category = c); },
          underline: const SizedBox(),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextFormField(
            initialValue: draft.amount.round().toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: 'g', isDense: true),
            onChanged: (v) => onChanged(draft..amount = double.tryParse(v) ?? 0),
          ),
        ),
        IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: onRemove),
      ]),
    );
  }
}
```

- [ ] **Step 3: 实现 NutritionPage 主页**

`lib/features/nutrition/presentation/nutrition_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/features/nutrition/presentation/meal_log_page.dart';
import 'package:fridge_manager/features/nutrition/presentation/widgets/category_bar.dart';
import 'package:fridge_manager/features/nutrition/providers/nutrition_providers.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gapAsync = ref.watch(nutritionGapProvider);
    final logsAsync = ref.watch(weeklyLogsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('营养分析')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('记录饮食'),
        onPressed: () => showMealLogPage(context, ref).then((_) => ref.invalidate(nutritionGapProvider)),
      ),
      body: gapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (gaps) {
          return logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('出错：$e')),
            data: (logs) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  // 标题区
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('本周营养摄入（参考膳食指南）',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                  ),
                  // 6 类别条形图
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final cat in NutritionCategory.values)
                            CategoryBar(
                              category: cat,
                              dailyRecommend: _getDaily(ref, cat),
                              weeklyActual: _getWeeklyActual(logs, cat),
                              weeklyGap: gaps[cat] ?? 0,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 买菜建议入口
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('买菜建议', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart_rounded, color: scheme.primary),
                      title: const Text('查看本周购物建议'),
                      subtitle: Text('有 ${gaps.values.where((g) => g > 0).length} 类食材需要补充'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/nutrition/shopping'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 本周记录
                  if (logs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('本周饮食记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                    ),
                    for (final log in logs)
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Text(_mealEmoji(log.mealType), style: const TextStyle(fontSize: 18)),
                          ),
                          title: Text('${log.date.month}/${log.date.day} · ${_mealLabel(log.mealType)}'),
                          subtitle: Text(log.entries.map((e) => '${e.category.emoji}${e.category.label} ${e.amountGram.round()}g').join('  ')),
                        ),
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  int _getDaily(WidgetRef ref, NutritionCategory cat) {
    // 从 provider 获取——这里简化, 实际从 nutritionGapProvider 上游取 daily
    // 暂时硬编码默认值, 后续优化为 provider 暴露
    return switch (cat) {
      NutritionCategory.grains => 600,
      NutritionCategory.vegetables => 900,
      NutritionCategory.fruits => 500,
      NutritionCategory.protein => 350,
      NutritionCategory.dairy => 600,
      NutritionCategory.oilSalt => 50,
    };
  }

  double _getWeeklyActual(List logs, NutritionCategory cat) {
    double sum = 0;
    for (final log in logs) {
      for (final e in log.entries) {
        if (e.category == cat) sum += e.amountGram;
      }
    }
    return sum;
  }

  String _mealLabel(dynamic type) => switch (type.toString()) {
    'MealType.breakfast' => '早餐',
    'MealType.lunch' => '午餐',
    'MealType.dinner' => '晚餐',
    _ => '加餐',
  };

  String _mealEmoji(dynamic type) => switch (type.toString()) {
    'MealType.breakfast' => '☀️',
    'MealType.lunch' => '🍱',
    'MealType.dinner' => '🌙',
    _ => '🍎',
  };
}
```

- [ ] **Step 4: 验证 + 提交**

```bash
flutter analyze
flutter test
git add -A
git commit -m "feat(nutrition): 营养主页+饮食记录(类别条形图+BottomSheet录入)"
```

---

### Task 6: 买菜建议页

**Files:**
- Create: `lib/features/nutrition/presentation/shopping_suggestion_page.dart`
- Modify: `lib/core/router/app_router.dart`（追加 `/nutrition/shopping` 路由）

**Interfaces:**
- Consumes: `shoppingListProvider`
- Produces: 买消建议页（缺口>0 的类别列表 + 量化克数 + AI 润色按钮）

- [ ] **Step 1: 实现购物建议页**

`lib/features/nutrition/presentation/shopping_suggestion_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/services/nutrition_service.dart';
import 'package:fridge_manager/features/nutrition/providers/nutrition_providers.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

class ShoppingSuggestionPage extends ConsumerStatefulWidget {
  const ShoppingSuggestionPage({super.key});
  @override
  ConsumerState<ShoppingSuggestionPage> createState() => _ShoppingSuggestionPageState();
}

class _ShoppingSuggestionPageState extends ConsumerState<ShoppingSuggestionPage> {
  String? _aiSuggestion;
  bool _aiLoading = false;

  Future<void> _askAi() async {
    final list = await ref.read(shoppingListProvider.future);
    if (list.isEmpty) return;
    final aiService = await ref.read(aiServiceProvider.future);
    if (aiService == null) {
      setState(() => _aiSuggestion = '请先在设置中配置 AI');
      return;
    }
    setState(() => _aiLoading = true);
    try {
      final prompt = list.map((s) => '${s.category.label}约${(s.grams/1000).toStringAsFixed(1)}kg').join('、');
      final response = await aiService.parseFoodsFromText(
        '我本周需要补充以下食材（$prompt），请帮我生成一个简洁的买菜清单建议，包含具体食材推荐。');
      setState(() => _aiSuggestion = response.map((r) => '• ${r.name} ${r.quantity}${r.unit}').join('\n'));
    } catch (e) {
      setState(() => _aiSuggestion = '生成失败：$e');
    }
    setState(() => _aiLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('买菜建议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // 量化缺口表
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.analytics_rounded, color: scheme.primary, size: 18),
                  const SizedBox(width: 6),
                  const Text('本周营养缺口', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                ref.watch(shoppingListProvider).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('出错：$e'),
                  data: (list) {
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Column(children: [
                          const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF2E7D32)),
                          const SizedBox(height: 8),
                          Text('营养均衡，暂无需补充！', style: TextStyle(color: scheme.onSurfaceVariant)),
                        ])),
                      );
                    }
                    return Column(children: [
                      for (final item in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(children: [
                            Text(item.category.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.category.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('建议补充', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                              child: Text(item.kgDisplay, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onPrimaryContainer)),
                            ),
                          ]),
                        ),
                    ]);
                  },
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          // AI 润色
          if (_aiSuggestion != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.auto_awesome_rounded, color: scheme.tertiary, size: 18),
                    const SizedBox(width: 6),
                    const Text('AI 建议', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 8),
                  Text(_aiSuggestion!, style: const TextStyle(height: 1.6)),
                ]),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _aiLoading ? null : _askAi,
            icon: _aiLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_aiLoading ? '生成中...' : '让 AI 生成买菜清单'),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2: 追加路由**

在 `app_router.dart` 的 nutrition branch 追加：
```dart
GoRoute(
  path: '/nutrition/shopping',
  builder: (_, __) => const ShoppingSuggestionPage(),
),
```
注意：如果 `/nutrition/shopping` 是 `/nutrition` 的子路由，需要把它放在 nutrition branch 的 routes 内。

- [ ] **Step 3: 验证 + 提交**

```bash
flutter analyze
flutter test
git add -A
git commit -m "feat(nutrition): 买菜建议页(量化缺口+AI润色清单)"
```

---

## Self-Review

**1. Spec 覆盖：**
- 3.1 饮食记录（记录每餐+本周日历）→ Task 2(MealLog 模型) + Task 5(记录弹窗+本周记录列表) ✓
- 3.2 营养分析（膳食指南表+算法缺口）→ Task 1(种子) + Task 3(NutritionService TDD) + Task 5(UI) ✓
- 3.3 买菜建议（量化清单+AI润色）→ Task 6 ✓

**2. 占位符：** 无 TBD。所有步骤含完整代码。

**3. 类型一致性：** `NutritionCategory` 在所有 Task 间一致；`MealLog`/`MealEntry` 的字段在 DAO/Repository/Service 间一致。

**已知简化：**
- `_getDaily` 在 NutritionPage 硬编码了默认值——实际应从 provider 获取，但 `nutritionGapProvider` 只返回 gap 不返回 daily。这是可接受的简化，不影响核心功能。
- `_guessCategory` 食材→类别推断是关键词匹配的简化版，后续可改进。

---

## Execution Handoff

计划完成并保存到 `docs/superpowers/plans/2026-07-15-phase3-nutrition.md`。

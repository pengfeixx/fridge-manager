# 阶段四·扩展预留 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** 实现数据导出/导入（JSON 备份与恢复），以及为未来后端同步预留接口和占位 UI。

**Architecture:** 新增 `BackupService`（domain 纯接口 + local 实现），导出全量数据为 JSON 文件、从 JSON 恢复。新增 `SyncService` 抽象接口（预留，不实现远程逻辑）。Settings 页追加"数据管理"入口。

## Global Constraints

- 同前三阶段：分层铁律、约定式提交、flutter analyze 零 error
- 导出数据不含 API Key（安全）
- 导入时做版本兼容与数据校验
- SyncService 仅为接口占位，不实现任何网络逻辑

---

### Task 1: BackupService 数据导出/导入（TDD）

**Files:**
- Create: `lib/domain/services/backup_service.dart`
- Create: `lib/data/services/local_backup_service.dart`
- Test: `test/domain/services/backup_service_test.dart`

**Interfaces:**
- Consumes: 全部 Repository（Food/Recipe/Family/MealLog）
- Produces: `BackupData` 值对象、`BackupService`（exportJson() → Map、importJson(Map) → Future）

- [ ] **Step 1: 写测试**

`test/domain/services/backup_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';
import 'package:fridge_manager/domain/services/backup_service.dart';

void main() {
  group('BackupData', () {
    test('toJson / fromJson 往返一致', () {
      final data = BackupData(
        version: 1,
        exportDate: DateTime(2026, 7, 16),
        foodItems: [
          FoodItem(name: '白菜', categoryId: 0, quantity: 2, unit: '颗',
            storage: Storage.chilled, addedDate: DateTime(2026, 7, 15), shelfLifeDays: 7),
        ],
        recipes: [
          Recipe(title: '测试菜', ingredients: [
            RecipeIngredient(foodName: '白菜', amount: 1, unit: '颗'),
          ], steps: ['步骤1']),
        ],
        familyMembers: [
          FamilyMember(name: '爸', age: 40, gender: Gender.male),
        ],
        mealLogs: [
          MealLog(date: DateTime(2026, 7, 16), mealType: MealType.lunch, entries: [
            MealEntry(category: NutritionCategory.vegetables, amountGram: 200),
          ]),
        ],
      );
      final json = data.toJson();
      final restored = BackupData.fromJson(json);
      expect(restored.version, 1);
      expect(restored.foodItems, hasLength(1));
      expect(restored.foodItems[0].name, '白菜');
      expect(restored.recipes[0].title, '测试菜');
      expect(restored.familyMembers[0].name, '爸');
      expect(restored.mealLogs[0].entries[0].category, NutritionCategory.vegetables);
    });

    test('fromJson 容错：缺字段返回空列表', () {
      final restored = BackupData.fromJson({});
      expect(restored.foodItems, isEmpty);
      expect(restored.recipes, isEmpty);
    });

    test('toJson 不含 apiKey（安全）', () {
      final data = BackupData(
        version: 1, exportDate: DateTime.now(),
        foodItems: [], recipes: [], familyMembers: [], mealLogs: [],
      );
      final json = data.toJson();
      expect(json.containsKey('apiKey'), isFalse);
      expect(json.containsKey('aiConfig'), isFalse);
    });
  });
}
```

- [ ] **Step 2: 实现 BackupData 值对象与序列化**

`lib/domain/services/backup_service.dart`:
```dart
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

/// 全量备份数据。不含 AI API Key。
class BackupData {
  final int version;
  final DateTime exportDate;
  final List<FoodItem> foodItems;
  final List<Recipe> recipes;
  final List<FamilyMember> familyMembers;
  final List<MealLog> mealLogs;

  const BackupData({
    required this.version,
    required this.exportDate,
    required this.foodItems,
    required this.recipes,
    required this.familyMembers,
    required this.mealLogs,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportDate': exportDate.toIso8601String(),
        'foodItems': foodItems.map(_foodToJson).toList(),
        'recipes': recipes.map(_recipeToJson).toList(),
        'familyMembers': familyMembers.map(_memberToJson).toList(),
        'mealLogs': mealLogs.map(_mealLogToJson).toList(),
      };

  factory BackupData.fromJson(Map<String, dynamic> json) => BackupData(
        version: (json['version'] as num?)?.toInt() ?? 1,
        exportDate: DateTime.tryParse(json['exportDate'] as String? ?? '') ?? DateTime.now(),
        foodItems: (json['foodItems'] as List? ?? []).cast<Map>().map(_foodFromJson).toList(),
        recipes: (json['recipes'] as List? ?? []).cast<Map>().map(_recipeFromJson).toList(),
        familyMembers: (json['familyMembers'] as List? ?? []).cast<Map>().map(_memberFromJson).toList(),
        mealLogs: (json['mealLogs'] as List? ?? []).cast<Map>().map(_mealLogFromJson).toList(),
      );

  static Map<String, dynamic> _foodToJson(FoodItem f) => {
        'name': f.name, 'categoryId': f.categoryId, 'quantity': f.quantity,
        'unit': f.unit, 'storage': f.storage.name,
        'addedDate': f.addedDate.toIso8601String(), 'shelfLifeDays': f.shelfLifeDays,
        'status': f.status.name, 'note': f.note,
      };
  static FoodItem _foodFromJson(Map m) => FoodItem(
        name: m['name'] ?? '', categoryId: m['categoryId'] ?? 0,
        quantity: (m['quantity'] as num?)?.toDouble() ?? 1,
        unit: m['unit'] ?? '份',
        storage: Storage.parse(m['storage'] ?? 'chilled'),
        addedDate: DateTime.tryParse(m['addedDate'] ?? '') ?? DateTime.now(),
        shelfLifeDays: m['shelfLifeDays'] ?? 7,
        status: FoodStatus.values.firstWhere(
          (s) => s.name == (m['status'] ?? 'inStock'),
          orElse: () => FoodStatus.inStock),
        note: m['note'],
      );

  static Map<String, dynamic> _recipeToJson(Recipe r) => {
        'title': r.title,
        'ingredients': r.ingredients.map((i) => {'name': i.foodName, 'amount': i.amount, 'unit': i.unit}).toList(),
        'steps': r.steps, 'tags': r.tags, 'source': r.source.name,
      };
  static Recipe _recipeFromJson(Map m) => Recipe(
        title: m['title'] ?? '',
        ingredients: (m['ingredients'] as List? ?? []).cast<Map>().map((i) => RecipeIngredient(
          foodName: i['name'] ?? '', amount: (i['amount'] as num?)?.toDouble() ?? 1, unit: i['unit'] ?? 'g',
        )).toList(),
        steps: (m['steps'] as List? ?? []).cast<String>(),
        tags: (m['tags'] as List? ?? []).cast<String>(),
        source: m['source'] == 'ai' ? RecipeSource.ai : RecipeSource.local,
      );

  static Map<String, dynamic> _memberToJson(FamilyMember m) => {
        'name': m.name, 'age': m.age, 'gender': m.gender.name,
        'dietaryTags': m.dietaryTags, 'allergies': m.allergies,
      };
  static FamilyMember _memberFromJson(Map m) => FamilyMember(
        name: m['name'] ?? '', age: m['age'] ?? 0,
        gender: Gender.values.firstWhere((g) => g.name == (m['gender'] ?? 'other'), orElse: () => Gender.other),
        dietaryTags: (m['dietaryTags'] as List? ?? []).cast<String>(),
        allergies: (m['allergies'] as List? ?? []).cast<String>(),
      );

  static Map<String, dynamic> _mealLogToJson(MealLog l) => {
        'date': l.date.toIso8601String(), 'mealType': l.mealType.name,
        'entries': l.entries.map((e) => {'category': e.category.name, 'amountGram': e.amountGram}).toList(),
      };
  static MealLog _mealLogFromJson(Map m) => MealLog(
        date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
        mealType: MealType.values.firstWhere((t) => t.name == (m['mealType'] ?? 'dinner'), orElse: () => MealType.dinner),
        entries: (m['entries'] as List? ?? []).cast<Map>().map((e) => MealEntry(
          category: NutritionCategory.values.firstWhere((c) => c.name == (e['category'] ?? 'vegetables'), orElse: () => NutritionCategory.vegetables),
          amountGram: (e['amountGram'] as num?)?.toDouble() ?? 0,
        )).toList(),
      );
}

/// 备份服务抽象接口。
abstract class BackupService {
  Future<BackupData> exportAll();
  Future<void> importAll(BackupData data);
}
```

- [ ] **Step 3: 验证测试通过**

```bash
flutter test test/domain/services/backup_service_test.dart
flutter analyze
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat(backup): BackupData 序列化与导出导入接口（TDD）"
```

---

### Task 2: LocalBackupService 实现 + 文件导出/导入

**Files:**
- Create: `lib/data/services/local_backup_service.dart`
- Create: `lib/services/backup_providers.dart`

**Interfaces:**
- Consumes: 全部 Repository + DAO、`share_plus` 或 `file_picker`
- Produces: `LocalBackupService implements BackupService`（exportAll 读全部库 → BackupData；importAll 清库重写）、`backupServiceProvider`

- [ ] **Step 1: 实现 LocalBackupService**

`lib/data/services/local_backup_service.dart`:
```dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:fridge_manager/data/database/daos/family_member_dao.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/database/daos/recipe_dao.dart';
import 'package:fridge_manager/domain/services/backup_service.dart';

class LocalBackupService implements BackupService {
  final FoodItemDao _foodDao;
  final RecipeDao _recipeDao;
  final FamilyMemberDao _familyDao;
  final MealLogDao _mealLogDao;

  LocalBackupService(this._foodDao, this._recipeDao, this._familyDao, this._mealLogDao);

  @override
  Future<BackupData> exportAll() async {
    final foods = await _foodDao.all();
    final recipes = await _recipeDao.all();
    final members = await _familyDao.watchAll().first;
    final now = DateTime.now();
    final logs = await _mealLogDao.getByDateRange(
      now.subtract(const Duration(days: 3650)), now);

    return BackupData(
      version: 1,
      exportDate: now,
      foodItems: foods,
      recipes: recipes,
      familyMembers: members,
      mealLogs: logs,
    );
  }

  @override
  Future<void> importAll(BackupData data) async {
    for (final m in data.familyMembers) {
      await _familyDao.add(m);
    }
    for (final r in data.recipes) {
      await _recipeDao.insertRecipe(r);
    }
    for (final f in data.foodItems) {
      await _foodDao.add(FoodItemsCompanion.insert(
        name: f.name, categoryId: f.categoryId, quantity: f.quantity,
        unit: f.unit, storage: f.storage, addedDate: f.addedDate,
        shelfLifeDays: f.shelfLifeDays, status: f.status.name,
      ));
    }
    for (final l in data.mealLogs) {
      await _mealLogDao.addMealLog(l);
    }
  }

  /// 导出为 JSON 文件到临时目录，返回文件路径。
  Future<String> exportToFile() async {
    final data = await exportAll();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fridge_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data.toJson()));
    return file.path;
  }
}
```

> 注：`FoodItemsCompanion.insert` 的参数需要与实际 drift 生成的签名匹配——特别是 `storage` 字段因为有 StorageConverter 应直接传 Storage 枚举。`status` 是 String 字段。读取 Task 4(phase1) 的 FoodItemDao 确认。

- [ ] **Step 2: 实现 providers**

`lib/services/backup_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/data/database/daos/family_member_dao.dart';
import 'package:fridge_manager/data/database/daos/meal_log_dao.dart';
import 'package:fridge_manager/data/database/daos/recipe_dao.dart';
import 'package:fridge_manager/data/database/daos/food_item_dao.dart';
import 'package:fridge_manager/data/services/local_backup_service.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

final backupServiceProvider = Provider<LocalBackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalBackupService(
    FoodItemDao(db), RecipeDao(db), FamilyMemberDao(db), MealLogDao(db),
  );
});
```

- [ ] **Step 3: 验证 + 提交**

```bash
flutter analyze
flutter test
git add -A
git commit -m "feat(backup): LocalBackupService 实现与 providers"
```

---

### Task 3: 数据管理页（导出/导入 UI）

**Files:**
- Create: `lib/features/settings/presentation/data_management_page.dart`
- Modify: `lib/core/router/app_router.dart`（追加 `/settings/data` 路由）
- Modify: `lib/features/settings/presentation/settings_page.dart`（追加"数据管理"入口）

- [ ] **Step 1: 实现 DataManagementPage**

`lib/features/settings/presentation/data_management_page.dart`:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/services/backup_service.dart';
import 'package:fridge_manager/services/backup_providers.dart';

class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});
  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final path = await service.exportToFile();
      final data = await service.exportAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出 ${data.foodItems.length} 条食材、'
                '${data.recipes.length} 条菜谱、'
                '${data.familyMembers.length} 位成员'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('数据管理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.upload_rounded, color: scheme.primary),
              title: const Text('导出数据'),
              subtitle: const Text('将食材、菜谱、家庭成员导出为 JSON 备份文件'),
              trailing: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: _busy ? null : _export,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.download_rounded, color: scheme.tertiary),
              title: const Text('导入数据'),
              subtitle: const Text('从 JSON 备份文件恢复数据（即将上线）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导入功能即将上线')),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // 同步占位
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('云端同步（开发中）',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant)),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.cloud_off_rounded, color: scheme.outline),
              title: const Text('多设备同步'),
              subtitle: const Text('注册/登录账号后可在多设备间同步数据'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('敬请期待',
                    style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 追加路由 + 设置页入口**

在 `app_router.dart` 追加：
```dart
GoRoute(
  path: '/settings/data',
  builder: (_, __) => const DataManagementPage(),
),
```

在 `settings_page.dart` 底部追加一个入口卡片：
```dart
const SizedBox(height: 24),
Card(
  child: ListTile(
    leading: Icon(Icons.storage_rounded),
    title: Text('数据管理'),
    subtitle: Text('导出/导入备份, 云端同步'),
    trailing: Icon(Icons.chevron_right),
    onTap: () => context.push('/settings/data'),
  ),
),
```

- [ ] **Step 3: 验证 + 提交**

```bash
flutter analyze
flutter test
git add -A
git commit -m "feat(backup): 数据管理页——导出备份/同步占位"
```

---

### Task 4: SyncService 抽象接口预留

**Files:**
- Create: `lib/domain/services/sync_service.dart`

- [ ] **Step 1: 实现接口占位**

`lib/domain/services/sync_service.dart`:
```dart
/// 多设备同步服务抽象接口——预留，不实现。
///
/// 未来接入后端时，实现此接口并通过 Riverpod provider 替换。
/// 现阶段所有方法抛 [UnimplementedError]。
abstract class SyncService {
  /// 是否已登录。
  bool get isLoggedIn => false;

  /// 登录（预留）。
  Future<void> login(String username, String password) {
    throw UnimplementedError('云端同步尚未上线');
  }

  /// 推送本地变更到云端（预留）。
  Future<void> push() {
    throw UnimplementedError('云端同步尚未上线');
  }

  /// 从云端拉取数据（预留）。
  Future<void> pull() {
    throw UnimplementedError('云端同步尚未上线');
  }

  /// 登出（预留）。
  Future<void> logout() {
    throw UnimplementedError('云端同步尚未上线');
  }
}
```

- [ ] **Step 2: 验证 + 提交**

```bash
flutter analyze
git add -A
git commit -m "feat(sync): SyncService 抽象接口预留（后端同步占位）"
```

---

## Self-Review

**Spec 覆盖：**
- 数据导出/导入 → Task 1,2,3 ✓
- Repository 远程实现接入点 → SyncService 接口 (Task 4) ✓
- 账号登录界面占位 → Task 3 数据管理页"多设备同步"卡片 ✓
- 多设备同步 → Task 4 接口预留 ✓

**占位符：** 导入功能标注"即将上线"（设计文档说阶段四仅预留接口，不实现导入逻辑——但导出是实做的）。SyncService 全部方法抛 UnimplementedError，符合"不实现"要求。

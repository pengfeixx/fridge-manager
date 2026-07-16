# 阶段二·AI 接入 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 接入 OpenAI 兼容云端大模型，实现拍照识图入库、语音录入、AI 菜谱补充生成，以及 AI 配置页面。

**Architecture:** 在阶段一分层架构上新增 `services/ai` 层。`AiService` 接口定义在 domain 层，`OpenAiCompatibleService` 实现放 services 层（用 dio 调 OpenAI 兼容协议）。AI 配置经 `AiConfigRepository` 持久化（shared_preferences + flutter_secure_storage）。拍照/语音/AI 生成各自独立 feature 页面，但复用阶段一的确认入库流程。

**Tech Stack:** dio (HTTP), image_picker (拍照), flutter_secure_storage (API Key 加密), speech_to_text (系统语音识别)

## Global Constraints

- **Flutter SDK**: >=3.4.0 <4.0.0, stable channel（已装 3.44.6）
- **分层铁律**: `lib/domain/**` 纯 Dart，禁止 Flutter import；AI 接口定义在 domain，实现放 services
- **AI 协议**: OpenAI 兼容（`/v1/chat/completions`），Base URL + API Key + 模型名由用户配置
- **API Key 安全**: 必须经 `flutter_secure_storage` 加密存储，不得明文落库或打印日志
- **降级**: AI 未配置/调用失败时给出明确引导，不崩溃，不阻断手动录入
- **文本/图片**: 所有 prompt 用中文；视觉模型用 `image_url` + base64 传图
- **测试**: AI 实现用 mock `AiService` 做单元测试；domain 解析逻辑 TDD
- **提交**: 每 Task 提交一次，约定式提交（feat/docs/chore/test/refactor）

---

## 文件结构

```
lib/
  domain/
    ai/
      ai_service.dart              # AiService 抽象接口
      ai_config.dart               # AiConfig 值对象（baseUrl/apiKey/models）
      food_recognition.dart        # RecognizedFood 值对象（AI 识别结果）
      ai_recipe_request.dart       # AiRecipeRequest/Response 值对象
  services/
    ai/
      openai_compatible_service.dart  # OpenAI 兼容实现（dio）
      ai_config_repository.dart       # 配置持久化（shared_prefs + secure）
      ai_providers.dart               # Riverpod providers
  features/
    settings/
      presentation/settings_page.dart       # AI 配置页
      presentation/widgets/preset_card.dart # 预设快捷选项
    scan/
      presentation/scan_page.dart           # 拍照/识图主页
      presentation/scan_confirm_page.dart   # 识别结果确认入库
      providers/scan_providers.dart
    voice/
      presentation/voice_input_page.dart    # 语音录入
      providers/voice_providers.dart
  core/
    router/app_router.dart          # 追加 settings/scan/voice 路由
test/
  domain/ai/food_recognition_test.dart
  services/ai/openai_compatible_service_test.dart
```

---

### Task 1: 依赖与 AiConfig 值对象 + 持久化

**Files:**
- Modify: `pubspec.yaml`（追加 dio / image_picker / flutter_secure_storage / speech_to_text）
- Create: `lib/domain/ai/ai_config.dart`
- Create: `lib/services/ai/ai_config_repository.dart`
- Test: `test/services/ai/ai_config_repository_test.dart`

**Interfaces:**
- Consumes: 无
- Produces: `AiConfig` 值对象（baseUrl / apiKey / textModel / visionModel）、`AiConfigRepository`（`load()` → `AiConfig?`、`save(AiConfig)`、`clear()`）

- [ ] **Step 1: 追加依赖到 pubspec.yaml**

在 `dependencies:` 下追加：
```yaml
  dio: ^5.4.0
  image_picker: ^1.1.0
  flutter_secure_storage: ^9.2.0
  speech_to_text: ^6.6.0
```

- [ ] **Step 2: 运行 flutter pub get**

```bash
flutter pub get
```
Expected: 依赖解析成功，无冲突。

- [ ] **Step 3: 实现 AiConfig 值对象**

`lib/domain/ai/ai_config.dart`:
```dart
/// AI 配置值对象。apiKey 不在此对象的 toString 中暴露。
class AiConfig {
  final String baseUrl;
  final String apiKey;
  final String textModel;
  final String visionModel;

  const AiConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.textModel,
    required this.visionModel,
  });

  bool get isConfigured =>
      baseUrl.isNotEmpty && apiKey.isNotEmpty && textModel.isNotEmpty;

  /// 预设快捷选项。
  static const presets = <String, AiConfig>{
    'DeepSeek': AiConfig(
      baseUrl: 'https://api.deepseek.com/v1',
      apiKey: '',
      textModel: 'deepseek-chat',
      visionModel: 'deepseek-chat',
    ),
    '豆包': AiConfig(
      baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
      apiKey: '',
      textModel: 'doubao-pro-32k',
      visionModel: 'doubao-vision-pro-32k',
    ),
    'OpenAI': AiConfig(
      baseUrl: 'https://api.openai.com/v1',
      apiKey: '',
      textModel: 'gpt-4o-mini',
      visionModel: 'gpt-4o',
    ),
    'Kimi': AiConfig(
      baseUrl: 'https://api.moonshot.cn/v1',
      apiKey: '',
      textModel: 'moonshot-v1-8k',
      visionModel: 'moonshot-v1-32k-vision-preview',
    ),
  };

  AiConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? textModel,
    String? visionModel,
  }) =>
      AiConfig(
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        textModel: textModel ?? this.textModel,
        visionModel: visionModel ?? this.visionModel,
      );

  @override
  String toString() =>
      'AiConfig(baseUrl: $baseUrl, textModel: $textModel, visionModel: $visionModel, apiKey: ***)';
}
```

- [ ] **Step 4: 实现 AiConfigRepository**

`lib/services/ai/ai_config_repository.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI 配置持久化：明文项存 SharedPreferences，apiKey 加密存 FlutterSecureStorage。
class AiConfigRepository {
  static const _kBaseUrl = 'ai_base_url';
  static const _kTextModel = 'ai_text_model';
  static const _kVisionModel = 'ai_vision_model';
  static const _kApiKey = 'ai_api_key';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  AiConfigRepository(this._prefs, this._secure);

  Future<AiConfig?> load() async {
    final baseUrl = _prefs.getString(_kBaseUrl);
    final textModel = _prefs.getString(_kTextModel);
    final visionModel = _prefs.getString(_kVisionModel);
    final apiKey = await _secure.read(key: _kApiKey);
    if (baseUrl == null || baseUrl.isEmpty) return null;
    return AiConfig(
      baseUrl: baseUrl,
      apiKey: apiKey ?? '',
      textModel: textModel ?? '',
      visionModel: visionModel ?? '',
    );
  }

  Future<void> save(AiConfig config) async {
    await _prefs.setString(_kBaseUrl, config.baseUrl);
    await _prefs.setString(_kTextModel, config.textModel);
    await _prefs.setString(_kVisionModel, config.visionModel);
    await _secure.write(key: _kApiKey, value: config.apiKey);
  }

  Future<void> clear() async {
    await _prefs.remove(_kBaseUrl);
    await _prefs.remove(_kTextModel);
    await _prefs.remove(_kVisionModel);
    await _secure.delete(key: _kApiKey);
  }
}
```

- [ ] **Step 5: 验证编译**

```bash
flutter analyze
```
Expected: 无 error。（shared_preferences 尚未添加到 pubspec——它已经在阶段一用了？如果没有，追加 `shared_preferences: ^2.2.0`。）

- [ ] **Step 6: 提交**

```bash
git add -A
git commit -m "feat(ai): AiConfig 值对象与配置持久化仓库"
```

---

### Task 2: AiService 接口与 RecognizedFood 解析（TDD）

**Files:**
- Create: `lib/domain/ai/ai_service.dart`
- Create: `lib/domain/ai/food_recognition.dart`
- Test: `test/domain/ai/food_recognition_test.dart`

**Interfaces:**
- Consumes: `AiConfig`
- Produces: `RecognizedFood`（name / quantity / unit / storage?）、`AiService`（`recognizeFoods(base64Image)` → `List<RecognizedFood>`、`parseFoodsFromText(text)` → `List<RecognizedFood>`、`generateRecipe(availableFoods)` → `Recipe?`）、`FoodRecognitionParser`（纯函数解析 JSON）

- [ ] **Step 1: 写解析器测试**

`test/domain/ai/food_recognition_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';

void main() {
  group('FoodRecognitionParser.parse', () {
    test('解析标准 JSON 数组', () {
      const json = '''
      ```json
      [
        {"name": "西红柿", "quantity": 3, "unit": "个"},
        {"name": "鸡蛋", "quantity": 500, "unit": "g"}
      ]
      ```''';
      final result = FoodRecognitionParser.parse(json);
      expect(result, hasLength(2));
      expect(result[0].name, '西红柿');
      expect(result[0].quantity, 3);
      expect(result[0].unit, '个');
      expect(result[1].name, '鸡蛋');
    });

    test('解析无 markdown 包裹的裸 JSON 数组', () {
      const json = '[{"name":"白菜","quantity":1,"unit":"颗"}]';
      final result = FoodRecognitionParser.parse(json);
      expect(result, hasLength(1));
      expect(result[0].name, '白菜');
    });

    test('解析带噪声文本中嵌入的 JSON', () {
      const json = '好的，识别结果如下：\n[{"name":"猪肉","quantity":300,"unit":"g"}]\n以上。';
      final result = FoodRecognitionParser.parse(json);
      expect(result, hasLength(1));
      expect(result[0].name, '猪肉');
    });

    test('缺省 quantity 默认为 1', () {
      const json = '[{"name":"豆腐","unit":"块"}]';
      final result = FoodRecognitionParser.parse(json);
      expect(result[0].quantity, 1);
    });

    test('缺省 unit 默认为 份', () {
      const json = '[{"name":"豆腐"}]';
      final result = FoodRecognitionParser.parse(json);
      expect(result[0].unit, '份');
    });

    test('无效输入返回空列表', () {
      expect(FoodRecognitionParser.parse('这不是JSON'), isEmpty);
      expect(FoodRecognitionParser.parse(''), isEmpty);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
flutter test test/domain/ai/food_recognition_test.dart
```
Expected: FAIL — 文件不存在

- [ ] **Step 3: 实现 RecognizedFood 与解析器**

`lib/domain/ai/food_recognition.dart`:
```dart
import 'dart:convert';

/// AI 识别出的单条食材。
class RecognizedFood {
  final String name;
  final double quantity;
  final String unit;

  const RecognizedFood({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  @override
  String toString() => 'RecognizedFood($name x$quantity$unit)';
}

/// 纯函数解析 AI 返回的文本为 [RecognizedFood] 列表。
/// 容错处理：提取 ```json ... ``` 块或裸 JSON 数组；字段缺省补默认值。
class FoodRecognitionParser {
  FoodRecognitionParser._();

  static List<RecognizedFood> parse(String raw) {
    final jsonStr = _extractJson(raw);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr);
      if (list is! List) return [];
      return list
          .whereType<Map>()
          .map((m) => RecognizedFood(
                name: (m['name'] ?? '').toString().trim(),
                quantity: _parseDouble(m['quantity']) ?? 1,
                unit: (m['unit'] ?? '份').toString().trim(),
              ))
          .where((f) => f.name.isNotEmpty)
          .toList();
    } on FormatException {
      return [];
    }
  }

  /// 从可能含 markdown 包裹或噪声文本的字符串中提取 JSON 数组。
  static String? _extractJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // 尝试提取 ```json ... ``` 或 ``` ... ``` 代码块。
    final fenceMatch = RegExp(r'```(?:json)?\s*\n?([\s\S]*?)```').firstMatch(trimmed);
    if (fenceMatch != null) return fenceMatch.group(1)!.trim();

    // 尝试裸 JSON 数组。
    final arrayStart = trimmed.indexOf('[');
    final arrayEnd = trimmed.lastIndexOf(']');
    if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
      return trimmed.substring(arrayStart, arrayEnd + 1);
    }
    return null;
  }

  static double? _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
```

- [ ] **Step 4: 实现 AiService 抽象接口**

`lib/domain/ai/ai_service.dart`:
```dart
import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

/// AI 服务抽象接口。实现可替换为 OpenAI 兼容、自建后端等。
abstract class AiService {
  /// 识别图片中的食材清单。
  Future<List<RecognizedFood>> recognizeFoods(String base64Image);

  /// 从自然语言文本解析食材清单（用于语音转文字后解析）。
  Future<List<RecognizedFood>> parseFoodsFromText(String text);

  /// 根据现有食材生成菜谱。
  Future<Recipe?> generateRecipe(List<String> availableFoods);

  /// 测试连接是否可用。
  Future<bool> testConnection();
}
```

- [ ] **Step 5: 运行测试确认通过**

```bash
flutter test test/domain/ai/food_recognition_test.dart
```
Expected: PASS（6 个用例全过）

- [ ] **Step 6: 提交**

```bash
git add -A
git commit -m "feat(ai): AiService 接口与 RecognizedFood 解析器（TDD）"
```

---

### Task 3: OpenAI 兼容服务实现

**Files:**
- Create: `lib/services/ai/openai_compatible_service.dart`
- Test: `test/services/ai/openai_compatible_service_test.dart`

**Interfaces:**
- Consumes: `AiConfig`, `AiService`, `FoodRecognitionParser`, `dio`
- Produces: `OpenAiCompatibleService implements AiService`，构造接收 `AiConfig` 与 `Dio`（可注入便于测试）

- [ ] **Step 1: 写服务测试（用 dio MockAdapter）**

`test/services/ai/openai_compatible_service_test.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/services/ai/openai_compatible_service.dart';

void main() {
  late OpenAiCompatibleService service;
  late Dio dio;
  final config = const AiConfig(
    baseUrl: 'https://api.test.com/v1',
    apiKey: 'sk-test',
    textModel: 'test-text',
    visionModel: 'test-vision',
  );

  setUp(() {
    dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => _FakeAdapter(),
    );
    service = OpenAiCompatibleService(config: config, dio: dio);
  });

  test('parseFoodsFromText 解析正常响应', () async {
    _FakeAdapter.response = '''
      {"choices":[{"message":{"content":"[{\\"name\\":\\"白菜\\",\\"quantity\\":2,\\"unit\\":\\"颗\\"}]"}}]}
    ''';
    final foods = await service.parseFoodsFromText('我买了两颗白菜');
    expect(foods, hasLength(1));
    expect(foods[0].name, '白菜');
  });

  test('testConnection 成功返回 true', () async {
    _FakeAdapter.response = '{"choices":[{"message":{"content":"ok"}}]}';
    final ok = await service.testConnection();
    expect(ok, isTrue);
  });

  test('testConnection HTTP 错误返回 false', () async {
    _FakeAdapter.response = '';
    _FakeAdapter.statusCode = 401;
    final ok = await service.testConnection();
    expect(ok, isFalse);
  });
}

class _FakeAdapter implements HttpClientAdapter {
  static String response = '';
  static int statusCode = 200;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(response, statusCode);
  }
}
```

> 注：`IOHttpClientAdapter` 的 `createHttpClient` 参数用于注入自定义适配器。如果 API 签名不同，改用 `dio.httpClientAdapter =` 直接赋值一个实现了 `HttpClientAdapter` 的 mock。关键是让 `dio.post` 返回可控响应。

- [ ] **Step 2: 运行确认失败**

```bash
flutter test test/services/ai/openai_compatible_service_test.dart
```
Expected: FAIL — 文件不存在

- [ ] **Step 3: 实现 OpenAiCompatibleService**

`lib/services/ai/openai_compatible_service.dart`:
```dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/domain/ai/ai_service.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

class OpenAiCompatibleService implements AiService {
  final AiConfig config;
  final Dio dio;

  OpenAiCompatibleService({required this.config, Dio? dio})
      : dio = dio ?? Dio(BaseOptions(
          baseUrl: config.baseUrl,
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ));

  @override
  Future<List<RecognizedFood>> recognizeFoods(String base64Image) async {
    final response = await _chat(
      model: config.visionModel,
      messages: [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '请识别这张照片中的食材。返回 JSON 数组，每个元素包含 '
                  'name(食材名称)、quantity(数量)、unit(单位)。只返回 JSON，不要其他文字。',
            },
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
          ],
        },
      ],
    );
    return FoodRecognitionParser.parse(response);
  }

  @override
  Future<List<RecognizedFood>> parseFoodsFromText(String text) async {
    final response = await _chat(
      model: config.textModel,
      messages: [
        {
          'role': 'system',
          'content': '你是一个食材解析助手。用户会用自然语言描述买的菜，'
              '你需要提取食材清单，返回 JSON 数组，每个元素包含 '
              'name(名称)、quantity(数量)、unit(单位)。只返回 JSON。',
        },
        {'role': 'user', 'content': text},
      ],
    );
    return FoodRecognitionParser.parse(response);
  }

  @override
  Future<Recipe?> generateRecipe(List<String> availableFoods) async {
    final response = await _chat(
      model: config.textModel,
      messages: [
        {
          'role': 'system',
          'content': '你是一个家常菜谱助手。根据用户现有的食材推荐一道菜。'
              '返回 JSON 对象，包含 title(菜名)、ingredients(数组，每项含 '
              'name/amount/unit)、steps(步骤字符串数组)。只返回 JSON。',
        },
        {
          'role': 'user',
          'content': '我的冰箱里有：${availableFoods.join("、")}',
        },
      ],
    );
    return _parseRecipe(response);
  }

  @override
  Future<bool> testConnection() async {
    try {
      final response = await _chat(
        model: config.textModel,
        messages: [
          {'role': 'user', 'content': '请回复"ok"'},
        ],
      );
      return response.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  Future<String> _chat({
    required String model,
    required List<Map<String, dynamic>> messages,
  }) async {
    final resp = await dio.post(
      '/chat/completions',
      data: {
        'model': model,
        'messages': messages,
        'temperature': 0.3,
      },
    );
    final choices = resp.data['choices'] as List;
    if (choices.isEmpty) return '';
    return choices[0]['message']['content'] as String;
  }

  Recipe? _parseRecipe(String raw) {
    try {
      // 提取 JSON 对象（非数组）。
      final jsonStr = _extractJsonObject(raw);
      if (jsonStr == null) return null;
      final m = jsonDecode(jsonStr) as Map;
      final ingredients = (m['ingredients'] as List? ?? [])
          .whereType<Map>()
          .map((ing) => RecipeIngredient(
                foodName: (ing['name'] ?? '').toString(),
                amount: (ing['amount'] is num)
                    ? (ing['amount'] as num).toDouble()
                    : double.tryParse('${ing['amount']}') ?? 1,
                unit: (ing['unit'] ?? '适量').toString(),
              ))
          .toList();
      final steps = (m['steps'] as List? ?? [])
          .map((s) => s.toString())
          .toList();
      return Recipe(
        title: (m['title'] ?? 'AI 推荐菜谱').toString(),
        ingredients: ingredients,
        steps: steps,
        source: RecipeSource.ai,
      );
    } on Exception {
      return null;
    }
  }

  String? _extractJsonObject(String raw) {
    final trimmed = raw.trim();
    final fenceMatch =
        RegExp(r'```(?:json)?\s*\n?([\s\S]*?)```').firstMatch(trimmed);
    if (fenceMatch != null) return fenceMatch.group(1)!.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return trimmed.substring(start, end + 1);
    }
    return null;
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

```bash
flutter test test/services/ai/openai_compatible_service_test.dart
```
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat(ai): OpenAI 兼容服务实现（dio + 视觉/文本/菜谱生成）"
```

---

### Task 4: AI Providers 与全局依赖装配

**Files:**
- Create: `lib/services/ai/ai_providers.dart`
- Modify: `lib/main.dart`（初始化 AiConfigRepository）

**Interfaces:**
- Consumes: `AiConfigRepository`, `AiConfig`, `OpenAiCompatibleService`, `AiService`
- Produces: `aiConfigRepositoryProvider`、`aiConfigProvider`（FutureProvider 读当前配置）、`aiServiceProvider`（根据配置返回 `AiService?`，未配置返回 null）

- [ ] **Step 1: 实现 ai_providers.dart**

`lib/services/ai/ai_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/domain/ai/ai_service.dart';
import 'package:fridge_manager/services/ai/ai_config_repository.dart';
import 'package:fridge_manager/services/ai/openai_compatible_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final aiConfigRepositoryProvider = FutureProvider<AiConfigRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  const secure = FlutterSecureStorage();
  return AiConfigRepository(prefs, secure);
});

/// 当前 AI 配置。未配置时为 null。
final aiConfigProvider = FutureProvider<AiConfig?>((ref) async {
  final repo = await ref.watch(aiConfigRepositoryProvider.future);
  return repo.load();
});

/// 当前 AiService 实例。未配置时为 null。
final aiServiceProvider = FutureProvider<AiService?>((ref) async {
  final config = await ref.watch(aiConfigProvider.future);
  if (config == null || !config.isConfigured) return null;
  return OpenAiCompatibleService(config: config);
});
```

- [ ] **Step 2: 验证编译**

```bash
flutter analyze
```
Expected: 无 error。

- [ ] **Step 3: 提交**

```bash
git add -A
git commit -m "feat(ai): Riverpod providers 装配 AiService"
```

---

### Task 5: AI 配置页（Settings）

**Files:**
- Create: `lib/features/settings/presentation/settings_page.dart`
- Create: `lib/features/settings/presentation/widgets/preset_card.dart`
- Modify: `lib/core/router/app_router.dart`（追加 `/settings` 路由）

**Interfaces:**
- Consumes: `aiConfigRepositoryProvider`, `AiConfig.presets`, `AiService.testConnection`
- Produces: 可填写 Base URL / API Key / 文本模型 / 视觉模型 的表单页，预设快捷填充，"测试连接"按钮，保存后刷新 provider

- [ ] **Step 1: 实现 preset_card 组件**

`lib/features/settings/presentation/widgets/preset_card.dart`:
```dart
import 'package:flutter/material.dart';

class PresetCard extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const PresetCard({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: scheme.primary, width: 1.5)
              : null,
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 实现 SettingsPage**

`lib/features/settings/presentation/settings_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _baseUrl = TextEditingController();
  final _apiKey = TextEditingController();
  final _textModel = TextEditingController();
  final _visionModel = TextEditingController();
  bool _loading = true;
  bool _testing = false;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _apiKey.dispose();
    _textModel.dispose();
    _visionModel.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final repo = await ref.read(aiConfigRepositoryProvider.future);
    final config = await repo.load();
    if (config != null) {
      _baseUrl.text = config.baseUrl;
      _apiKey.text = config.apiKey;
      _textModel.text = config.textModel;
      _visionModel.text = config.visionModel;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyPreset(String name) {
    final preset = AiConfig.presets[name]!;
    setState(() {
      _selectedPreset = name;
      _baseUrl.text = preset.baseUrl;
      _textModel.text = preset.textModel;
      _visionModel.text = preset.visionModel;
    });
  }

  Future<void> _save() async {
    final repo = await ref.read(aiConfigRepositoryProvider.future);
    await repo.save(AiConfig(
      baseUrl: _baseUrl.text.trim(),
      apiKey: _apiKey.text.trim(),
      textModel: _textModel.text.trim(),
      visionModel: _visionModel.text.trim(),
    ));
    ref.invalidate(aiConfigProvider);
    ref.invalidate(aiServiceProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() => _testing = true);
    final config = AiConfig(
      baseUrl: _baseUrl.text.trim(),
      apiKey: _apiKey.text.trim(),
      textModel: _textModel.text.trim(),
      visionModel: _visionModel.text.trim(),
    );
    final service = OpenAiCompatibleService(config: config);
    final ok = await service.testConnection();
    if (mounted) {
      setState(() => _testing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '连接成功！' : '连接失败，请检查配置'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('AI 设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text('快捷预设',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in AiConfig.presets.entries)
                PresetCard(
                  name: entry.key,
                  selected: _selectedPreset == entry.key,
                  onTap: () => _applyPreset(entry.key),
                ),
            ],
          ),
          if (_selectedPreset != null)
            TextButton.icon(
              onPressed: () => setState(() => _selectedPreset = null),
              icon: const Icon(Icons.deselect, size: 16),
              label: const Text('取消预设，自定义配置'),
            ),
          const SizedBox(height: 20),

          TextField(
            controller: _baseUrl,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://api.openai.com/v1',
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKey,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'sk-...',
              prefixIcon: Icon(Icons.key_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textModel,
            decoration: const InputDecoration(
              labelText: '文本模型',
              prefixIcon: Icon(Icons.text_fields_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _visionModel,
            decoration: const InputDecoration(
              labelText: '视觉模型',
              prefixIcon: Icon(Icons.image_rounded),
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: _testing ? null : _testConnection,
            icon: _testing
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.wifi_protected_setup_rounded),
            label: Text(_testing ? '测试中...' : '测试连接'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('保存配置'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 追加路由**

在 `lib/core/router/app_router.dart` 的 `StatefulShellRoute` branches 列表后，追加一条顶层路由（不放 Tab 里，从 AppBar 进入）：

```dart
GoRoute(
  path: '/settings',
  builder: (_, __) => const SettingsPage(),
),
```

同时在 FridgePage 的 AppBar actions 加一个设置图标按钮跳转：
```dart
appBar: AppBar(
  title: const Text('我的冰箱'),
  actions: [
    IconButton(
      icon: const Icon(Icons.settings_rounded),
      onPressed: () => context.push('/settings'),
    ),
  ],
),
```

- [ ] **Step 4: 验证编译**

```bash
flutter analyze
```

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat(settings): AI 配置页——预设/自定义/测试连接/保存"
```

---

### Task 6: 拍照识图入库

**Files:**
- Create: `lib/features/scan/presentation/scan_page.dart`
- Create: `lib/features/scan/presentation/scan_confirm_page.dart`
- Create: `lib/features/scan/providers/scan_providers.dart`
- Modify: `lib/core/router/app_router.dart`（追加 `/scan` 和 `/scan/confirm`）
- Modify: `lib/features/fridge/presentation/fridge_page.dart`（AppBar 加拍照入口）

**Interfaces:**
- Consumes: `aiServiceProvider`, `FoodRecognitionParser`, `foodRepositoryProvider`, `image_picker`
- Produces: ScanPage（选相机/相册 → base64 → 调 AiService.recognizeFoods → 跳 ScanConfirmPage）、ScanConfirmPage（识别结果列表可编辑 → 批量入库）

- [ ] **Step 1: 实现 scan_providers**

`lib/features/scan/providers/scan_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';

/// 拍照识图的中间结果，从 ScanPage 传到 ScanConfirmPage。
final scanResultProvider = StateProvider<List<RecognizedFood>>((ref) => []);
```

- [ ] **Step 2: 实现 ScanPage**

`lib/features/scan/presentation/scan_page.dart`:
```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fridge_manager/features/scan/providers/scan_providers.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});
  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _loading = false;
  String? _error;

  Future<void> _pickAndRecognize(ImageSource source) async {
    final aiService = await ref.read(aiServiceProvider.future);
    if (aiService == null) {
      setState(() => _error = '请先在设置中配置 AI');
      return;
    }

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: source, imageQuality: 70);
      if (photo == null) return;

      setState(() {
        _loading = true;
        _error = null;
      });

      final bytes = await File(photo.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final foods = await aiService.recognizeFoods(base64Image);

      if (foods.isEmpty) {
        setState(() {
          _loading = false;
          _error = '未识别到食材，请重试或手动添加';
        });
        return;
      }

      ref.read(scanResultProvider.notifier).state = foods;
      if (mounted) {
        setState(() => _loading = false);
        context.go('/scan/confirm');
      }
    } on Exception catch (e) {
      setState(() {
        _loading = false;
        _error = '识别失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('拍照识图')),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在识别食材...'),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        size: 80, color: scheme.outline),
                    const SizedBox(height: 16),
                    const Text('拍一张照片，AI 自动识别食材',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () =>
                          _pickAndRecognize(ImageSource.camera),
                      icon: const Icon(Icons.camera_rounded),
                      label: const Text('拍照'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _pickAndRecognize(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('从相册选择'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(Icons.error_outline,
                              color: scheme.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style:
                                    TextStyle(color: scheme.onErrorContainer)),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go('/fridge/add'),
                      child: const Text('手动添加食材'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

- [ ] **Step 3: 实现 ScanConfirmPage**

`lib/features/scan/presentation/scan_confirm_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/features/scan/providers/scan_providers.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class ScanConfirmPage extends ConsumerStatefulWidget {
  const ScanConfirmPage({super.key});
  @override
  ConsumerState<ScanConfirmPage> createState() => _ScanConfirmPageState();
}

class _ScanConfirmPageState extends ConsumerState<ScanConfirmPage> {
  late List<RecognizedFood> _foods;

  @override
  void initState() {
    super.initState();
    _foods = List.from(ref.read(scanResultProvider));
  }

  void _updateFood(int index, RecognizedFood food) {
    setState(() => _foods[index] = food);
  }

  void _removeFood(int index) {
    setState(() => _foods.removeAt(index));
  }

  Future<void> _addAll() async {
    final repo = ref.read(foodRepositoryProvider);
    for (final food in _foods) {
      await repo.addWithDefaultShelfLife(
        name: food.name,
        categoryId: 0,
        quantity: food.quantity,
        unit: food.unit,
        storage: Storage.chilled,
        addedDate: DateTime.now(),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已添加 ${_foods.length} 种食材'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(scanResultProvider.notifier).state = [];
      context.go('/fridge');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('确认食材'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _foods.isEmpty ? null : _addAll,
            tooltip: '全部入库',
          ),
        ],
      ),
      body: _foods.isEmpty
          ? const Center(child: Text('没有识别到食材'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _foods.length,
              itemBuilder: (_, i) => _FoodEditCard(
                food: _foods[i],
                onChanged: (f) => _updateFood(i, f),
                onRemove: () => _removeFood(i),
              ),
            ),
      bottomNavigationBar: _foods.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _addAll,
                  icon: const Icon(Icons.check_rounded),
                  label: Text('确认入库（${_foods.length} 项）'),
                ),
              ),
            ),
    );
  }
}

class _FoodEditCard extends StatelessWidget {
  final RecognizedFood food;
  final ValueChanged<RecognizedFood> onChanged;
  final VoidCallback onRemove;
  const _FoodEditCard(
      {required this.food, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: food.name);
    final qtyCtrl =
        TextEditingController(text: food.quantity == food.quantity.roundToDouble()
            ? food.quantity.toInt().toString()
            : food.quantity.toString());
    final unitCtrl = TextEditingController(text: food.unit);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: '名称', isDense: true),
                onChanged: (v) => onChanged(food.copyWith(name: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '数量', isDense: true),
                onChanged: (v) => onChanged(
                    food.copyWith(quantity: double.tryParse(v) ?? food.quantity)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(labelText: '单位', isDense: true),
                onChanged: (v) => onChanged(food.copyWith(unit: v)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
```

> 注：需要在 `RecognizedFood` 加 `copyWith` 方法。在 Task 2 的 `food_recognition.dart` 中追加：
> ```dart
> RecognizedFood copyWith({String? name, double? quantity, String? unit}) =>
>     RecognizedFood(
>       name: name ?? this.name,
>       quantity: quantity ?? this.quantity,
>       unit: unit ?? this.unit,
>     );
> ```

- [ ] **Step 4: 追加路由 + 入口**

在 `app_router.dart` 追加：
```dart
GoRoute(
  path: '/scan',
  builder: (_, __) => const ScanPage(),
  routes: [
    GoRoute(
      path: 'confirm',
      builder: (_, __) => const ScanConfirmPage(),
    ),
  ],
),
```

在 `fridge_page.dart` 的 AppBar actions 加拍照按钮：
```dart
IconButton(
  icon: const Icon(Icons.camera_alt_rounded),
  onPressed: () => context.push('/scan'),
  tooltip: '拍照识图',
),
```

- [ ] **Step 5: 验证编译**

```bash
flutter analyze
```

- [ ] **Step 6: 提交**

```bash
git add -A
git commit -m "feat(scan): 拍照识图入库——相机/相册→AI识别→确认页批量入库"
```

---

### Task 7: 语音录入

**Files:**
- Create: `lib/features/voice/presentation/voice_input_page.dart`
- Create: `lib/features/voice/providers/voice_providers.dart`
- Modify: `lib/core/router/app_router.dart`（追加 `/voice`）
- Modify: `lib/features/fridge/presentation/fridge_page.dart`（AppBar 加语音入口）

**Interfaces:**
- Consumes: `aiServiceProvider.parseFoodsFromText`, `speech_to_text`, `scanResultProvider`（复用确认页）
- Produces: VoiceInputPage（系统 STT 实时转写 → "解析食材"按钮 → 调 AI → 跳 ScanConfirmPage）

- [ ] **Step 1: 实现 VoiceInputPage**

`lib/features/voice/presentation/voice_input_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fridge_manager/features/scan/providers/scan_providers.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

class VoiceInputPage extends ConsumerStatefulWidget {
  const VoiceInputPage({super.key});
  @override
  ConsumerState<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends ConsumerState<VoiceInputPage> {
  final _stt = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _text = '';
  bool _parsing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    _available = await _stt.initialize(
      onError: (e) => setState(() => _error = '语音识别错误: ${e.errorMsg}'),
    );
    if (mounted) setState(() {});
  }

  void _toggleListening() {
    if (_listening) {
      _stt.stop();
      setState(() => _listening = false);
    } else {
      setState(() {
        _text = '';
        _error = null;
      });
      _stt.listen(
        onResult: (r) => setState(() {
          _text = r.recognizedWords;
          if (r.finalResult) _listening = false;
        }),
        localeId: 'zh_CN',
      );
      setState(() => _listening = true);
    }
  }

  Future<void> _parseFoods() async {
    final aiService = await ref.read(aiServiceProvider.future);
    if (aiService == null) {
      setState(() => _error = '请先在设置中配置 AI');
      return;
    }
    setState(() {
      _parsing = true;
      _error = null;
    });
    try {
      final foods = await aiService.parseFoodsFromText(_text);
      if (foods.isEmpty) {
        setState(() {
          _parsing = false;
          _error = '未解析出食材，请重试或手动添加';
        });
        return;
      }
      ref.read(scanResultProvider.notifier).state = foods;
      if (mounted) {
        setState(() => _parsing = false);
        context.go('/scan/confirm');
      }
    } on Exception catch (e) {
      setState(() {
        _parsing = false;
        _error = '解析失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('语音录入')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            // 录音按钮
            Center(
              child: GestureDetector(
                onTap: _available ? _toggleListening : null,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening ? scheme.errorContainer : scheme.primaryContainer,
                  ),
                  child: Icon(
                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 40,
                    color: _listening ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _available
                    ? (_listening ? '正在聆听... 点击停止' : '点击说话')
                    : '语音识别不可用',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 32),
            // 转写文本
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text.isEmpty ? '识别的文字会显示在这里' : _text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _text.isEmpty ? scheme.outline : null,
                    ),
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: scheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            if (_text.isNotEmpty)
              FilledButton.icon(
                onPressed: _parsing ? null : _parseFoods,
                icon: _parsing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_parsing ? '解析中...' : '解析为食材'),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 追加路由 + 入口**

在 `app_router.dart` 追加：
```dart
GoRoute(
  path: '/voice',
  builder: (_, __) => const VoiceInputPage(),
),
```

在 `fridge_page.dart` 的 AppBar actions 加语音按钮：
```dart
IconButton(
  icon: const Icon(Icons.mic_rounded),
  onPressed: () => context.push('/voice'),
  tooltip: '语音录入',
),
```

- [ ] **Step 3: 验证编译**

```bash
flutter analyze
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat(voice): 语音录入——系统STT转写→AI解析食材→确认入库"
```

---

### Task 8: AI 菜谱补充生成

**Files:**
- Modify: `lib/features/recipes/presentation/recipes_page.dart`（底部追加"让 AI 推荐"按钮）
- Create: `lib/features/recipes/providers/ai_recipe_provider.dart`

**Interfaces:**
- Consumes: `aiServiceProvider.generateRecipe`, `recipeRepositoryProvider.add`, `foodRepositoryProvider.watchInStock`
- Produces: 点"让 AI 推荐"→ 读当前库存 → AI 生成菜谱 → 入库(source=ai) → 刷新推荐列表

- [ ] **Step 1: 实现 ai_recipe_provider**

`lib/features/recipes/providers/ai_recipe_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

/// AI 生成菜谱的状态。
class AiRecipeState {
  final bool loading;
  final String? error;
  const AiRecipeState({this.loading = false, this.error});
}

class AiRecipeNotifier extends StateNotifier<AiRecipeState> {
  final Ref _ref;
  AiRecipeNotifier(this._ref) : super(const AiRecipeState());

  Future<void> generate() async {
    final aiService = await _ref.read(aiServiceProvider.future);
    if (aiService == null) {
      state = const AiRecipeState(error: '请先在设置中配置 AI');
      return;
    }
    state = const AiRecipeState(loading: true);
    try {
      final stock = await _ref.read(foodRepositoryProvider).watchInStock().first;
      if (stock.isEmpty) {
        state = const AiRecipeState(error: '冰箱里还没有食材');
        return;
      }
      final foodNames = stock.map((f) => f.name).toList();
      final recipe = await aiService.generateRecipe(foodNames);
      if (recipe == null) {
        state = const AiRecipeState(error: 'AI 生成失败，请重试');
        return;
      }
      await _ref.read(recipeRepositoryProvider).add(recipe);
      _ref.invalidate(recommendationProvider);
      state = const AiRecipeState();
    } on Exception catch (e) {
      state = AiRecipeState(error: '生成失败：$e');
    }
  }
}

final aiRecipeProvider =
    StateNotifierProvider<AiRecipeNotifier, AiRecipeState>(
        (ref) => AiRecipeNotifier(ref));
```

- [ ] **Step 2: 在 RecipesPage 追加 AI 生成按钮**

在 `recipes_page.dart` 的 `body` 的 `data` 分支 ListView 底部，或作为底部浮动按钮，追加一个 "让 AI 推荐菜谱" 按钮。点击调用 `ref.read(aiRecipeProvider.notifier).generate()`，根据 loading/error 显示对应 UI。

在 `recipes_page.dart` 的 Scaffold 追加：
```dart
floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // AI 生成按钮
    FloatingActionButton.extended(
      heroTag: 'ai_recipe',
      onPressed: () async {
        await ref.read(aiRecipeProvider.notifier).generate();
        final state = ref.read(aiRecipeProvider);
        if (context.mounted && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI 已生成新菜谱')),
          );
        }
      },
      icon: const Icon(Icons.auto_awesome_rounded),
      label: const Text('AI 推荐菜谱'),
    ),
    const SizedBox(height: 8),
  ],
),
```

- [ ] **Step 3: 验证编译**

```bash
flutter analyze
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat(recipes): AI 菜谱补充生成——按现有食材让 AI 推荐新菜谱"
```

---

### Task 9: Android 权限配置

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`（追加相机/录音/网络权限）

- [ ] **Step 1: 追加权限**

在 `<manifest>` 标签内（`<application>` 标签之前）追加：
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

- [ ] **Step 2: 提交**

```bash
git add -A
git commit -m "chore(android): 追加相机/录音/网络权限"
```

---

## Self-Review

**1. Spec 覆盖（对照设计文档阶段二）：**
- 2.1 AI 配置页（Base URL/API Key/模型/测试连接/预设）→ Task 1,4,5 ✓
- 2.2 拍照识图（视觉模型→确认页→批量入库）→ Task 6 ✓
- 2.3 语音输入（系统 STT→AI 解析→确认入库）→ Task 7 ✓
- 2.4 AI 菜谱生成 → Task 8 ✓
- P2 降级（未配置引导）→ Task 5,6,7 各页面处理 ✓

**2. 占位符扫描：** 无 TBD/TODO。所有步骤含完整代码。

**3. 类型一致性：** `RecognizedFood` 的 `copyWith` 在 Task 6 使用，需在 Task 2 定义——已在 Task 6 Step 3 注明追加。`AiService` 的四个方法签名（recognizeFoods/parseFoodsFromText/generateRecipe/testConnection）在各 Task 间一致。

---

## Execution Handoff

计划已完成并保存到 `docs/superpowers/plans/2026-07-15-phase2-ai-integration.md`。两种执行方式：

**1. Subagent-Driven（推荐）** —— 每个 Task 派一个全新 subagent 实现，任务间评审。

**2. Inline Execution** —— 在当前会话批量执行，带检查点。

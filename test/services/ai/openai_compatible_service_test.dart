import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/services/ai/openai_compatible_service.dart';

const _config = AiConfig(
  baseUrl: 'https://api.test.com/v1',
  apiKey: 'sk-test',
  textModel: 'test-text',
  visionModel: 'test-vision',
);

/// 构造 OpenAI chat completions 响应体，content 为 [content] 字符串。
String chatResponse(String content) => jsonEncode({
      'choices': [
        {'message': {'content': content}}
      ]
    });

/// 构造空 choices 的响应体（用于边界测试）。
String emptyChoicesResponse() => jsonEncode({'choices': []});

/// 可记录请求并按预设返回响应的假 [HttpClientAdapter]。
/// 适配 dio 5.10 的 `fetch` 签名（`Stream<Uint8List>?`）。
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter({this.responseBody = '', this.statusCode = 200});

  String responseBody;
  int statusCode;

  /// 最近一次请求的解码 body（用于断言请求结构）。
  Map<String, dynamic>? lastRequestBody;
  String lastPath = '';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastPath = options.path;
    if (options.data is Map) {
      lastRequestBody = Map<String, dynamic>.from(options.data as Map);
    }
    // 模拟真实 OpenAI 响应头，触发 dio 的 JSON 自动解码。
    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: const {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeAdapter adapter;
  late OpenAiCompatibleService service;

  setUp(() {
    adapter = FakeAdapter();
    final dio = Dio();
    dio.httpClientAdapter = adapter;
    service = OpenAiCompatibleService(config: _config, dio: dio);
  });

  group('parseFoodsFromText', () {
    test('解析正常响应', () async {
      adapter.responseBody =
          chatResponse(jsonEncode([
        {'name': '白菜', 'quantity': 2, 'unit': '颗'}
      ]));
      final foods = await service.parseFoodsFromText('我买了两颗白菜');
      expect(foods, hasLength(1));
      expect(foods[0].name, '白菜');
      expect(foods[0].quantity, 2);
      expect(foods[0].unit, '颗');
    });

    test('请求体使用 textModel 且包含 system+user 两条消息', () async {
      adapter.responseBody = chatResponse('[]');
      await service.parseFoodsFromText('鸡蛋 3 个');
      expect(adapter.lastPath, '/chat/completions');
      expect(adapter.lastRequestBody!['model'], 'test-text');
      final messages = adapter.lastRequestBody!['messages'] as List;
      expect(messages, hasLength(2));
      expect(messages[0]['role'], 'system');
      expect(messages[1]['role'], 'user');
      expect(messages[1]['content'], '鸡蛋 3 个');
    });

    test('AI 返回非数组时得到空列表', () async {
      adapter.responseBody = chatResponse('抱歉，我没看懂');
      final foods = await service.parseFoodsFromText('???');
      expect(foods, isEmpty);
    });
  });

  group('recognizeFoods', () {
    test('解析视觉模型返回的食材 JSON', () async {
      adapter.responseBody =
          chatResponse(jsonEncode([
        {'name': '西红柿', 'quantity': 3, 'unit': '个'}
      ]));
      final foods = await service.recognizeFoods('BASE64DATA');
      expect(foods, hasLength(1));
      expect(foods[0].name, '西红柿');
    });

    test('请求体使用 visionModel 且 user content 含 image_url', () async {
      adapter.responseBody = chatResponse('[]');
      await service.recognizeFoods('ABC123');
      expect(adapter.lastRequestBody!['model'], 'test-vision');
      final user = (adapter.lastRequestBody!['messages'] as List)
          .firstWhere((m) => m['role'] == 'user') as Map;
      final content = user['content'] as List;
      final hasImageUrl = content.any(
        (part) => part is Map && part['type'] == 'image_url',
      );
      expect(hasImageUrl, isTrue);
    });
  });

  group('generateRecipe', () {
    test('解析正常 JSON 对象为 Recipe', () async {
      adapter.responseBody = chatResponse(jsonEncode({
        'title': '番茄炒蛋',
        'ingredients': [
          {'name': '番茄', 'amount': 2, 'unit': '个'}
        ],
        'steps': ['打蛋', '翻炒'],
      }));
      final recipe = await service.generateRecipe(['番茄', '鸡蛋']);
      expect(recipe, isNotNull);
      expect(recipe!.title, '番茄炒蛋');
      expect(recipe.ingredients, hasLength(1));
      expect(recipe.ingredients[0].foodName, '番茄');
      expect(recipe.ingredients[0].amount, 2);
      expect(recipe.steps, ['打蛋', '翻炒']);
      expect(recipe.source, RecipeSource.ai);
    });

    test('请求体 user 消息包含可用食材列表', () async {
      adapter.responseBody = chatResponse(jsonEncode({}));
      await service.generateRecipe(['番茄', '鸡蛋']);
      final user = (adapter.lastRequestBody!['messages'] as List)
          .firstWhere((m) => m['role'] == 'user') as Map;
      expect(user['content'].toString(), contains('番茄'));
      expect(user['content'].toString(), contains('鸡蛋'));
    });

    test('带 markdown 代码块包裹的 JSON 也能解析', () async {
      final inner = jsonEncode(
          {'title': '测试', 'ingredients': [], 'steps': []});
      adapter.responseBody = chatResponse('```json\n$inner\n```');
      final recipe = await service.generateRecipe(['x']);
      expect(recipe, isNotNull);
      expect(recipe!.title, '测试');
    });

    test('无效 JSON 返回 null', () async {
      adapter.responseBody = chatResponse('这不是JSON');
      final recipe = await service.generateRecipe(['x']);
      expect(recipe, isNull);
    });
  });

  group('testConnection', () {
    test('成功返回 true', () async {
      adapter.responseBody = chatResponse('ok');
      final ok = await service.testConnection();
      expect(ok, isTrue);
    });

    test('HTTP 错误返回 false', () async {
      adapter.responseBody = '';
      adapter.statusCode = 401;
      final ok = await service.testConnection();
      expect(ok, isFalse);
    });

    test('空 choices 内容返回 false', () async {
      adapter.responseBody = emptyChoicesResponse();
      final ok = await service.testConnection();
      expect(ok, isFalse);
    });
  });

  group('默认 Dio 构造', () {
    test('未注入 Dio 时自动创建并携带 Authorization 与 baseUrl', () {
      final svc = OpenAiCompatibleService(config: _config);
      expect(svc.dio.options.baseUrl, _config.baseUrl);
      expect(svc.dio.options.headers['Authorization'], 'Bearer sk-test');
      expect(svc.dio.options.headers['Content-Type'], 'application/json');
    });
  });
}

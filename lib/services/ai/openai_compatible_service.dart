import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/domain/ai/ai_service.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

/// 基于 OpenAI 兼容 `/v1/chat/completions` 接口的 [AiService] 实现。
///
/// 支持视觉模型识别食材、文本模型解析自然语言、生成菜谱。
/// 测试时通过注入 [Dio]（搭配自定义 [HttpClientAdapter]）实现解耦。
class OpenAiCompatibleService implements AiService {
  final AiConfig config;
  final Dio dio;

  OpenAiCompatibleService({required this.config, Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
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
          'content': '我的冰箱里有：${availableFoods.join('、')}',
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

  /// 统一的 chat completions 调用，返回首条 message 的 content 文本。
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

  /// 解析 AI 返回的菜谱 JSON 文本为 [Recipe]；任何异常返回 null。
  Recipe? _parseRecipe(String raw) {
    try {
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
      final steps =
          (m['steps'] as List? ?? []).map((s) => s.toString()).toList();
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

  /// 从可能含 markdown 围栏或噪声文本的字符串中提取首个 JSON 对象。
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

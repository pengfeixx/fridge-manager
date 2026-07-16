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

  RecognizedFood copyWith({
    String? name,
    double? quantity,
    String? unit,
  }) =>
      RecognizedFood(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
      );

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
    final fenceMatch =
        RegExp(r'```(?:json)?\s*\n?([\s\S]*?)```').firstMatch(trimmed);
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

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
      // DeepSeek 暂无公开视觉模型，留空待用户手动配置。
      visionModel: '',
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

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

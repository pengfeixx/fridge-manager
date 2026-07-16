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

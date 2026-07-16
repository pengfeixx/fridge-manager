import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/services/ai/ai_config_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FlutterSecureStorage 平台通道名称。
const _kSecureChannel = 'plugins.it_nomads.com/flutter_secure_storage';

/// 注册一个由 [store] 支撑的 FlutterSecureStorage 平台通道假实现，
/// 用于在 flutter_test 环境下避免真实 Keystore/keyring 调用。
void registerSecureStorageFake(Map<String, String> store) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel(_kSecureChannel),
          (MethodCall call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    switch (call.method) {
      case 'write':
        store[args['key'] as String] = args['value'] as String;
        return null;
      case 'read':
        return store[args['key'] as String];
      case 'delete':
        store.remove(args['key'] as String);
        return null;
      case 'containsKey':
        return store.containsKey(args['key'] as String);
      case 'readAll':
        return Map<String, dynamic>.from(store);
      case 'deleteAll':
        store.clear();
        return null;
    }
    return null;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiConfig 值对象', () {
    test('isConfigured 在 baseUrl/apiKey/textModel 均非空时为 true', () {
      const config = AiConfig(
        baseUrl: 'https://api.deepseek.com/v1',
        apiKey: 'sk-xxx',
        textModel: 'deepseek-chat',
        visionModel: 'deepseek-chat',
      );
      expect(config.isConfigured, isTrue);
    });

    test('isConfigured 在任一关键字段为空时为 false', () {
      expect(
        const AiConfig(
                baseUrl: '', apiKey: 'k', textModel: 'm', visionModel: 'v')
            .isConfigured,
        isFalse,
      );
      expect(
        const AiConfig(
                baseUrl: 'u', apiKey: '', textModel: 'm', visionModel: 'v')
            .isConfigured,
        isFalse,
      );
      expect(
        const AiConfig(
                baseUrl: 'u', apiKey: 'k', textModel: '', visionModel: 'v')
            .isConfigured,
        isFalse,
      );
      // visionModel 为空不影响 isConfigured。
      expect(
        const AiConfig(
                baseUrl: 'u', apiKey: 'k', textModel: 'm', visionModel: '')
            .isConfigured,
        isTrue,
      );
    });

    test('copyWith 只覆盖传入字段', () {
      const original = AiConfig(
        baseUrl: 'u',
        apiKey: 'k',
        textModel: 't',
        visionModel: 'v',
      );
      final updated = original.copyWith(apiKey: 'k2');
      expect(updated.apiKey, 'k2');
      expect(updated.baseUrl, 'u');
      expect(updated.textModel, 't');
      expect(updated.visionModel, 'v');
    });

    test('toString 不暴露 apiKey', () {
      const config = AiConfig(
        baseUrl: 'https://example.com',
        apiKey: 'super-secret-key',
        textModel: 't',
        visionModel: 'v',
      );
      final repr = config.toString();
      expect(repr, contains('apiKey: ***'));
      expect(repr, isNot(contains('super-secret-key')));
    });

    test('presets 提供预置配置且 apiKey 为空', () {
      expect(AiConfig.presets.keys,
          containsAll(const ['DeepSeek', '豆包', 'OpenAI', 'Kimi']));
      for (final config in AiConfig.presets.values) {
        expect(config.apiKey, '');
        expect(config.baseUrl, isNotEmpty);
        expect(config.textModel, isNotEmpty);
      }
    });
  });

  group('AiConfigRepository', () {
    late SharedPreferences prefs;
    late Map<String, String> secureStore;
    late AiConfigRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      secureStore = <String, String>{};
      registerSecureStorageFake(secureStore);
      repo = AiConfigRepository(prefs, const FlutterSecureStorage());
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(_kSecureChannel), null);
    });

    test('load 在未保存时返回 null', () async {
      expect(await repo.load(), isNull);
    });

    test('save 后 load 能还原全部字段', () async {
      const config = AiConfig(
        baseUrl: 'https://api.deepseek.com/v1',
        apiKey: 'sk-secret',
        textModel: 'deepseek-chat',
        visionModel: 'deepseek-chat',
      );
      await repo.save(config);
      final loaded = await repo.load();
      expect(loaded, isNotNull);
      expect(loaded!.baseUrl, config.baseUrl);
      expect(loaded.apiKey, config.apiKey);
      expect(loaded.textModel, config.textModel);
      expect(loaded.visionModel, config.visionModel);
    });

    test('apiKey 存入安全存储而非 SharedPreferences 明文', () async {
      const config = AiConfig(
        baseUrl: 'https://api.deepseek.com/v1',
        apiKey: 'sk-secret',
        textModel: 'deepseek-chat',
        visionModel: 'deepseek-chat',
      );
      await repo.save(config);
      // 明文存储不应包含 apiKey。
      expect(prefs.getString('ai_api_key'), isNull);
      // 安全存储应包含 apiKey。
      expect(secureStore['ai_api_key'], 'sk-secret');
    });

    test('clear 删除明文项与安全项', () async {
      const config = AiConfig(
        baseUrl: 'u',
        apiKey: 'k',
        textModel: 't',
        visionModel: 'v',
      );
      await repo.save(config);
      await repo.clear();
      expect(await repo.load(), isNull);
      expect(prefs.getString('ai_base_url'), isNull);
      expect(secureStore['ai_api_key'], isNull);
    });

    test('load 在 baseUrl 为空字符串时返回 null', () async {
      // 模拟仅写入了空 baseUrl（边界情况）。
      await prefs.setString('ai_base_url', '');
      expect(await repo.load(), isNull);
    });
  });
}

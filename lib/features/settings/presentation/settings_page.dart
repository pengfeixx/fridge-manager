import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/ai/ai_config.dart';
import 'package:fridge_manager/features/settings/presentation/widgets/preset_card.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';
import 'package:fridge_manager/services/ai/openai_compatible_service.dart';

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
        const SnackBar(
            content: Text('配置已保存'), behavior: SnackBarBehavior.floating),
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
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                    width: 18,
                    height: 18,
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

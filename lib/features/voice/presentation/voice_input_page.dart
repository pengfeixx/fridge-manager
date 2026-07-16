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
    } catch (e) {
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
                    color: _listening
                        ? scheme.errorContainer
                        : scheme.primaryContainer,
                  ),
                  child: Icon(
                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 40,
                    color: _listening
                        ? scheme.onErrorContainer
                        : scheme.onPrimaryContainer,
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
              Text(_error!,
                  style: TextStyle(color: scheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            if (_text.isNotEmpty)
              FilledButton.icon(
                onPressed: _parsing ? null : _parseFoods,
                icon: _parsing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
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

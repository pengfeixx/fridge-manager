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

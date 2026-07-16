import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/features/nutrition/providers/nutrition_providers.dart';
import 'package:fridge_manager/services/ai/ai_providers.dart';

class ShoppingSuggestionPage extends ConsumerStatefulWidget {
  const ShoppingSuggestionPage({super.key});
  @override
  ConsumerState<ShoppingSuggestionPage> createState() =>
      _ShoppingSuggestionPageState();
}

class _ShoppingSuggestionPageState
    extends ConsumerState<ShoppingSuggestionPage> {
  String? _aiSuggestion;
  bool _aiLoading = false;

  Future<void> _askAi() async {
    final list = await ref.read(shoppingListProvider.future);
    if (list.isEmpty) return;
    final aiService = await ref.read(aiServiceProvider.future);
    if (aiService == null) {
      if (!mounted) return;
      setState(() => _aiSuggestion = '请先在设置中配置 AI');
      return;
    }
    if (!mounted) return;
    setState(() => _aiLoading = true);
    try {
      final prompt = list
          .map((s) =>
              '${s.category.label}约${(s.grams / 1000).toStringAsFixed(1)}kg')
          .join('、');
      final response = await aiService.parseFoodsFromText(
          '我本周需要补充以下食材（$prompt），请帮我生成一个简洁的买菜清单建议，包含具体食材推荐。');
      if (!mounted) return;
      setState(() => _aiSuggestion =
          response.map((r) => '• ${r.name} ${r.quantity}${r.unit}').join('\n'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _aiSuggestion = '生成失败：$e');
    }
    if (!mounted) return;
    setState(() => _aiLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('买菜建议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // 量化缺口表
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.analytics_rounded,
                          color: scheme.primary, size: 18),
                      const SizedBox(width: 6),
                      const Text('本周营养缺口',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 12),
                    ref.watch(shoppingListProvider).when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('出错：$e'),
                          data: (list) {
                            if (list.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                    child: Column(children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 48, color: Color(0xFF2E7D32)),
                                  const SizedBox(height: 8),
                                  Text('营养均衡，暂无需补充！',
                                      style: TextStyle(
                                          color: scheme.onSurfaceVariant)),
                                ])),
                              );
                            }
                            return Column(children: [
                              for (final item in list)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(children: [
                                    Text(item.category.emoji,
                                        style: const TextStyle(fontSize: 22)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(item.category.label,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text('建议补充',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      scheme.onSurfaceVariant)),
                                        ])),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: scheme.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(item.kgDisplay,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  scheme.onPrimaryContainer)),
                                    ),
                                  ]),
                                ),
                            ]);
                          },
                        ),
                  ]),
            ),
          ),
          const SizedBox(height: 16),
          // AI 润色
          if (_aiSuggestion != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: scheme.tertiary, size: 18),
                        const SizedBox(width: 6),
                        const Text('AI 建议',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 8),
                      Text(_aiSuggestion!, style: const TextStyle(height: 1.6)),
                    ]),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _aiLoading ? null : _askAi,
            icon: _aiLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_aiLoading ? '生成中...' : '让 AI 生成买菜清单'),
          ),
        ]),
      ),
    );
  }
}

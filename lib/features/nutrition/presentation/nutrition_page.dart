import 'package:flutter/material.dart';

/// 营养分析主页占位（下个任务完整实现）。
class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('营养分析')),
      body: const Center(child: Text('营养分析（即将上线）')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/app.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // 启动时播种菜谱库（幂等）。
  await container.read(recipeRepositoryProvider).seedIfEmpty();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const FridgeApp(),
  ));
}

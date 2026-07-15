import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/app.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';
import 'package:fridge_manager/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final container = ProviderContainer();
  // 启动时播种菜谱库（幂等）。
  await container.read(recipeRepositoryProvider).seedIfEmpty();
  // 注册每日 09:00 临期检查通知。
  await NotificationService.scheduleDailyExpiryCheck(container);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const FridgeApp(),
  ));
}

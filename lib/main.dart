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
  // 阶段一简化：App 启动时主动检查一次临期食材并通知。
  // 纯后台定时在 flutter_local_notifications 下不可靠，因此每次打开 App 时
  // 都触发一次即时检查；阶段二可用 workmanager 实现真正的后台定时检查。
  await NotificationService.checkAndNotify(container);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const FridgeApp(),
  ));
}

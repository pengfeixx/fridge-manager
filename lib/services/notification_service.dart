import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 临期食材本地通知服务。
///
/// 负责：
/// - 初始化 flutter_local_notifications 插件与 Android 通知通道。
/// - [checkAndNotify]：立即检查在库食材，对处于 [ExpiryLevel.near] 的食材
///   汇总并弹出一条本地通知。
/// - [scheduleDailyExpiryCheck]：注册每天 09:00 的定时通知（前台/后台唤起时触发）。
///
/// 平台后台限制下纯后台定时不可靠，后续可换为 workmanager 增强（P1）。
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'expiry_reminder',
    '临期提醒',
    description: '快过期的食材提醒',
  );

  /// 初始化插件、时区数据与 Android 通知通道。应在 main 中尽早调用。
  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// 立即检查并发送一次通知（也用于每日定时任务触发）。
  ///
  /// 取 [FoodRepository.watchInStock] 的首帧，筛选剩余天数在
  /// (0, nearThreshold] 区间（即 [ExpiryLevel.near]）的食材，拼接名称与剩余
  /// 天数后弹出一条高优先级通知。无临期食材时静默返回。
  static Future<void> checkAndNotify(
    ProviderContainer container, {
    int nearThreshold = 3,
  }) async {
    final repo = container.read(foodRepositoryProvider);
    final items = await repo.watchInStock().first;
    final now = DateTime.now();
    final near = items
        .where((i) =>
            ShelfLifeService.expiryLevel(i, now,
                nearThreshold: nearThreshold) ==
            ExpiryLevel.near)
        .toList();
    if (near.isEmpty) return;
    final body = near
        .map((i) =>
            '${i.name}（剩余${ShelfLifeService.remainingDays(i, now)}天）')
        .join('、');
    await _plugin.show(
      0,
      '冰箱里有食材快过期啦',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
        ),
      ),
    );
  }

  /// 注册每天 09:00 的定时通知（使用 zonedSchedule）。
  ///
  /// 若今天 09:00 已过，则从明天 09:00 开始；通过 [DateTimeComponents.time]
  /// 让其每日重复。注意：此处仅注册一条占位通知，真正的临期检查逻辑
  /// 由 [checkAndNotify] 完成（受平台后台限制，需 App 被唤起时才可靠触发）。
  static Future<void> scheduleDailyExpiryCheck(
      ProviderContainer container) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      1,
      '冰箱临期检查',
      '正在检查…',
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

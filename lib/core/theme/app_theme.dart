import 'package:flutter/material.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';

class AppTheme {
  static const seed = Colors.green;

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      );

  /// 临期三色映射。
  static Color expiryColor(ExpiryLevel level) => switch (level) {
        ExpiryLevel.safe => Colors.green,
        ExpiryLevel.near => Colors.orange,
        ExpiryLevel.expired => Colors.red,
      };
}

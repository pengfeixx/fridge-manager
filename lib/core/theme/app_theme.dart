import 'package:flutter/material.dart';
import 'package:fridge_manager/domain/services/shelf_life_service.dart';

class AppTheme {
  static const seed = Color(0xFF00695C);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
        space: 1,
      ),
    );
  }

  static Color expiryColor(ExpiryLevel level) => switch (level) {
        ExpiryLevel.safe => const Color(0xFF2E7D32),
        ExpiryLevel.near => const Color(0xFFEF6C00),
        ExpiryLevel.expired => const Color(0xFFC62828),
      };

  static Color expiryBg(ExpiryLevel level) => switch (level) {
        ExpiryLevel.safe => const Color(0xFFE8F5E9),
        ExpiryLevel.near => const Color(0xFFFFF3E0),
        ExpiryLevel.expired => const Color(0xFFFFEBEE),
      };

  static IconData storageIcon(String label) => switch (label) {
        '冷藏' => Icons.kitchen_rounded,
        '冷冻' => Icons.ac_unit_rounded,
        '常温' => Icons.home_rounded,
        _ => Icons.inventory_2_rounded,
      };
}

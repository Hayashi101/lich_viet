import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF2F7164);
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: brightness == Brightness.light
          ? const Color(0xFFFBFDFB)
          : const Color(0xFF15211F),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

abstract final class AppColors {
  static Color lunar(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFA34842)
      : const Color(0xFFFFAAA4);

  static Color lunarSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFFBEDEA)
      : const Color(0xFF3A2927);

  static Color selectedTab(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFD9F3E9)
      : const Color(0xFF294B44);

  static Color selectedDate(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF2F7164)
      : const Color(0xFF72C9B7);

  static Color onSelectedDate(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF10231F);
}

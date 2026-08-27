import 'package:flutter/material.dart';
import 'package:gometer/core/settings/settings_repository.dart';

export 'app_extra_colors.dart' show UsageLevel, levelFor, labelFor, noteFor;

extension AccentSeedColor on AccentSeed {
  Color get color {
    return switch (this) {
      AccentSeed.auto => const Color(0xFF2196F3),
      AccentSeed.blue => const Color(0xFF2196F3),
      AccentSeed.violet => const Color(0xFF7C4DFF),
      AccentSeed.green => const Color(0xFF22C55E),
      AccentSeed.orange => const Color(0xFFFB8C00),
      AccentSeed.pink => const Color(0xFFE91E63),
    };
  }
}

extension AppThemeModeResolver on AppThemeMode {
  Brightness resolve(Brightness platform) =>
      this == AppThemeMode.system
          ? platform
          : (this == AppThemeMode.light ? Brightness.light : Brightness.dark);
}

ThemeData buildTheme(
  AppSettings settings,
  Brightness platformBrightness, {
  ColorScheme? dynamicLight,
  ColorScheme? dynamicDark,
}) {
  final brightness = settings.themeMode.resolve(platformBrightness);
  final dynamicScheme =
      brightness == Brightness.light ? dynamicLight : dynamicDark;
  final scheme = settings.seed == AccentSeed.auto && dynamicScheme != null
      ? dynamicScheme
      : ColorScheme.fromSeed(
          seedColor: settings.seed.color,
          brightness: brightness,
        );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/app_extra_colors.dart';
import 'package:gometer/core/theme/app_theme.dart';

void main() {
  const platformBrightness = Brightness.dark;

  AppSettings settingsWith(AccentSeed seed) =>
      AppSettings(seed: seed, themeMode: AppThemeMode.system);

  ColorScheme seedScheme(AccentSeed seed, Brightness brightness) =>
      ColorScheme.fromSeed(seedColor: seed.color, brightness: brightness);

  test('auto uses dark dynamic scheme when available', () {
    final dynamicDark = seedScheme(AccentSeed.pink, Brightness.dark);

    final theme =
        buildTheme(settingsWith(AccentSeed.auto), platformBrightness,
            dynamicDark: dynamicDark);

    expect(theme.colorScheme.primary, dynamicDark.primary);
  });

  test('auto uses light dynamic scheme when available', () {
    final dynamicLight = seedScheme(AccentSeed.green, Brightness.light);

    final theme = buildTheme(settingsWith(AccentSeed.auto), Brightness.light,
        dynamicLight: dynamicLight);

    expect(theme.colorScheme.primary, dynamicLight.primary);
  });

  test('auto falls back to blue seed without dynamic schemes', () {
    final theme = buildTheme(settingsWith(AccentSeed.auto), platformBrightness);
    final fallback = seedScheme(AccentSeed.blue, Brightness.dark);

    expect(theme.colorScheme.primary, fallback.primary);
  });

  test('explicit seed ignores dynamic schemes', () {
    final dynamicDark = seedScheme(AccentSeed.pink, Brightness.dark);
    final expected = seedScheme(AccentSeed.blue, Brightness.dark);

    final theme = buildTheme(settingsWith(AccentSeed.blue), platformBrightness,
        dynamicDark: dynamicDark);

    expect(theme.colorScheme.primary, expected.primary);
  });

  test('level colors map to M3 roles (amber -> tertiary)', () {
    final theme =
        buildTheme(settingsWith(AccentSeed.green), platformBrightness);
    final scheme = theme.colorScheme;

    expect(scheme.levelColor(UsageLevel.green), scheme.primary);
    expect(scheme.levelColor(UsageLevel.amber), scheme.tertiary);
    expect(scheme.levelColor(UsageLevel.red), scheme.error);
  });
}

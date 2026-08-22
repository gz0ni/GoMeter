import 'package:flutter/material.dart';

@immutable
class AppExtraColors extends ThemeExtension<AppExtraColors> {
  final Color warn;
  final Color onWarn;
  final Color warnContainer;
  final Color onWarnContainer;

  const AppExtraColors({
    required this.warn,
    required this.onWarn,
    required this.warnContainer,
    required this.onWarnContainer,
  });

  factory AppExtraColors.light() => const AppExtraColors(
        warn: Color(0xFF9C6200),
        onWarn: Color(0xFFFFFFFF),
        warnContainer: Color(0xFFFFE08A),
        onWarnContainer: Color(0xFF2C1D00),
      );

  factory AppExtraColors.dark() => const AppExtraColors(
        warn: Color(0xFFFFB759),
        onWarn: Color(0xFF452B00),
        warnContainer: Color(0xFF5C4900),
        onWarnContainer: Color(0xFFFFE08A),
      );

  @override
  AppExtraColors copyWith({
    Color? warn,
    Color? onWarn,
    Color? warnContainer,
    Color? onWarnContainer,
  }) {
    return AppExtraColors(
      warn: warn ?? this.warn,
      onWarn: onWarn ?? this.onWarn,
      warnContainer: warnContainer ?? this.warnContainer,
      onWarnContainer: onWarnContainer ?? this.onWarnContainer,
    );
  }

  @override
  AppExtraColors lerp(ThemeExtension<AppExtraColors>? other, double t) {
    if (other is! AppExtraColors) return this;
    return AppExtraColors(
      warn: Color.lerp(warn, other.warn, t)!,
      onWarn: Color.lerp(onWarn, other.onWarn, t)!,
      warnContainer: Color.lerp(warnContainer, other.warnContainer, t)!,
      onWarnContainer: Color.lerp(onWarnContainer, other.onWarnContainer, t)!,
    );
  }
}

extension AppExtraColorsExtension on BuildContext {
  AppExtraColors get extraColors {
    return Theme.of(this).extension<AppExtraColors>() ??
        AppExtraColors.light();
  }
}

extension ColorSchemeExtra on ColorScheme {
  Color levelColor(UsageLevel level, AppExtraColors extra) => switch (level) {
        UsageLevel.green => primary,
        UsageLevel.amber => extra.warn,
        UsageLevel.red => error,
      };

  Color levelContainerColor(UsageLevel level, AppExtraColors extra) =>
      switch (level) {
        UsageLevel.green => primaryContainer,
        UsageLevel.amber => extra.warnContainer,
        UsageLevel.red => errorContainer,
      };

  Color onLevelContainerColor(UsageLevel level, AppExtraColors extra) =>
      switch (level) {
        UsageLevel.green => onPrimaryContainer,
        UsageLevel.amber => extra.onWarnContainer,
        UsageLevel.red => onErrorContainer,
      };
}

enum UsageLevel { green, amber, red }

UsageLevel levelFor(int remainingPercent) {
  if (remainingPercent > 50) return UsageLevel.green;
  if (remainingPercent >= 20) return UsageLevel.amber;
  return UsageLevel.red;
}

String labelFor(UsageLevel level) => switch (level) {
      UsageLevel.green => 'Всё спокойно',
      UsageLevel.amber => 'Почти у предела',
      UsageLevel.red => 'Близко к лимиту',
    };

String noteFor(UsageLevel level) => switch (level) {
      UsageLevel.green => 'Запас прочности большой — можно работать спокойно.',
      UsageLevel.amber => 'Осталось немного. Скоро окно обновится.',
      UsageLevel.red => 'Осталось совсем чуть-чуть — побереги лимит.',
    };

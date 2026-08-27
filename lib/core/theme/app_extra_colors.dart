import 'package:flutter/material.dart';

extension ColorSchemeLevels on ColorScheme {
  Color levelColor(UsageLevel level) => switch (level) {
        UsageLevel.green => primary,
        UsageLevel.amber => tertiary,
        UsageLevel.red => error,
      };

  Color levelContainerColor(UsageLevel level) => switch (level) {
        UsageLevel.green => primaryContainer,
        UsageLevel.amber => tertiaryContainer,
        UsageLevel.red => errorContainer,
      };

  Color onLevelContainerColor(UsageLevel level) => switch (level) {
        UsageLevel.green => onPrimaryContainer,
        UsageLevel.amber => onTertiaryContainer,
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

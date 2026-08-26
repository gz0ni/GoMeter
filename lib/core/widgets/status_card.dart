import 'package:flutter/material.dart';
import 'package:gometer/core/theme/app_extra_colors.dart';
import 'package:gometer/features/usage/utils/duration_format.dart';

class StatusCard extends StatelessWidget {
  final UsageLevel level;
  final String windowName;
  final int percent;
  final int resetInSeconds;

  const StatusCard({
    super.key,
    required this.level,
    required this.windowName,
    required this.percent,
    required this.resetInSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extra = context.extraColors;
    final accent = scheme.levelColor(level, extra);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              switch (level) {
                UsageLevel.green => Icons.check_circle,
                UsageLevel.amber => Icons.warning,
                UsageLevel.red => Icons.error,
              },
              size: 22,
              color: accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelFor(level),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    text: '$windowName · использовано $percent% · окно в течение ',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: scheme.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: formatDuration(resetInSeconds),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

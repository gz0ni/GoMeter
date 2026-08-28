import 'package:flutter/material.dart';
import 'package:gometer/core/theme/app_extra_colors.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';

class LimitCard extends StatelessWidget {
  final UsageLimit limit;

  const LimitCard({super.key, required this.limit});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = scheme.levelColor(limit.level);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 16),
      child: Column(
        children: [
          Icon(
            _iconFor(limit.id),
            size: 30,
            color: scheme.onSurface,
          ),
          const SizedBox(height: 6),
          Text(limit.name, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: '${limit.percent}',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '%',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'осталось ${limit.remainingPercent}%',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: limit.percent / 100,
            minHeight: 4,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
        'rolling' => Icons.history,
        'weekly' => Icons.date_range,
        'monthly' => Icons.calendar_month,
        _ => Icons.timelapse,
      };
}

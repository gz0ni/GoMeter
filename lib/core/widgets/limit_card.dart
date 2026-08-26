import 'package:flutter/material.dart';
import 'package:gometer/core/theme/app_extra_colors.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';

class LimitCard extends StatelessWidget {
  final UsageLimit limit;

  const LimitCard({super.key, required this.limit});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extra = context.extraColors;
    final accent = scheme.levelColor(limit.level, extra);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
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
          Text(
            limit.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: '${limit.percent}',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01,
                color: scheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'осталось ${limit.remainingPercent}%',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: limit.percent / 100,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
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

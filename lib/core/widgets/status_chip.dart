import 'package:flutter/material.dart';
import 'package:gometer/core/theme/app_extra_colors.dart';

class StatusChip extends StatelessWidget {
  final UsageLevel level;
  final String? label;

  const StatusChip({super.key, required this.level, this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extra = context.extraColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.levelContainerColor(level, extra),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: scheme.levelColor(level, extra),
          ),
          const SizedBox(width: 8),
          Text(
            label ?? labelFor(level),
            style: TextStyle(
              color: scheme.onLevelContainerColor(level, extra),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final UsageLevel level;

  const StatusPill({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extra = context.extraColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.levelContainerColor(level, extra),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: scheme.levelColor(level, extra),
          ),
          const SizedBox(width: 6),
          Text(
            labelFor(level),
            style: TextStyle(
              color: scheme.onLevelContainerColor(level, extra),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

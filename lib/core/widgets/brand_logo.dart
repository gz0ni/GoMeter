import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double iconSize;

  const BrandLogo({super.key, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.speed,
            color: colorScheme.onPrimaryContainer,
            size: iconSize * 0.6,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GoMeter',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Лимиты OpenCode Go',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final double radius;
  final String image;

  const AppIcon({
    super.key,
    this.size = 40,
    this.radius = 12,
    this.image = 'assets/images/png/icon-256.png',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.speed,
            size: size * 0.6,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

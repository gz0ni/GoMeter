import 'package:flutter/material.dart';

class ColorDot extends StatelessWidget {
  final bool selected;
  final Color? color;
  final VoidCallback? onTap;
  final bool isAuto;

  const ColorDot({
    super.key,
    this.color,
    this.selected = false,
    this.onTap,
    this.isAuto = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? (color ?? scheme.primary) : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAuto ? scheme.surfaceContainerHighest : color,
            border: Border.all(
              color: selected ? scheme.onSurface : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: isAuto
              ? Icon(
                  Icons.auto_awesome,
                  size: 22,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                )
              : null,
        ),
      ),
    );
  }
}

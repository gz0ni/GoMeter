import 'package:flutter/material.dart';

class M3Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const M3Switch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onChanged != null;
    final checked = value;

    return Semantics(
      toggled: checked,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!checked) : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.38,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 56,
            height: 34,
            decoration: BoxDecoration(
              color: checked ? scheme.primary : Colors.transparent,
              border: Border.all(
                color: checked ? scheme.primary : scheme.outline,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: AnimatedAlign(
              alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 190),
                  curve: Curves.easeOutCubic,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

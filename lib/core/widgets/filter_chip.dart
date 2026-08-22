import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: scheme.secondaryContainer,
      backgroundColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : scheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

import 'package:flutter/material.dart';

class DropdownPill<T> extends StatelessWidget {
  final T value;
  final List<DropdownPillItem<T>> items;
  final ValueChanged<T> onChanged;

  const DropdownPill({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = items.firstWhere((i) => i.value == value).label;

    return PopupMenuButton<T>(
      tooltip: '',
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                Expanded(child: Text(item.label)),
                if (item.value == value)
                  Icon(Icons.check, size: 18, color: scheme.primary),
              ],
            ),
          ),
      ],
      onSelected: onChanged,
      child: Container(
        height: 50,
        padding: const EdgeInsets.only(left: 20, right: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.expand_more,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownPillItem<T> {
  final T value;
  final String label;

  const DropdownPillItem({required this.value, required this.label});
}

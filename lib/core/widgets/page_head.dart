import 'package:flutter/material.dart';

class PageHead extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const PageHead({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (showBack)
          IconButton(
            tooltip: 'Назад',
            iconSize: 22,
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ...actions,
      ],
    );
  }
}

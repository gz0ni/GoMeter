import 'package:flutter/material.dart';

class UpdateBanner extends StatelessWidget {
  final String version;
  final String subtitle;
  final VoidCallback? onUpdate;
  final VoidCallback? onDismiss;

  const UpdateBanner({
    super.key,
    required this.version,
    required this.subtitle,
    this.onUpdate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.system_update,
            size: 22,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вышла версия $version',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUpdate,
            style: TextButton.styleFrom(
              foregroundColor: scheme.onPrimaryContainer,
              backgroundColor: scheme.onPrimaryContainer.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Обновить'),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close,
              size: 18,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

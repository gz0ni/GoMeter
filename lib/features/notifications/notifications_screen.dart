import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsProvider).value ?? const AppSettings();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Когда лимит приближается к 80% и 95%, приходит пуш — так ты не упрёшься в лимит неожиданно.',
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.speed,
                          color: scheme.onPrimaryContainer,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'GoMeter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'сейчас',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Лимит 80% · 5-часовое окно',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Осталось 20%. Окно сбросится примерно через 47 минут.',
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(
                      Icons.notifications,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  title: const Text('Порог 80%'),
                  subtitle: const Text('«Почти у предела»'),
                  value: settings.threshold80,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setThreshold80(v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(
                      Icons.priority_high,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  title: const Text('Порог 95%'),
                  subtitle: const Text('«Близко к лимиту»'),
                  value: settings.threshold95,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setThreshold95(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

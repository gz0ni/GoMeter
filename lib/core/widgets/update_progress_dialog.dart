import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/core/update/update_state.dart';

class UpdateProgressDialog extends ConsumerWidget {
  const UpdateProgressDialog({super.key});

  void _restart(BuildContext context, WidgetRef ref) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      Process.start(Platform.resolvedExecutable, Platform.executableArguments);
      exit(0);
    }
    Navigator.of(context).pop();
    ref.read(updateControllerProvider.notifier).dismiss();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final title = switch (update.status) {
      UpdateStatus.error => 'Ошибка обновления',
      UpdateStatus.installing => 'Установка',
      UpdateStatus.done => 'Обновление завершено',
      _ => 'Загрузка обновления',
    };

    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (update.status == UpdateStatus.done)
              Row(
                spacing: 12,
                children: [
                  Icon(Icons.check_circle, color: scheme.primary),
                  const Expanded(
                    child: Text(
                      'Перезапустите программу, чтобы изменения вступили в силу.',
                    ),
                  ),
                ],
              )
            else if (update.status == UpdateStatus.error)
              Text(update.error ?? 'Неизвестная ошибка')
            else if (update.status == UpdateStatus.installing)
              Row(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: scheme.primary,
                    ),
                  ),
                  const Text('Установка обновления...'),
                ],
              )
            else ...[
              LinearProgressIndicator(
                value: update.progress > 0 ? update.progress : null,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
              Text('${(update.progress * 100).toInt()}%'),
            ],
          ],
        ),
      ),
      actions: [
        if (update.status == UpdateStatus.error)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(updateControllerProvider.notifier).dismiss();
            },
            child: const Text('Закрыть'),
          )
        else if (update.status == UpdateStatus.done) ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(updateControllerProvider.notifier).dismiss();
            },
            child: const Text('Позже'),
          ),
          FilledButton(
            onPressed: () => _restart(context, ref),
            child: const Text('Перезапустить'),
          ),
        ] else if (update.status != UpdateStatus.installing)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(updateControllerProvider.notifier).dismiss();
            },
            child: const Text('Отмена'),
          ),
      ],
    );
  }
}

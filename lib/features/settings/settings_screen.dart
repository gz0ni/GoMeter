import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/layout/breakpoints.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/app_theme.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/core/update/update_state.dart';
import 'package:gometer/core/utils/opencode_auth.dart';
import 'package:gometer/core/widgets/color_dot.dart';
import 'package:gometer/core/widgets/dropdown_pill.dart';
import 'package:gometer/core/widgets/phone_notif.dart';
import 'package:gometer/core/widgets/setting_row.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _intervalOptions = [1, 3, 5];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsProvider).value ?? const AppSettings();
    final notifier = ref.read(settingsProvider.notifier);
    final update = ref.watch(updateControllerProvider);
    final updateNotifier = ref.read(updateControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    Future<void> checkForUpdate() async {
      await updateNotifier.check(isUser: true);
      if (!context.mounted) return;
      final status = ref.read(updateControllerProvider).status;
      final message = status == UpdateStatus.available
          ? 'Доступно обновление'
          : 'Обновлений нет';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    Future<void> importFromCli() async {
      final token = await importOpencodeAuth();
      if (token != null) {
        await ref.read(settingsProvider.notifier).setApiKey(token);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              token != null
                  ? 'Ключ импортирован из opencode CLI'
                  : 'Не удалось импортировать из opencode CLI',
            ),
          ),
        );
      }
    }

    Future<void> clearData() async {
      await notifier.reset();
      if (context.mounted) context.go('/onboarding');
    }

    Widget versionText() {
      return FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.hasData ? snapshot.data!.version : '...';
          return Text(
            'Текущая версия $version',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    final chevron = Icon(
      Icons.chevron_right,
      size: 20,
      color: scheme.onSurfaceVariant,
    );

    return Scaffold(
      body: SafeArea(
        child: DesktopNarrow(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text(
                'Настройки',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              SettingsSection(
                title: 'Внешний вид',
                children: [
                  SettingRow(
                    label: 'Тема',
                    trailing: DropdownPill<AppThemeMode>(
                      value: settings.themeMode,
                      items: [
                        for (final mode in AppThemeMode.values)
                          DropdownPillItem(
                            value: mode,
                            label: switch (mode) {
                              AppThemeMode.light => 'Светлая',
                              AppThemeMode.dark => 'Тёмная',
                              AppThemeMode.system => 'Системная',
                            },
                          ),
                      ],
                      onChanged: (v) => notifier.setThemeMode(v),
                    ),
                  ),
                  const SettingRow(label: 'Цвет акцента'),
                  Wrap(
                    spacing: 14,
                    runSpacing: 10,
                    children: AccentSeed.values.map((seed) {
                      return ColorDot(
                        isAuto: seed == AccentSeed.auto,
                        color: seed == AccentSeed.auto ? null : seed.color,
                        selected: settings.seed == seed,
                        onTap: () => notifier.setSeed(seed),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Обновление',
                showDivider: true,
                children: [
                  SettingRow(
                    label: 'Проверить обновления',
                    subWidget: versionText(),
                    trailing: chevron,
                    onTap: checkForUpdate,
                  ),
                  SwitchRow(
                    label: 'Автопроверка обновлений',
                    sub: 'При запуске приложения',
                    value: settings.autoCheckUpdate,
                    onChanged: (v) => notifier.setAutoCheckUpdate(v),
                  ),
                  SettingRow(
                    label: 'Интервал проверки',
                    trailing: DropdownPill<int>(
                      value: settings.checkIntervalMinutes,
                      items: [
                        for (final m in _intervalOptions)
                          DropdownPillItem(value: m, label: '$m мин'),
                      ],
                      onChanged: (v) => notifier.setCheckInterval(v),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Уведомления',
                showDivider: true,
                children: [
                  const PhoneNotif(
                    title: 'Лимит 80% · 5-часовое окно',
                    text: 'Осталось 20%. Окно сбросится примерно через 47 минут.',
                  ),
                  const SizedBox(height: 8),
                  SwitchRow(
                    label: 'Показывать уведомления',
                    sub: 'О достижении порогов',
                    value: settings.notificationsEnabled,
                    onChanged: (v) => notifier.setNotificationsEnabled(v),
                  ),
                  SwitchRow(
                    label: 'Порог 80%',
                    sub: '«Почти у предела»',
                    value: settings.threshold80,
                    onChanged: settings.notificationsEnabled
                        ? (v) => notifier.setThreshold80(v)
                        : null,
                  ),
                  SwitchRow(
                    label: 'Порог 95%',
                    sub: '«Близко к лимиту»',
                    value: settings.threshold95,
                    onChanged: settings.notificationsEnabled
                        ? (v) => notifier.setThreshold95(v)
                        : null,
                  ),
                ],
              ),
              SettingsSection(
                title: 'Автозапуск',
                showDivider: true,
                children: [
                  SwitchRow(
                    label: 'Старт вместе с системой',
                    sub: 'Запускать GoMeter при входе в систему',
                    value: settings.autostart,
                    onChanged: (v) => notifier.setAutostart(v),
                  ),
                  if (settings.autostart)
                    SwitchRow(
                      label: 'Тихий старт',
                      sub: 'Открываться в трее без окна',
                      value: settings.quietStart,
                      onChanged: (v) => notifier.setQuietStart(v),
                    ),
                ],
              ),
              SettingsSection(
                title: 'Доступ',
                showDivider: true,
                children: [
                  SettingRow(
                    label: 'Ключ доступа',
                    sub: 'Ввод или импорт ключа API',
                    trailing: chevron,
                    onTap: () => context.go('/key'),
                  ),
                  if (!Platform.isAndroid && !Platform.isIOS)
                    SettingRow(
                      label: 'Импорт из opencode CLI',
                      sub: opencodeAuthHintPath(),
                      trailing: chevron,
                      onTap: importFromCli,
                    ),
                ],
              ),
              SettingsSection(
                title: 'Данные',
                showDivider: true,
                children: [
                  SettingRow(
                    label: 'Очистить данные',
                    sub: 'Сбросить кэш и ключ доступа',
                    danger: true,
                    trailing: chevron,
                    onTap: clearData,
                  ),
                  SettingRow(
                    label: 'О приложении',
                    sub: update.status == UpdateStatus.available
                        ? 'Доступно обновление'
                        : 'Версия и информация',
                    trailing: chevron,
                    onTap: () => context.go('/about'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

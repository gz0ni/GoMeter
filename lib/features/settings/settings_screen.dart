import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/app_theme.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'dart:io' show Platform;
import 'package:gometer/core/update/update_state.dart';
import 'package:gometer/core/utils/opencode_auth.dart';
import 'package:gometer/core/widgets/color_dot.dart';
import 'package:gometer/core/widgets/filter_chip.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Лимиты',
            children: [
              _IconTile(
                icon: Icons.schedule,
                title: 'Интервал проверки',
                subtitle: 'Как часто обновлять лимиты',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  children: [1, 3, 5].map((m) {
                    return FilterChipWidget(
                      label: '$m мин',
                      selected: settings.checkIntervalMinutes == m,
                      onSelected: (_) => notifier.setCheckInterval(m),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          _Section(
            title: 'Обновления',
            children: [
              SwitchListTile(
                secondary: _TileIcon(icon: Icons.update),
                title: const Text('Проверять обновления'),
                subtitle: const Text('Автоматически при запуске'),
                value: settings.autoCheckUpdate,
                onChanged: (v) => notifier.setAutoCheckUpdate(v),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _IconTile(
                icon: Icons.system_update_alt,
                title: 'Проверить обновления',
                subtitle: 'Поиск новой версии вручную',
                trailing: const Icon(Icons.chevron_right),
                onTap: checkForUpdate,
              ),
            ],
          ),
          _Section(
            title: 'Внешний вид',
            children: [
              _IconTile(
                icon: Icons.palette,
                title: 'Тема',
                subtitle: 'Авто, светлая или тёмная',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  children: AppThemeMode.values.map((mode) {
                    return FilterChipWidget(
                      label: switch (mode) {
                        AppThemeMode.light => 'Светлая',
                        AppThemeMode.dark => 'Тёмная',
                        AppThemeMode.system => 'Системная',
                      },
                      selected: settings.themeMode == mode,
                      onSelected: (_) => notifier.setThemeMode(mode),
                    );
                  }).toList(),
                ),
              ),
              _IconTile(
                icon: Icons.format_color_fill,
                title: 'Цвет акцента',
                subtitle: 'Основной цвет интерфейса',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 12,
                  children: AccentSeed.values.map((seed) {
                    return ColorDot(
                      isAuto: seed == AccentSeed.auto,
                      color: seed == AccentSeed.auto ? null : seed.color,
                      selected: settings.seed == seed,
                      onTap: () => notifier.setSeed(seed),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          _Section(
            title: 'Уведомления',
            children: [
              SwitchListTile(
                secondary: _TileIcon(icon: Icons.notifications_active),
                title: const Text('Показывать уведомления'),
                subtitle:
                    const Text('О достижении порогов 80% и 95%'),
                value: settings.notificationsEnabled,
                onChanged: (v) => notifier.setNotificationsEnabled(v),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                secondary: _TileIcon(icon: Icons.sensors),
                title: const Text('Порог 80%'),
                subtitle: const Text('«Почти у предела»'),
                value: settings.threshold80,
                onChanged: settings.notificationsEnabled
                    ? (v) => notifier.setThreshold80(v)
                    : null,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                secondary: _TileIcon(icon: Icons.priority_high),
                title: const Text('Порог 95%'),
                subtitle: const Text('«Близко к лимиту»'),
                value: settings.threshold95,
                onChanged: settings.notificationsEnabled
                    ? (v) => notifier.setThreshold95(v)
                    : null,
              ),
            ],
          ),
          _Section(
            title: 'Доступ',
            children: [
              _IconTile(
                icon: Icons.key,
                title: 'Ключ доступа',
                subtitle: 'Ввод или импорт ключа API',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/key'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              if (!Platform.isAndroid && !Platform.isIOS)
                _IconTile(
                  icon: Icons.file_download,
                  title: 'Импорт из opencode CLI',
                  subtitle: opencodeAuthHintPath(),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: importFromCli,
                ),
            ],
          ),
          _Section(
            title: 'Прочее',
            children: [
              _IconTile(
                icon: Icons.delete,
                title: 'Очистить данные',
                subtitle: 'Сбросить кэш и ключ доступа',
                iconColor: scheme.error,
                textColor: scheme.error,
                trailing: const Icon(Icons.chevron_right),
                onTap: clearData,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _IconTile(
                icon: Icons.info,
                title: 'О приложении',
                subtitle: update.status == UpdateStatus.available &&
                        update.info != null
                    ? 'Доступно ${update.info!.tagName}'
                    : 'Версия и информация',
                trailing: Icon(
                  Icons.chevron_right,
                  color: update.status == UpdateStatus.available
                      ? Colors.amber
                      : null,
                ),
                onTap: () => context.go('/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: scheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _IconTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _TileIcon(icon: icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _TileIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _TileIcon({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: color == null
          ? scheme.secondaryContainer
          : scheme.errorContainer,
      child: Icon(
        icon,
        color: color ?? scheme.onSecondaryContainer,
      ),
    );
  }
}

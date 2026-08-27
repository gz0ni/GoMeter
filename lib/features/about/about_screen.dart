import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gometer/core/layout/breakpoints.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/core/update/update_state.dart';
import 'package:gometer/core/widgets/app_icon.dart';
import 'package:gometer/core/widgets/page_head.dart';
import 'package:gometer/core/widgets/setting_row.dart';
import 'package:gometer/core/widgets/update_progress_dialog.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  void _startUpdate(BuildContext context, WidgetRef ref) {
    ref.read(updateControllerProvider.notifier).downloadAndInstall();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UpdateProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final update = ref.watch(updateControllerProvider);
    final hasUpdate =
        update.status == UpdateStatus.available && update.info != null;

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/settings');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: DesktopNarrow(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              PageHead(
                title: 'О приложении',
                showBack: true,
                onBack: goBack,
              ),
              const SizedBox(height: 12),
              const AppIcon(
                size: 116,
                radius: 58,
                image: 'assets/images/png/icon-512.png',
              ),
              const SizedBox(height: 10),
              Text(
                'GoMeter',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version =
                      snapshot.hasData ? snapshot.data!.version : '...';
                  return Text(
                    'Версия $version',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  );
                },
              ),
              if (hasUpdate) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.system_update,
                        size: 22,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Доступно обновление',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: scheme.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${update.info!.tagName} · улучшенная работа с лимитами',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => _startUpdate(context, ref),
                        child: const Text('Обновить'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SettingsSection(
                title: 'Доступ',
                children: [
                  SettingRow(
                    label: 'OpenCode Go',
                    sub: 'opencode.ai/go',
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    onTap: () => _openUrl('https://opencode.ai/go'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isMobile ? 'Windows · Linux · macOS · Android' : 'Windows · Linux · macOS',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '© 2026 GoMeter. Данные об использовании не покидают устройство.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

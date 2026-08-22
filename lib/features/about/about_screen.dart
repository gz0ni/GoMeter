import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/core/update/update_state.dart';
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

    return Scaffold(
      appBar: AppBar(
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/settings'),
              )
            : null,
        title: const Text('О приложении'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    Icons.speed,
                    size: 40,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'GoMeter',
                  style: TextStyle(fontSize: 24),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version =
                        snapshot.hasData ? snapshot.data!.version : '...';
                    return Text(
                      'Версия $version · мокап',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (hasUpdate) ...[
            const SizedBox(height: 16),
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.system_update,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Доступно обновление',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '${update.info!.tagName} · нажмите, чтобы загрузить',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _startUpdate(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            scheme.onPrimaryContainer.withValues(alpha: 0.15),
                        foregroundColor: scheme.onPrimaryContainer,
                      ),
                      child: const Text('Обновить'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Трекер лимитов подписки OpenCode Go — показывает, сколько осталось в 5-часовом, недельном и месячном окнах, и предупреждает, когда лимит близок.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('OpenCode Go'),
                  subtitle: const Text('opencode.ai/go'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl('https://opencode.ai/go'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Material Design 3'),
                  subtitle: Text('Google · светлая и тёмная темы'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Сделано с заботой'),
                  subtitle: Text('Flutter · Windows, Linux, macOS, Android'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Платформы',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              _PlatformChip(icon: Icons.desktop_windows, label: 'Windows'),
              _PlatformChip(icon: Icons.computer, label: 'Linux'),
              _PlatformChip(icon: Icons.laptop_mac, label: 'macOS'),
              _PlatformChip(icon: Icons.phone_android, label: 'Android'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 GoMeter. Данные об использовании не покидают устройство.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlatformChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

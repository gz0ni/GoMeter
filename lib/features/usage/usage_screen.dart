import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/core/update/update_state.dart';
import 'package:gometer/core/widgets/brand_logo.dart';
import 'package:gometer/core/widgets/limit_card.dart';
import 'package:gometer/core/widgets/status_chip.dart';
import 'package:gometer/core/widgets/update_banner.dart';
import 'package:gometer/core/widgets/update_progress_dialog.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';

class UsageScreen extends ConsumerWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(usageProvider);
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final update = ref.watch(updateControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final appBar = AppBar(
      title: const BrandLogo(),
      actions: const [
        _RefreshButton(),
        _KeyButton(),
      ],
    );

    return usageAsync.when(
      data: (limits) {
        final worst = limits.isNotEmpty
            ? limits.reduce(
                (a, b) => a.remainingPercent < b.remainingPercent ? a : b,
              )
            : null;

        final showBanner = update.status == UpdateStatus.available &&
            !settings.bannerDismissed &&
            update.info != null;

        return Scaffold(
          appBar: appBar,
          body: limits.isEmpty
              ? _EmptyBody(
                  message: 'Нет данных о лимитах',
                  onRefresh: () => ref.read(usageProvider.notifier).refresh(),
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  children: [
                    if (showBanner)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UpdateBanner(
                          version: update.info!.tagName,
                          subtitle: 'Улучшенная работа с лимитами',
                          onUpdate: () => _startUpdate(context, ref),
                          onDismiss: () => ref
                              .read(settingsProvider.notifier)
                              .setBannerDismissed(true),
                        ),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: StatusChip(level: worst!.level),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        spacing: 12,
                        children: limits.map((l) => LimitCard(limit: l)).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Обновлено недавно · проверка каждые ${settings.checkIntervalMinutes} мин',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        );
      },
      loading: () => Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: appBar,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Не удалось загрузить лимиты: $e'),
                const SizedBox(height: 16),
                _RefreshButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startUpdate(BuildContext context, WidgetRef ref) {
    ref.read(updateControllerProvider.notifier).downloadAndInstall();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UpdateProgressDialog(),
    );
  }
}

class _RefreshButton extends ConsumerStatefulWidget {
  const _RefreshButton();

  @override
  ConsumerState<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _controller.forward(from: 0);
    await ref.read(usageProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: 'Обновить',
        onPressed: _refresh,
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.key),
      tooltip: 'Ключ доступа',
      onPressed: () => context.go('/key'),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;

  const _EmptyBody({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
}

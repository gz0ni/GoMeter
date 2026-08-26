import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/layout/breakpoints.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/widgets/limit_card.dart';
import 'package:gometer/core/widgets/page_head.dart';
import 'package:gometer/core/widgets/push_card.dart';
import 'package:gometer/core/widgets/status_card.dart';
import 'package:gometer/core/widgets/section_title.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/push_cards_provider.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';

class UsageScreen extends ConsumerWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(usageProvider);
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final pushes = ref.watch(pushCardsProvider);
    final isDesktop = isDesktopLayout(context);

    final head = PageHead(
      title: 'Лимиты',
      actions: [
        const _RefreshButton(),
        _KeyButton(),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 640 : 440),
            child: usageAsync.when(
              data: (data) {
                final worst = data.isEmpty
                    ? null
                    : data.reduce(
                        (a, b) => a.remainingPercent < b.remainingPercent
                            ? a
                            : b,
                      );

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 24,
                    24,
                    isDesktop ? 32 : 24,
                    48,
                  ),
                  children: [
                    head,
                    const SizedBox(height: 16),
                    if (pushes.isNotEmpty) ...[
                      for (final card in pushes) ...[
                        PushCardTile(
                          card: card,
                          onDismiss: () => ref
                              .read(pushCardsProvider.notifier)
                              .dismiss(card.id),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 6),
                    ],
                    if (data.isEmpty)
                      _EmptyBody(
                        message: 'Нет данных о лимитах',
                        onRefresh: () =>
                            ref.read(usageProvider.notifier).refresh(),
                      )
                    else ...[
                      _buildCards(data, isDesktop),
                      const SizedBox(height: 18),
                      const SectionTitle(title: 'Статус'),
                      const SizedBox(height: 10),
                      StatusCard(
                        level: worst!.level,
                        windowName: worst.name,
                        percent: worst.percent,
                        resetInSeconds: worst.resetInSeconds,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Обновлено недавно · проверка каждые ${settings.checkIntervalMinutes} мин',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  head,
                  const SizedBox(height: 60),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
              error: (e, _) => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  head,
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Не удалось загрузить лимиты: $e'),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              ref.read(usageProvider.notifier).refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Обновить'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(List<UsageLimit> limits, bool isDesktop) {
    if (!isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, limit) in limits.indexed) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: LimitCard(limit: limit)),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const minCardWidth = 180.0;
        const gap = 12.0;
        final width = constraints.maxWidth;
        final columns =
            (width / minCardWidth).floor().clamp(1, limits.length).toInt();
        final cardWidth =
            ((width - gap * (columns - 1)) / columns).toDouble();

        return Wrap(
          spacing: gap,
          runSpacing: 12,
          children: [
            for (final limit in limits)
              SizedBox(width: cardWidth, child: LimitCard(limit: limit)),
          ],
        );
      },
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
        iconSize: 22,
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
      icon: const Icon(Icons.key_outlined),
      iconSize: 22,
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
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
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
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/push_cards_provider.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUsageNotifier extends UsageNotifier {
  @override
  Future<List<UsageLimit>> build() async => [
    UsageLimit(
      id: 'rolling',
      name: '5 часов',
      window: 'Скользящее окно',
      percent: 81,
      resetAt: DateTime.now().toUtc().add(const Duration(hours: 14)),
    ),
    UsageLimit(
      id: 'weekly',
      name: '7 дней',
      window: 'Неделя',
      percent: 96,
      resetAt: DateTime.now().toUtc().add(const Duration(days: 2)),
    ),
    UsageLimit(
      id: 'monthly',
      name: '30 дней',
      window: 'Месяц',
      percent: 16,
      resetAt: DateTime.now().toUtc().add(const Duration(days: 30)),
    ),
  ];
}

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final repo = await SettingsRepository.create();
  return ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
      usageProvider.overrideWith(() => _FakeUsageNotifier()),
      notificationHistoryProvider.overrideWithValue(
        NotificationHistory(await SharedPreferences.getInstance()),
      ),
    ],
  );
}

void main() {
  test(
    'creates a live card per enabled threshold using the worst window',
    () async {
      final container = await _container();
      addTearDown(container.dispose);
      await container.read(settingsProvider.future);
      await container.read(usageProvider.future);

      final cards = container.read(pushCardsProvider);
      await container.pump();

      expect(cards, hasLength(2));
      expect(cards[0].threshold, 80);
      expect(cards[0].windowId, 'weekly');
      expect(cards[0].title, 'Лимит 80% · 7 дней');
      expect(cards[1].threshold, 95);
      expect(cards[1].windowId, 'weekly');
      expect(cards[1].title, 'Лимит 95% · 7 дней');
    },
  );

  test('master switch disables all cards', () async {
    final container = await _container(prefs: {'notificationsEnabled': false});
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);
    await container.read(usageProvider.future);

    expect(container.read(pushCardsProvider), isEmpty);
  });

  test('disabled threshold does not produce a card', () async {
    final container = await _container(prefs: {'threshold80': false});
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);
    await container.read(usageProvider.future);

    final cards = container.read(pushCardsProvider);

    expect(cards, hasLength(1));
    expect(cards.single.threshold, 95);
  });

  test('dismiss removes the card and persists across rebuilds', () async {
    final container = await _container();
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);
    await container.read(usageProvider.future);

    final cards = container.read(pushCardsProvider);
    await container.read(pushCardsProvider.notifier).dismiss(cards.first.id);
    await container.pump();

    final afterDismiss = container.read(pushCardsProvider);
    expect(afterDismiss, hasLength(1));
    expect(afterDismiss.single.id, cards.last.id);

    container.invalidate(pushCardsProvider);
    await container.pump();

    expect(container.read(pushCardsProvider), hasLength(1));
  });
}

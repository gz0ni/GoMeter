import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/notifications/notification_service.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/limit_monitor.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';
import 'package:gometer/features/usage/services/usage_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService implements NotificationService {
  final shows = <(String, String)>[];

  @override
  Future<void> init() async {}

  @override
  Future<void> show({required String title, required String body}) async {
    shows.add((title, body));
  }
}

class _FakeUsageApiService extends UsageApiService {
  _FakeUsageApiService(this.limits) : super(Dio());

  List<UsageLimit> limits;

  @override
  Future<List<UsageLimit>> fetch(String apiKey) async => limits;
}

List<UsageLimit> _limits({int rolling = 81, int weekly = 96}) => [
  UsageLimit(
    id: 'rolling',
    name: '5 часов',
    window: 'Скользящее окно',
    percent: rolling,
    resetAt: DateTime.now().toUtc().add(const Duration(hours: 14)),
  ),
  UsageLimit(
    id: 'weekly',
    name: '7 дней',
    window: 'Неделя',
    percent: weekly,
    resetAt: DateTime.now().toUtc().add(const Duration(days: 2)),
  ),
];

Future<(ProviderContainer, _FakeNotificationService, _FakeUsageApiService)>
_start({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues({'apiKey': 'sk-test', ...prefs});
  final repo = await SettingsRepository.create();
  final notifications = _FakeNotificationService();
  final api = _FakeUsageApiService(_limits());
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
      usageApiServiceProvider.overrideWithValue(api),
      notificationsServiceProvider.overrideWithValue(notifications),
      notificationHistoryProvider.overrideWithValue(
        NotificationHistory(await SharedPreferences.getInstance()),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(settingsProvider.future);
  container.listen(limitMonitorProvider, (_, _) {});
  container.listen(usageProvider, (_, _) {});
  await container.pump();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return (container, notifications, api);
}

void main() {
  test('notifies once per threshold when usage crosses it', () async {
    final (_, notifications, _) = await _start();

    expect(notifications.shows, hasLength(2));
    expect(notifications.shows[0].$1, 'Лимит 80% · 7 дней');
    expect(notifications.shows[1].$2, contains('Осталось 4%'));
  });

  test(
    'does not re-notify while the limit stays above the threshold',
    () async {
      final (container, notifications, api) = await _start();

      api.limits = _limits(rolling: 90, weekly: 98);
      await container.read(usageProvider.notifier).refresh();
      await container.pump();

      expect(notifications.shows, hasLength(2));
    },
  );

  test('notifies a new window after it resets', () async {
    final (container, notifications, api) = await _start();

    api.limits = [
      UsageLimit(
        id: 'rolling',
        name: '5 часов',
        window: 'Скользящее окно',
        percent: 10,
        resetAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      UsageLimit(
        id: 'weekly',
        name: '7 дней',
        window: 'Неделя',
        percent: 96,
        resetAt: DateTime.now().toUtc().add(const Duration(days: 3)),
      ),
    ];
    await container.read(usageProvider.notifier).refresh();
    await container.pump();

    api.limits = _limits(rolling: 82);
    await container.read(usageProvider.notifier).refresh();
    await container.pump();

    expect(
      notifications.shows.where((s) => s.$1.contains('80%')),
      hasLength(2),
    );
  });

  test('master switch disables notifications entirely', () async {
    final (_, notifications, _) = await _start(
      prefs: {'notificationsEnabled': false},
    );

    expect(notifications.shows, isEmpty);
  });

  test('disabled threshold never notifies', () async {
    final (_, notifications, _) = await _start(prefs: {'threshold80': false});

    expect(notifications.shows, hasLength(1));
    expect(notifications.shows.single.$1, 'Лимит 95% · 7 дней');
  });
}

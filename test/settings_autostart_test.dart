import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/autostart/autostart_service.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAutostartService implements AutostartService {
  final calls = <String>[];
  final quietFlags = <bool>[];
  bool enabled = false;

  @override
  bool get isSupported => true;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> enable({bool quiet = false}) async {
    calls.add('enable');
    quietFlags.add(quiet);
    enabled = true;
  }

  @override
  Future<void> disable() async {
    calls.add('disable');
    enabled = false;
  }
}

void main() {
  late _FakeAutostartService service;
  late ProviderContainer container;

  Future<void> startApp({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final repo = await SettingsRepository.create();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        autostartServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);
  }

  setUp(() {
    service = _FakeAutostartService();
  });

  test('setAutostart(true) enables OS autostart and persists', () async {
    await startApp();

    await container.read(settingsProvider.notifier).setAutostart(true);
    await container.pump();

    expect(service.calls, ['enable']);
    expect(service.quietFlags, [false]);
    expect(container.read(settingsProvider).value!.autostart, isTrue);
  });

  test('setAutostart(true) passes quiet flag when quietStart is on',
      () async {
    await startApp(prefs: {'quietStart': true});

    await container.read(settingsProvider.notifier).setAutostart(true);
    await container.pump();

    expect(service.calls, ['enable']);
    expect(service.quietFlags, [true]);
  });

  test('setAutostart(false) disables OS autostart and persists', () async {
    await startApp(prefs: {'autostart': true});

    await container.read(settingsProvider.notifier).setAutostart(false);
    await container.pump();

    expect(service.calls, ['disable']);
    expect(container.read(settingsProvider).value!.autostart, isFalse);
  });

  test('setQuietStart(true) re-registers autostart with quiet flag',
      () async {
    await startApp(prefs: {'autostart': true});

    await container.read(settingsProvider.notifier).setQuietStart(true);
    await container.pump();

    expect(service.calls, ['enable']);
    expect(service.quietFlags, [true]);
    expect(container.read(settingsProvider).value!.quietStart, isTrue);
  });

  test('setQuietStart(true) without autostart does not touch the OS',
      () async {
    await startApp();

    await container.read(settingsProvider.notifier).setQuietStart(true);
    await container.pump();

    expect(service.calls, isEmpty);
    expect(container.read(settingsProvider).value!.quietStart, isTrue);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/core/settings/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('Override in main() with initialized repository');
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async =>
      ref.read(settingsRepositoryProvider).load();

  Future<void> _update(AppSettings Function(AppSettings) fn) async {
    final repo = ref.read(settingsRepositoryProvider);
    final current = await future;
    final next = fn(current);
    await repo.save(next);
    state = AsyncData(next);
  }

  Future<void> setThemeMode(AppThemeMode value) =>
      _update((s) => s.copyWith(themeMode: value));

  Future<void> setSeed(AccentSeed value) =>
      _update((s) => s.copyWith(seed: value));

  Future<void> setApiKey(String value) =>
      _update((s) => s.copyWith(apiKey: value));

  Future<void> setCheckInterval(int value) =>
      _update((s) => s.copyWith(checkIntervalMinutes: value));

  Future<void> setNotificationsEnabled(bool value) =>
      _update((s) => s.copyWith(notificationsEnabled: value));

  Future<void> setThreshold80(bool value) =>
      _update((s) => s.copyWith(threshold80: value));

  Future<void> setThreshold95(bool value) =>
      _update((s) => s.copyWith(threshold95: value));

  Future<void> setBannerDismissed(bool value) =>
      _update((s) => s.copyWith(bannerDismissed: value));

  Future<void> setAutoCheckUpdate(bool value) =>
      _update((s) => s.copyWith(autoCheckUpdate: value));

  Future<void> reset() => _update((_) => const AppSettings());
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

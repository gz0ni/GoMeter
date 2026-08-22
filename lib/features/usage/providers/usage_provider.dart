import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/services/usage_api_service.dart';

final usageProvider =
    AsyncNotifierProvider<UsageNotifier, List<UsageLimit>>(UsageNotifier.new);

class UsageNotifier extends AsyncNotifier<List<UsageLimit>> {
  Timer? _countdownTimer;
  Timer? _pollTimer;

  @override
  Future<List<UsageLimit>> build() async {
    _cleanup();
    final settings = ref.watch(settingsProvider);
    final apiKey = settings.value?.apiKey ?? '';
    if (apiKey.isEmpty) return [];

    final intervalMinutes = settings.value?.checkIntervalMinutes ?? 5;
    _startTimers(apiKey, intervalMinutes);

    return _fetch(apiKey);
  }

  void _cleanup() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _countdownTimer = null;
    _pollTimer = null;
  }

  void _startTimers(String apiKey, int intervalMinutes) {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
    _pollTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => unawaited(_fetchAndUpdate(apiKey)),
    );
    ref.onDispose(_cleanup);
  }

  void _tick() {
    if (state.hasValue) {
      try {
        state = AsyncData(List.of(state.value!));
      } catch (_) {}
    }
  }

  Future<void> _fetchAndUpdate(String apiKey) async {
    try {
      final limits = await _fetch(apiKey);
      try {
        state = AsyncData(limits);
      } catch (_) {}
    } catch (e, st) {
      try {
        if (!state.hasValue) state = AsyncError(e, st);
      } catch (_) {}
    }
  }

  Future<List<UsageLimit>> _fetch(String apiKey) async {
    final service = ref.read(usageApiServiceProvider);
    return service.fetch(apiKey);
  }

  Future<void> refresh() async {
    final apiKey = ref.read(settingsProvider).value?.apiKey ?? '';
    if (apiKey.isEmpty) return;
    return _fetchAndUpdate(apiKey);
  }
}

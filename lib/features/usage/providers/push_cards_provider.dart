import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/features/usage/logic/threshold_logic.dart';
import 'package:gometer/features/usage/models/push_card.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';

final pushCardsProvider = NotifierProvider<PushCardsController, List<PushCard>>(
  PushCardsController.new,
);

class PushCardsController extends Notifier<List<PushCard>> {
  NotificationHistory? _history;

  @override
  List<PushCard> build() {
    _history = ref.read(notificationHistoryProvider);
    ref.watch(settingsProvider);
    ref.listen(usageProvider, (_, _) => _recompute());
    return _compute();
  }

  Future<void> dismiss(String id) async {
    await _history?.dismissPushCard(id);
    _recompute();
  }

  void _recompute() {
    state = _compute();
  }

  List<PushCard> _compute() {
    final settings = ref.read(settingsProvider).value;
    if (settings == null || !settings.notificationsEnabled) return const [];

    final thresholds = <int>{
      if (settings.threshold80) 80,
      if (settings.threshold95) 95,
    };
    if (thresholds.isEmpty) return const [];

    final usage = ref.read(usageProvider);
    if (!usage.hasValue) return const [];

    return buildPushCards(
      usage.value!,
      enabledThresholds: thresholds,
      dismissedIds: _history?.dismissedPushCards ?? const {},
    );
  }
}

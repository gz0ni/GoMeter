import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/notifications/notification_service.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/tray/tray_controller.dart';
import 'package:gometer/features/usage/logic/threshold_logic.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';

final limitMonitorProvider = NotifierProvider<LimitMonitor, LimitMonitorState>(
  LimitMonitor.new,
);

class LimitMonitorState {
  final List<UsageLimit>? lastLimits;

  const LimitMonitorState({this.lastLimits});
}

class LimitMonitor extends Notifier<LimitMonitorState> {
  NotificationHistory? _history;

  @override
  LimitMonitorState build() {
    _history = ref.read(notificationHistoryProvider);
    ref.listen(usageProvider, _onUsage);
    return const LimitMonitorState();
  }

  void _onUsage(
    AsyncValue<List<UsageLimit>>? previous,
    AsyncValue<List<UsageLimit>> next,
  ) {
    final limits = next.value;
    if (limits == null) return;

    final settings = ref.read(settingsProvider).value;
    if (settings == null) return;

    final thresholds = <int>{
      if (settings.threshold80) 80,
      if (settings.threshold95) 95,
    };
    if (settings.notificationsEnabled && thresholds.isNotEmpty) {
      final prev = previous?.value ?? state.lastLimits;
      for (final threshold in thresholds) {
        UsageLimit? worst;
        for (final limit in limits) {
          if (limit.percent < threshold) continue;
          final prevPercent = _percentFor(prev, limit.id);
          if (!crossedThreshold(
            prevPercent: prevPercent,
            currentPercent: limit.percent,
            threshold: threshold,
          )) {
            continue;
          }
          if (worst == null || limit.percent > worst.percent) {
            worst = limit;
          }
        }
        if (worst != null) {
          unawaited(_notify(worst, threshold));
        }
      }
    }

    unawaited(
      TrayController.instance.updateTooltip(buildTrayTooltip(limits)),
    );
    state = LimitMonitorState(lastLimits: limits);
  }

  int? _percentFor(List<UsageLimit>? limits, String windowId) {
    for (final limit in limits ?? const <UsageLimit>[]) {
      if (limit.id == windowId) return limit.percent;
    }
    return null;
  }

  Future<void> _notify(UsageLimit limit, int threshold) async {
    final history = _history;
    if (history == null) return;
    final now = DateTime.now();
    if (history.hasNotified(limit.id, threshold, limit.resetAt, now: now)) {
      return;
    }
    await history.markNotified(limit.id, threshold, limit.resetAt, now: now);
    try {
      await ref
          .read(notificationsServiceProvider)
          .show(
            title: notificationTitle(threshold, limit.name),
            body: notificationBody(limit),
          );
    } catch (_) {
      // best-effort
    }
  }
}

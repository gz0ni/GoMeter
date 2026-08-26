import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationHistoryProvider = Provider<NotificationHistory>((ref) {
  throw UnimplementedError('Override in main() with initialized history');
});

class NotificationHistory {
  final SharedPreferences _prefs;

  NotificationHistory(this._prefs);

  static const _notifiedPrefix = 'notified-';
  static const _dismissedKey = 'dismissedPushCards';

  String resetKey(DateTime? resetAt, DateTime now) {
    if (resetAt != null) {
      return resetAt.toUtc().millisecondsSinceEpoch.toString();
    }
    final utc = now.toUtc();
    return '${utc.year}-${utc.month}-${utc.day}';
  }

  bool hasNotified(
    String windowId,
    int threshold,
    DateTime? resetAt, {
    DateTime? now,
  }) {
    final key = _notifiedKey(windowId, threshold, resetAt, now);
    return _prefs.getBool(key) ?? false;
  }

  Future<void> markNotified(
    String windowId,
    int threshold,
    DateTime? resetAt, {
    DateTime? now,
  }) async {
    final key = _notifiedKey(windowId, threshold, resetAt, now);
    await _prefs.setBool(key, true);
  }

  Set<String> get dismissedPushCards =>
      (_prefs.getStringList(_dismissedKey) ?? const []).toSet();

  Future<void> dismissPushCard(String id) async {
    final dismissed = dismissedPushCards..add(id);
    await _prefs.setStringList(_dismissedKey, dismissed.toList()..sort());
  }

  String _notifiedKey(
    String windowId,
    int threshold,
    DateTime? resetAt,
    DateTime? now,
  ) {
    return '$_notifiedPrefix$windowId-$threshold-'
        '${resetKey(resetAt, now ?? DateTime.now())}';
  }
}

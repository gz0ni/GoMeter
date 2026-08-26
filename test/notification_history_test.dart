import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NotificationHistory history;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    history = NotificationHistory(await SharedPreferences.getInstance());
  });

  group('notification anti-spam', () {
    test('starts unnotified and persists the mark', () async {
      final resetAt = DateTime.utc(2026, 8, 26, 12);

      expect(
        history.hasNotified('rolling', 80, resetAt, now: DateTime(2026, 8, 26)),
        isFalse,
      );

      await history.markNotified(
        'rolling',
        80,
        resetAt,
        now: DateTime(2026, 8, 26),
      );

      expect(
        history.hasNotified('rolling', 80, resetAt, now: DateTime(2026, 8, 26)),
        isTrue,
      );
    });

    test('different windows and thresholds are independent', () async {
      final resetAt = DateTime.utc(2026, 8, 26, 12);

      await history.markNotified('rolling', 80, resetAt);

      expect(history.hasNotified('weekly', 80, resetAt), isFalse);
      expect(history.hasNotified('rolling', 95, resetAt), isFalse);
      expect(history.hasNotified('rolling', 80, resetAt), isTrue);
    });

    test('new resetsAt re-arms the notification', () async {
      final firstReset = DateTime.utc(2026, 8, 26, 12);
      final secondReset = DateTime.utc(2026, 8, 30, 18);

      await history.markNotified('weekly', 95, firstReset);

      expect(history.hasNotified('weekly', 95, firstReset), isTrue);
      expect(history.hasNotified('weekly', 95, secondReset), isFalse);
    });

    test('null resetsAt falls back to a daily key', () async {
      final now = DateTime(2026, 8, 26, 20);

      await history.markNotified('monthly', 80, null, now: now);

      expect(history.hasNotified('monthly', 80, null, now: now), isTrue);
      expect(
        history.hasNotified('monthly', 80, null, now: DateTime(2026, 8, 27, 8)),
        isFalse,
      );
    });
  });

  group('dismissed push cards', () {
    test('dismiss persists a card id', () async {
      await history.dismissPushCard('80-rolling-123');
      await history.dismissPushCard('95-weekly-456');

      expect(
        history.dismissedPushCards,
        containsAll(['80-rolling-123', '95-weekly-456']),
      );
    });

    test('dismiss is idempotent', () async {
      await history.dismissPushCard('80-rolling-123');
      await history.dismissPushCard('80-rolling-123');

      expect(history.dismissedPushCards, hasLength(1));
    });
  });
}

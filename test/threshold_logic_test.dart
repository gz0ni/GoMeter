import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/features/usage/logic/threshold_logic.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';

UsageLimit _limit({
  required String id,
  required int percent,
  DateTime? resetAt,
  String name = 'окно',
}) => UsageLimit(
  id: id,
  name: name,
  window: 'window',
  percent: percent,
  resetAt: resetAt,
);

void main() {
  group('crossedThreshold', () {
    test('first observation at or above threshold notifies', () {
      expect(
        crossedThreshold(prevPercent: null, currentPercent: 81, threshold: 80),
        isTrue,
      );
      expect(
        crossedThreshold(prevPercent: null, currentPercent: 95, threshold: 95),
        isTrue,
      );
    });

    test('below threshold never notifies', () {
      expect(
        crossedThreshold(prevPercent: null, currentPercent: 79, threshold: 80),
        isFalse,
      );
      expect(
        crossedThreshold(prevPercent: 79, currentPercent: 79, threshold: 80),
        isFalse,
      );
      expect(
        crossedThreshold(prevPercent: 90, currentPercent: 92, threshold: 95),
        isFalse,
      );
    });

    test('notifies exactly when percent crosses the threshold upward', () {
      expect(
        crossedThreshold(prevPercent: 79, currentPercent: 81, threshold: 80),
        isTrue,
      );
      expect(
        crossedThreshold(prevPercent: 94, currentPercent: 96, threshold: 95),
        isTrue,
      );
    });

    test('does not re-notify while staying above the threshold', () {
      expect(
        crossedThreshold(prevPercent: 81, currentPercent: 90, threshold: 80),
        isFalse,
      );
      expect(
        crossedThreshold(prevPercent: 96, currentPercent: 97, threshold: 95),
        isFalse,
      );
    });
  });

  group('notification texts', () {
    test('title mentions threshold and window', () {
      expect(notificationTitle(80, '7 дней'), 'Лимит 80% · 7 дней');
    });

    test('body mentions remaining percent and reset', () {
      final limit = _limit(id: 'weekly', percent: 81, name: '7 дней');
      expect(
        notificationBody(limit),
        'Осталось 19%. Окно сбросится примерно через 0 сек.',
      );
    });
  });

  group('buildPushCards', () {
    test(
      'creates a card for each enabled threshold using the worst window',
      () {
        final limits = [
          _limit(id: 'rolling', percent: 81, name: '5 часов'),
          _limit(id: 'weekly', percent: 96, name: '7 дней'),
          _limit(id: 'monthly', percent: 16, name: '30 дней'),
        ];

        final cards = buildPushCards(
          limits,
          enabledThresholds: const {80, 95},
          dismissedIds: const {},
        );

        expect(cards, hasLength(2));
        expect(cards[0].threshold, 80);
        expect(cards[0].windowName, '7 дней');
        expect(cards[0].percent, 96);
        expect(cards[0].title, 'Лимит 80% · 7 дней');
        expect(cards[1].threshold, 95);
        expect(cards[1].windowId, 'weekly');
      },
    );

    test('skips thresholds that no window reaches', () {
      final limits = [_limit(id: 'rolling', percent: 81)];

      final cards = buildPushCards(
        limits,
        enabledThresholds: const {80, 95},
        dismissedIds: const {},
      );

      expect(cards, hasLength(1));
      expect(cards.single.threshold, 80);
    });

    test('skips dismissed card ids', () {
      final limits = [_limit(id: 'rolling', percent: 81)];
      final id = pushCardId(
        threshold: 80,
        windowId: 'rolling',
        resetKey: resetKeyOf(limits.single, DateTime.utc(2026)),
      );

      final cards = buildPushCards(
        limits,
        enabledThresholds: const {80},
        dismissedIds: {id},
        now: DateTime.utc(2026),
      );

      expect(cards, isEmpty);
    });

    test('produces a fresh id after the window resets', () {
      final before = _limit(
        id: 'rolling',
        percent: 81,
        resetAt: DateTime(2026, 1, 1),
      );
      final after = _limit(
        id: 'rolling',
        percent: 90,
        resetAt: DateTime(2026, 1, 2),
      );

      final idBefore = pushCardId(
        threshold: 80,
        windowId: 'rolling',
        resetKey: resetKeyOf(before, DateTime.now()),
      );
      final idAfter = pushCardId(
        threshold: 80,
        windowId: 'rolling',
        resetKey: resetKeyOf(after, DateTime.now()),
      );

      expect(idBefore, isNot(idAfter));
    });

    test('falls back to a daily reset key when resetAt is null', () {
      final limit = _limit(id: 'rolling', percent: 81);
      final key1 = resetKeyOf(limit, DateTime.utc(2026, 7, 10, 4, 30));
      final key2 = resetKeyOf(limit, DateTime.utc(2026, 7, 10, 23, 59));
      final key3 = resetKeyOf(limit, DateTime.utc(2026, 7, 11));

      expect(key1, key2);
      expect(key1, isNot(key3));
    });
  });
}

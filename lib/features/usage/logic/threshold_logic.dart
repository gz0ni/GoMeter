import 'package:gometer/features/usage/models/push_card.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/utils/duration_format.dart';

const listOfLimitThresholds = [80, 95];

bool crossedThreshold({
  required int? prevPercent,
  required int currentPercent,
  required int threshold,
}) {
  if (currentPercent < threshold) return false;
  return prevPercent == null || prevPercent < threshold;
}

String notificationTitle(int threshold, String windowName) =>
    'Лимит $threshold% · $windowName';

String notificationBody(UsageLimit limit) =>
    'Осталось ${limit.remainingPercent}%. Окно сбросится примерно через '
    '${formatDuration(limit.resetInSeconds)}.';

String pushCardId({
  required int threshold,
  required String windowId,
  required String resetKey,
}) => '$threshold-$windowId-$resetKey';

List<PushCard> buildPushCards(
  List<UsageLimit> limits, {
  required Set<int> enabledThresholds,
  required Set<String> dismissedIds,
  DateTime? now,
}) {
  final cards = <PushCard>[];
  for (final threshold in enabledThresholds) {
    final over = limits.where((l) => l.percent >= threshold).toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));
    if (over.isEmpty) continue;
    final worst = over.first;
    final id = pushCardId(
      threshold: threshold,
      windowId: worst.id,
      resetKey: resetKeyOf(worst, now),
    );
    if (dismissedIds.contains(id)) continue;
    cards.add(
      PushCard(
        id: id,
        threshold: threshold,
        windowId: worst.id,
        windowName: worst.name,
        percent: worst.percent,
        resetInSeconds: worst.resetInSeconds,
        title: notificationTitle(threshold, worst.name),
        text: notificationBody(worst),
      ),
    );
  }
  return cards;
}

String resetKeyOf(UsageLimit limit, DateTime? now) {
  final resetAt = limit.resetAt;
  if (resetAt != null) {
    return resetAt.toUtc().millisecondsSinceEpoch.toString();
  }
  final utc = (now ?? DateTime.now()).toUtc();
  return '${utc.year}-${utc.month}-${utc.day}';
}

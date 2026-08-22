String formatDuration(int seconds) {
  if (seconds < 0) seconds = 0;
  final d = seconds ~/ 86400;
  final h = (seconds % 86400) ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;

  if (d > 0) return '$d дн $h:${m.toString().padLeft(2, '0')}';
  if (h > 0) return '$h ч ${m.toString().padLeft(2, '0')} мин';
  if (m > 0) return '$m мин ${s.toString().padLeft(2, '0')} сек';
  return '$s сек';
}

import 'package:gometer/core/theme/app_extra_colors.dart';

class UsageLimit {
  final String id;
  final String name;
  final String window;
  final int percent;
  final DateTime? resetAt;

  const UsageLimit({
    required this.id,
    required this.name,
    required this.window,
    required this.percent,
    this.resetAt,
  });

  int get resetInSeconds {
    final at = resetAt;
    if (at == null) return 0;
    final diff = at.difference(DateTime.now().toUtc()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  int get remainingPercent => 100 - percent;

  UsageLevel get level => levelFor(remainingPercent);
}

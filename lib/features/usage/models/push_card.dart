class PushCard {
  final String id;
  final int threshold;
  final String windowId;
  final String windowName;
  final int percent;
  final int resetInSeconds;
  final String title;
  final String text;

  const PushCard({
    required this.id,
    required this.threshold,
    required this.windowId,
    required this.windowName,
    required this.percent,
    required this.resetInSeconds,
    required this.title,
    required this.text,
  });
}

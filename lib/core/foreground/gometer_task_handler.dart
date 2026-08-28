import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(GoMeterTaskHandler());
}

class GoMeterTaskHandler extends TaskHandler {
  FlutterLocalNotificationsPlugin? _notifications;
  bool _notifInitialized = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _ensureNotifInitialized();
    await _checkLimits();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    unawaited(_checkLimits());
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  Future<void> _ensureNotifInitialized() async {
    if (_notifInitialized) return;
    _notifications = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_gometer'),
    );
    try {
      await _notifications!.initialize(settings: settings);
      _notifInitialized = true;
    } catch (_) {}
  }

  Future<void> _checkLimits() async {
    try {
      await _ensureNotifInitialized();
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final apiKey = prefs.getString('apiKey') ?? '';
      if (apiKey.isEmpty) return;
      final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      if (!notificationsEnabled) return;

      final thresholds = <int>{
        if (prefs.getBool('threshold80') ?? true) 80,
        if (prefs.getBool('threshold95') ?? true) 95,
      };
      if (thresholds.isEmpty) return;

      final dio = Dio(
        BaseOptions(
          headers: {'User-Agent': 'GoMeter'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final response = await dio.get<Map<String, dynamic>>(
        'https://opencode.ai/zen/go/v1/usage',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode != 200 || response.data == null) return;
      final usage = response.data!['usage'] as Map<String, dynamic>? ?? {};
      final now = DateTime.now().toUtc();

      final limits = [
        _parseWindow(
          id: 'rolling',
          name: '5 часов',
          window: 'Скользящее окно',
          json: usage['rolling'] as Map<String, dynamic>? ??
              usage['rolling5h'] as Map<String, dynamic>?,
          now: now,
        ),
        _parseWindow(
          id: 'weekly',
          name: '7 дней',
          window: 'Неделя',
          json: usage['weekly'] as Map<String, dynamic>?,
          now: now,
        ),
        _parseWindow(
          id: 'monthly',
          name: '30 дней',
          window: 'Месяц',
          json: usage['monthly'] as Map<String, dynamic>?,
          now: now,
        ),
      ];

      final tooltip = _buildTooltip(limits);
      await FlutterForegroundTask.updateService(notificationText: tooltip);

      for (final threshold in thresholds) {
        _UsageLimit? worst;
        for (final limit in limits) {
          if (limit.percent < threshold) continue;
          if (worst == null || limit.percent > worst.percent) {
            worst = limit;
          }
        }
        if (worst == null) continue;
        if (_hasNotified(prefs, worst.id, threshold, worst.resetAt, now)) {
          continue;
        }
        await _markNotified(prefs, worst.id, threshold, worst.resetAt, now);
        await _showAlert(worst, threshold);
      }
    } catch (_) {}
  }

  Future<void> _showAlert(_UsageLimit limit, int threshold) async {
    final plugin = _notifications;
    if (plugin == null) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'limit_warnings',
        'Напоминания о лимитах',
        channelDescription: 'Уведомления о пересечении порогов лимитов',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    final title = 'Лимит $threshold% · ${limit.name}';
    final body =
        'Осталось ${100 - limit.percent}%. Окно сбросится примерно через ${_formatDuration(limit.resetInSeconds)}.';
    try {
      await plugin.show(
        id: title.hashCode & 0x0fffffff,
        title: title,
        body: body,
        notificationDetails: details,
        payload: 'open',
      );
    } catch (_) {}
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '—';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '$hч $mм';
    return '$mм';
  }

  String _buildTooltip(List<_UsageLimit> limits) {
    if (limits.isEmpty) return 'GoMeter отслеживает лимиты';
    const labels = {'rolling': 'R5h', 'weekly': 'W', 'monthly': 'M'};
    final parts = <String>[];
    for (final l in limits) {
      final label = labels[l.id] ?? l.name;
      parts.add('$label: ${100 - l.percent}%');
    }
    return parts.join(' · ');
  }

  bool _hasNotified(
    SharedPreferences prefs,
    String windowId,
    int threshold,
    DateTime? resetAt,
    DateTime now,
  ) {
    final key = _notifiedKey(windowId, threshold, resetAt, now);
    return prefs.getBool(key) ?? false;
  }

  Future<void> _markNotified(
    SharedPreferences prefs,
    String windowId,
    int threshold,
    DateTime? resetAt,
    DateTime now,
  ) async {
    final key = _notifiedKey(windowId, threshold, resetAt, now);
    await prefs.setBool(key, true);
  }

  String _notifiedKey(
    String windowId,
    int threshold,
    DateTime? resetAt,
    DateTime now,
  ) {
    final resetKey = resetAt != null
        ? resetAt.toUtc().millisecondsSinceEpoch.toString()
        : '${now.toUtc().year}-${now.toUtc().month}-${now.toUtc().day}';
    return 'notified-$windowId-$threshold-$resetKey';
  }

  _UsageLimit _parseWindow({
    required String id,
    required String name,
    required String window,
    required Map<String, dynamic>? json,
    required DateTime now,
  }) {
    final percent = (json?['percent'] as num?)?.toInt() ?? 0;
    final resetAt = _parseReset(json, now);
    return _UsageLimit(
      id: id,
      name: name,
      window: window,
      percent: percent.clamp(0, 100),
      resetAt: resetAt,
    );
  }

  DateTime? _parseReset(Map<String, dynamic>? json, DateTime now) {
    final resetsAt = json?['resetsAt'] as String?;
    if (resetsAt != null && resetsAt.isNotEmpty) {
      return DateTime.tryParse(resetsAt)?.toUtc();
    }
    final resetInSec = (json?['resetInSec'] as num?)?.toInt();
    if (resetInSec != null) {
      return now.add(Duration(seconds: resetInSec));
    }
    return null;
  }
}

class _UsageLimit {
  final String id;
  final String name;
  final String window;
  final int percent;
  final DateTime? resetAt;

  _UsageLimit({
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
}

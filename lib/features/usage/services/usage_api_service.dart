import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';

final usageApiServiceProvider = Provider<UsageApiService>((ref) {
  throw UnimplementedError('Override in main() with initialized service');
});

class UsageApiService {
  final Dio _dio;

  UsageApiService(this._dio);

  Future<List<UsageLimit>> fetch(String apiKey) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://opencode.ai/zen/go/v1/usage',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'User-Agent': 'GoMeter',
        },
        responseType: ResponseType.json,
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Usage API returned ${response.statusCode}');
    }

    final usage = response.data!['usage'] as Map<String, dynamic>? ?? {};
    final now = DateTime.now().toUtc();

    return [
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
  }

  UsageLimit _parseWindow({
    required String id,
    required String name,
    required String window,
    required Map<String, dynamic>? json,
    required DateTime now,
  }) {
    final percent = (json?['percent'] as num?)?.toInt() ?? 0;
    final resetAt = _parseReset(json, now);

    return UsageLimit(
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/features/usage/services/usage_api_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
  final List<Map<String, dynamic>> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add({
      'path': options.path,
      'headers': options.headers,
      'method': options.method,
    });
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('UsageApiService.fetch', () {
    test('sends bearer token and user agent', () async {
      final adapter = _FakeAdapter(
        200,
        {
          'usage': {
            'rolling': {'percent': 10, 'resetInSec': 60},
            'weekly': {'percent': 20},
            'monthly': {'percent': 30},
          },
        },
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = UsageApiService(dio);

      await service.fetch('sk-test');

      final request = adapter.requests.single;
      expect(request['method'], 'GET');
      expect(request['path'], contains('v1/usage'));
      final headers = request['headers'] as Map<String, dynamic>;
      expect(headers['Authorization'], 'Bearer sk-test');
      expect(headers['User-Agent'], 'GoMeter');
    });

    test('parses rolling, weekly and monthly windows', () async {
      final adapter = _FakeAdapter(
        200,
        {
          'usage': {
            'rolling': {'percent': 10, 'resetInSec': 60},
            'weekly': {'percent': 20, 'resetsAt': '2026-09-01T00:00:00Z'},
            'monthly': {'percent': 30},
          },
        },
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = UsageApiService(dio);

      final limits = await service.fetch('sk-test');

      expect(limits, hasLength(3));
      expect(limits.map((l) => l.id), ['rolling', 'weekly', 'monthly']);
      expect(limits[0].percent, 10);
      expect(limits[1].percent, 20);
      expect(limits[2].percent, 30);

      final rolling = limits[0].resetAt!;
      expect(
        rolling.isAfter(DateTime.now().toUtc().add(const Duration(seconds: 10))),
        isTrue,
      );
      expect(
        limits[1].resetAt,
        DateTime.parse('2026-09-01T00:00:00Z').toUtc(),
      );
      expect(limits[2].resetAt, isNull);
    });

    test('clamps percent to 0..100', () async {
      final adapter = _FakeAdapter(
        200,
        {
          'usage': {
            'rolling': {'percent': 120},
            'weekly': {'percent': -5},
          },
        },
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = UsageApiService(dio);

      final limits = await service.fetch('sk-test');

      expect(limits[0].percent, 100);
      expect(limits[1].percent, 0);
    });

    test('falls back to zeroes when usage section is missing', () async {
      final adapter = _FakeAdapter(200, {});
      final dio = Dio()..httpClientAdapter = adapter;
      final service = UsageApiService(dio);

      final limits = await service.fetch('sk-test');

      expect(limits, hasLength(3));
      expect(limits.every((l) => l.percent == 0), isTrue);
      expect(limits.every((l) => l.resetAt == null), isTrue);
    });

    test('throws on non-200 response', () async {
      final adapter = _FakeAdapter(401, {'message': 'unauthorized'});
      final dio = Dio()..httpClientAdapter = adapter;
      final service = UsageApiService(dio);

      expect(
        () => service.fetch('sk-test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

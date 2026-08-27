import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/utils/opencode_auth.dart';
import 'package:gometer/features/usage/services/usage_api_service.dart';

// End-to-end check against the real OpenCode Go API. Skips when no key is
// available (e.g. on CI or a machine without a local auth.json).
void main() async {
  final key = Platform.environment['GOMETER_API_KEY'] ??
      await importOpencodeAuth();

  test(
    'fetches real usage windows with the local key',
    () async {
      final service = UsageApiService(Dio());
      final limits = await service.fetch(key!);

      expect(limits, hasLength(3));
      expect(limits.map((l) => l.id), ['rolling', 'weekly', 'monthly']);
      for (final limit in limits) {
        expect(limit.percent, inInclusiveRange(0, 100));
        // ignore: avoid_print
        print('${limit.name} ${limit.window}: ${limit.percent}%');
      }
    },
    timeout: const Timeout(Duration(minutes: 1)),
    skip: key == null ? 'No key found in env or local auth.json' : false,
  );
}

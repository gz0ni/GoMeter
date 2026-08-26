import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/utils/opencode_auth.dart';

void main() {
  group('parseAuthToken', () {
    test('prefers the nested opencode-go provider key', () {
      final token = parseAuthToken({
        'google': {'type': 'google', 'key': 'google-key'},
        'opencode-go': {'type': 'apikey', 'key': 'sk-go-key'},
      });

      expect(token, 'sk-go-key');
    });

    test('accepts zen and opencode provider keys when opencode-go is absent',
        () {
      final zen = parseAuthToken({
        'zen': {'type': 'apikey', 'key': 'sk-zen-key'},
      });
      expect(zen, 'sk-zen-key');

      final legacy = parseAuthToken({
        'opencode': {'type': 'apikey', 'key': 'sk-opencode-key'},
      });
      expect(legacy, 'sk-opencode-key');
    });

    test('falls back to any provider that has a key', () {
      final token = parseAuthToken({
        'google': {'type': 'google', 'key': 'google-key'},
      });

      expect(token, 'google-key');
    });

    test('consumes legacy flat token fields', () {
      expect(parseAuthToken({'token': 'sk-flat'}), 'sk-flat');
      expect(
        parseAuthToken({'access_token': 'sk-access'}),
        'sk-access',
      );
      expect(
        parseAuthToken({'refresh_token': 'sk-refresh'}),
        'sk-refresh',
      );
    });

    test('reads provider token field as alternative to key', () {
      final token = parseAuthToken({
        'opencode-go': {'type': 'apikey', 'token': 'sk-provider-token'},
      });

      expect(token, 'sk-provider-token');
    });

    test('returns null for empty, missing or malformed payloads', () {
      expect(parseAuthToken({}), isNull);
      expect(
        parseAuthToken({
          'opencode-go': {'type': 'apikey', 'key': ''},
        }),
        isNull,
      );
      expect(
        parseAuthToken({
          'opencode-go': {'type': 'apikey'},
        }),
        isNull,
      );
      expect(
        parseAuthToken({
          'opencode-go': 'not-a-map',
        }),
        isNull,
      );
    });
  });
}

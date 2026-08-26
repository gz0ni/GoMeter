import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

String? _homeDir() {
  if (Platform.isAndroid || Platform.isIOS) return null;

  if (Platform.isWindows) {
    return Platform.environment['USERPROFILE'] ??
        Platform.environment['HOMEDRIVE'] ??
        Platform.environment['HOMEPATH'];
  }

  return Platform.environment['HOME'];
}

String? _windowsConfigDir() => Platform.environment['APPDATA'];

List<String> _candidatePaths() {
  final home = _homeDir();

  return switch (Platform.operatingSystem) {
    'linux' => [
        if (home != null) p.join(home, '.local', 'share', 'opencode', 'auth.json'),
        if (home != null) p.join(home, '.config', 'opencode', 'auth.json'),
      ],
    'macos' => [
        if (home != null)
          p.join(home, 'Library', 'Application Support', 'opencode', 'auth.json'),
        if (home != null) p.join(home, '.config', 'opencode', 'auth.json'),
      ],
    'windows' => [
        if (home != null) p.join(home, '.config', 'opencode', 'auth.json'),
        if (home != null)
          p.join(home, '.local', 'share', 'opencode', 'auth.json'),
        if (_windowsConfigDir() != null)
          p.join(_windowsConfigDir()!, 'opencode', 'auth.json'),
      ],
    _ => const [],
  };
}

String? _readToken(String path) {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    final json = jsonDecode(file.readAsStringSync());
    if (json is! Map<String, dynamic>) return null;
    return parseAuthToken(json);
  } catch (_) {
    return null;
  }
}

/// Extracts the local provider key from an OpenCode `auth.json` payload.
///
/// Handles the nested per-provider format:
/// `{"opencode-go": {"type": ..., "key": "sk-..."}, ...}` and the legacy
/// flat format (`token` / `access_token` / `refresh_token`). Prefers the
/// `opencode-go` provider, then `zen`, then `opencode`, then any provider
/// that has a `key`; falls back to legacy flat fields.
String? parseAuthToken(Map<String, dynamic> json) {
  for (final provider in const ['opencode-go', 'zen', 'opencode']) {
    final entry = json[provider];
    if (entry is Map<String, dynamic>) {
      final key = entry['key'] ?? entry['token'];
      if (key is String && key.isNotEmpty) return key;
    }
  }

  for (final field in const ['token', 'access_token', 'refresh_token']) {
    final value = json[field];
    if (value is String && value.isNotEmpty) return value;
  }

  for (final entry in json.values) {
    if (entry is Map<String, dynamic>) {
      final key = entry['key'] ?? entry['token'];
      if (key is String && key.isNotEmpty) return key;
    }
  }

  return null;
}

Future<String?> importOpencodeAuth() async {
  if (Platform.isAndroid || Platform.isIOS) return null;

  for (final path in _candidatePaths()) {
    final token = _readToken(path);
    if (token != null) return token;
  }

  return null;
}

String opencodeAuthHintPath() {
  final candidates = _candidatePaths();
  if (candidates.isEmpty) return '';

  final first = candidates.first;
  final home = _homeDir();

  if (home != null && first.startsWith(home)) {
    return first.replaceFirst(home, '~');
  }

  return first;
}

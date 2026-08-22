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
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return json['token'] as String? ??
        json['access_token'] as String? ??
        json['refresh_token'] as String?;
  } catch (_) {
    return null;
  }
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

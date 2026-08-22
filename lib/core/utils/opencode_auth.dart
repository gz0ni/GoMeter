import 'dart:convert';
import 'dart:io';

Future<String?> importOpencodeAuth() async {
  if (Platform.isAndroid || Platform.isIOS) return null;

  final home = Platform.environment['HOME'] ??
      (Platform.isWindows ? Platform.environment['USERPROFILE'] : null);
  if (home == null) return null;

  final path = switch (Platform.operatingSystem) {
    'linux' => '$home/.local/share/opencode/auth.json',
    'macos' => '$home/Library/Application Support/opencode/auth.json',
    'windows' => '${Platform.environment['APPDATA']}/opencode/auth.json',
    _ => null,
  };

  if (path == null) return null;

  try {
    final file = File(path);
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return json['token'] as String? ??
        json['access_token'] as String? ??
        json['refresh_token'] as String?;
  } catch (_) {
    return null;
  }
}

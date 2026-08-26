import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

String windowsRunCommand(String executable, {required bool quiet}) =>
    '"$executable"${quiet ? ' --quiet' : ''}';

String linuxDesktopEntry(String executable, {required bool quiet}) {
  final exec = '"$executable"${quiet ? ' --quiet' : ''}';
  return [
    '[Desktop Entry]',
    'Type=Application',
    'Name=GoMeter',
    'Comment=OpenCode Go limits tracker',
    'Exec=$exec',
    'Terminal=false',
    'X-GNOME-Autostart-enabled=true',
    'Version=1.0',
  ].join('\n');
}

String macosLaunchAgentPlist(String executable, {required bool quiet}) {
  final args = [
    executable,
    if (quiet) '--quiet',
  ];
  final argLines = args.map((a) => '    <string>${_xmlEscape(a)}</string>');
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"',
    '  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    '<plist version="1.0">',
    '<dict>',
    '  <key>Label</key>',
    '  <string>dev.gometer.gometer</string>',
    '  <key>ProgramArguments</key>',
    '  <array>',
    ...argLines,
    '  </array>',
    '  <key>RunAtLoad</key>',
    '  <true/>',
    '</dict>',
    '</plist>',
  ].join('\n');
}

String _xmlEscape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

abstract class AutostartService {
  bool get isSupported;

  Future<bool> isEnabled();

  Future<void> enable({bool quiet = false});

  Future<void> disable();
}

class NoopAutostartService implements AutostartService {
  const NoopAutostartService();

  @override
  bool get isSupported => false;

  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> enable({bool quiet = false}) async {}

  @override
  Future<void> disable() async {}
}

const _windowsRunKey = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';
const _windowsValueName = 'GoMeter';
const _linuxDesktopPath =
    '.config/autostart/gometer.desktop';
const _macosPlistPath =
    'Library/LaunchAgents/dev.gometer.gometer.plist';

class WindowsAutostartService implements AutostartService {
  const WindowsAutostartService();

  @override
  bool get isSupported => true;

  @override
  Future<bool> isEnabled() async {
    if (!Platform.isWindows) return false;
    final result =
        await Process.run('reg', ['query', _windowsRunKey, '/v', _windowsValueName]);
    return result.exitCode == 0;
  }

  @override
  Future<void> enable({bool quiet = false}) async {
    if (!Platform.isWindows) return;
    await Process.run('reg', [
      'add', _windowsRunKey, '/v', _windowsValueName,
      '/t', 'REG_SZ',
      '/d', windowsRunCommand(Platform.resolvedExecutable, quiet: quiet),
      '/f',
    ]);
  }

  @override
  Future<void> disable() async {
    if (!Platform.isWindows) return;
    await Process.run('reg', [
      'delete', _windowsRunKey, '/v', _windowsValueName, '/f',
    ]);
  }
}

class LinuxAutostartService implements AutostartService {
  const LinuxAutostartService();

  File _desktopFile() => File(
        '${Platform.environment['HOME'] ?? ''}/$_linuxDesktopPath',
      );

  @override
  bool get isSupported => true;

  @override
  Future<bool> isEnabled() async {
    if (!Platform.isLinux) return false;
    return _desktopFile().exists();
  }

  @override
  Future<void> enable({bool quiet = false}) async {
    if (!Platform.isLinux) return;
    final file = _desktopFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      linuxDesktopEntry(Platform.resolvedExecutable, quiet: quiet),
    );
  }

  @override
  Future<void> disable() async {
    if (!Platform.isLinux) return;
    final file = _desktopFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class MacosAutostartService implements AutostartService {
  const MacosAutostartService();

  File _plistFile() => File(
        '${Platform.environment['HOME'] ?? ''}/$_macosPlistPath',
      );

  @override
  bool get isSupported => true;

  @override
  Future<bool> isEnabled() async {
    if (!Platform.isMacOS) return false;
    return _plistFile().exists();
  }

  @override
  Future<void> enable({bool quiet = false}) async {
    if (!Platform.isMacOS) return;
    final file = _plistFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      macosLaunchAgentPlist(Platform.resolvedExecutable, quiet: quiet),
    );
  }

  @override
  Future<void> disable() async {
    if (!Platform.isMacOS) return;
    final file = _plistFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}

final autostartServiceProvider = Provider<AutostartService>((ref) {
  if (Platform.isWindows) return const WindowsAutostartService();
  if (Platform.isLinux) return const LinuxAutostartService();
  if (Platform.isMacOS) return const MacosAutostartService();
  return const NoopAutostartService();
});

import 'dart:io';
import 'package:flutter/services.dart';

class Installer {
  static const _channel = MethodChannel('dev.gometer/installer');

  Future<void> install(String filePath) async {
    if (Platform.isWindows) {
      await Process.start(filePath, [
        '/VERYSILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
      ]);
    } else if (Platform.isMacOS) {
      await _installMacosDmg(filePath);
    } else if (Platform.isLinux) {
      await _installLinux(filePath);
    } else if (Platform.isAndroid) {
      await _channel.invokeMethod('installApk', {'path': filePath});
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  Future<Directory> _createTempMount() async {
    try {
      return await Directory.systemTemp.createTemp('gometer_update_');
    } catch (_) {
      final tmpBase = Platform.environment['TMPDIR'] ?? Directory.systemTemp.path;
      final fallback = Directory(
        '$tmpBase/gometer_update_${DateTime.now().millisecondsSinceEpoch}',
      );
      await fallback.create(recursive: true);
      return fallback;
    }
  }

  Future<void> _installMacosDmg(String dmgPath) async {
    final tempDir = await _createTempMount();
    final mountPoint = tempDir.path;
    try {
      final attachResult = await Process.run('hdiutil', [
        'attach',
        dmgPath,
        '-mountpoint',
        mountPoint,
        '-nobrowse',
      ]);
      if (attachResult.exitCode != 0) {
        throw Exception(
          'hdiutil attach failed: ${attachResult.stderr}${attachResult.stdout}',
        );
      }
      final appBundle = Directory('$mountPoint/GoMeter.app');
      if (!await appBundle.exists()) {
        throw Exception('GoMeter.app not found in DMG at $mountPoint');
      }
      final script =
          'do shell script "ditto \\"$mountPoint/GoMeter.app\\" \\"/Applications/GoMeter.app\\"" with administrator privileges';
      final copyResult = await Process.run('osascript', ['-e', script]);
      if (copyResult.exitCode != 0) {
        throw Exception(
          'Install failed: ${copyResult.stderr}${copyResult.stdout}',
        );
      }
    } finally {
      try {
        await Process.run('hdiutil', ['detach', mountPoint]);
      } catch (_) {}
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
    }
  }

  Future<void> _installLinux(String filePath) async {
    if (filePath.endsWith('.deb')) {
      final result = await Process.run('pkexec', ['dpkg', '-i', filePath]);
      if (result.exitCode != 0) {
        await Process.run('xdg-open', [filePath]);
      }
    } else if (filePath.endsWith('.tar.gz')) {
      final home = Platform.environment['HOME'] ?? '';
      final dest = '$home/GoMeter';
      await Directory(dest).create(recursive: true);
      await Process.run('tar', [
        '-xzf',
        filePath,
        '-C',
        dest,
        '--strip-components=1',
      ]);
      await Process.run('xdg-open', [dest]);
    } else {
      await Process.run('xdg-open', [filePath]);
    }
  }
}

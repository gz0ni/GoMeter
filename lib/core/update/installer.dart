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

  Future<void> _installMacosDmg(String dmgPath) async {
    const mountPoint = '/tmp/gometer_update';
    await Directory(mountPoint).create(recursive: true);
    await Process.run('hdiutil', [
      'attach',
      dmgPath,
      '-mountpoint',
      mountPoint,
      '-nobrowse',
    ]);
    final appBundle = Directory('$mountPoint/GoMeter.app');
    if (await appBundle.exists()) {
      final script =
          'do shell script "ditto \\"$mountPoint/GoMeter.app\\" \\"/Applications/GoMeter.app\\"" with administrator privileges';
      await Process.run('osascript', ['-e', script]);
    }
    await Process.run('hdiutil', ['detach', mountPoint]);
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

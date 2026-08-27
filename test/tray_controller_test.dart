import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/tray/tray_controller.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('tray_icon_path_test_');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  void add(String rel) {
    final file = File(p.join(root.path, rel));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('x');
  }

  String exe() => p.join(root.path, 'app', 'gometer.exe');

  group('resolveTrayIconPath', () {
    test('prefers the release bundle next to the exe', () {
      add('app/data/flutter_assets/assets/images/ico/gometer.ico');

      final path = resolveTrayIconPath(
        exePath: exe(),
        cwd: p.join(root.path, 'repo'),
        windows: true,
      );

      expect(path, contains(p.join('app', 'data', 'flutter_assets')));
      expect(File(path).existsSync(), isTrue);
    });

    test('falls back to data/flutter_assets under the cwd', () {
      final cwd = p.join(root.path, 'flutter_run');
      add('flutter_run/data/flutter_assets/assets/images/ico/gometer.ico');

      final path = resolveTrayIconPath(
        exePath: exe(),
        cwd: cwd,
        windows: true,
      );

      expect(path, contains(p.join('flutter_run', 'data', 'flutter_assets')));
      expect(File(path).existsSync(), isTrue);
    });

    test('falls back to the repo root asset relative to the exe', () {
      add('app/assets/images/ico/gometer.ico');

      final path = resolveTrayIconPath(
        exePath: exe(),
        cwd: p.join(root.path, 'other'),
        windows: true,
      );

      expect(path, contains(p.join('app', 'assets', 'images', 'ico')));
      expect(File(path).existsSync(), isTrue);
    });

    test('falls back to the cwd asset (repo root)', () {
      final cwd = p.join(root.path, 'repo');
      add('repo/assets/images/ico/gometer.ico');

      final path = resolveTrayIconPath(
        exePath: exe(),
        cwd: cwd,
        windows: true,
      );

      expect(path, contains(p.join('repo', 'assets', 'images', 'ico')));
      expect(File(path).existsSync(), isTrue);
    });

    test('returns a path (last candidate) when nothing exists', () {
      final path = resolveTrayIconPath(
        exePath: exe(),
        cwd: p.join(root.path, 'empty'),
        windows: true,
      );

      expect(path, isNotEmpty);
    });

    test('uses icon-64.png on non-Windows platforms', () {
      add('app/data/flutter_assets/assets/images/png/icon-64.png');

      final path = resolveTrayIconPath(
        exePath: exe(),
        cwd: p.join(root.path, 'repo'),
        windows: false,
      );

      expect(path, contains('icon-64.png'));
      expect(File(path).existsSync(), isTrue);
    });
  });
}

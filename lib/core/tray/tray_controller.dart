import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayController with TrayListener, WindowListener {
  TrayController._();

  static final TrayController instance = TrayController._();

  bool _attached = false;

  Future<void> attachToTray() async {
    if (_attached) return;
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    await trayManager.setIcon(resolveTrayIconPath());
    await trayManager.setToolTip('GoMeter');
    await trayManager.setContextMenu(
      Menu(items: [
        MenuItem(key: 'open', label: 'Открыть GoMeter'),
        MenuItem.separator(),
        MenuItem(key: 'quit', label: 'Выход'),
      ]),
    );
    trayManager.addListener(this);
    _attached = true;
  }

  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.restore();
    await windowManager.focus();
  }

  @override
  void onTrayIconMouseDown() {
    showWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onWindowClose() {
    windowManager.hide();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'open':
        showWindow();
      case 'quit':
        trayManager.destroy();
        exit(0);
    }
  }
}

/// Resolves an absolute path to the tray icon asset.
///
/// Resolution order (first existing file wins):
/// 1. `<exeDir>/data/flutter_assets/<rel>` — release bundle next to the exe;
/// 2. `<cwd>/data/flutter_assets/<rel>` — `flutter run` on desktop;
/// 3. `<exeDir>/<rel>` — unpacked repo build;
/// 4. `<cwd>/<rel>` — repo root.
///
/// Windows needs an `.ico`; other platforms use `icon-64.png`. Returns the
/// raw relative path as a last-resort fallback so the call never throws.
String resolveTrayIconPath({
  String? exePath,
  String? cwd,
  bool? windows,
}) {
  final isWindows = windows ?? Platform.isWindows;
  final rel = isWindows
      ? p.join('assets', 'images', 'ico', 'gometer.ico')
      : p.join('assets', 'images', 'png', 'icon-64.png');
  final resolvedExe = exePath ?? Platform.resolvedExecutable;
  final exeDir = p.dirname(resolvedExe);
  final base = cwd ?? Directory.current.path;

  final candidates = [
    p.join(exeDir, 'data', 'flutter_assets', rel),
    p.join(base, 'data', 'flutter_assets', rel),
    p.join(exeDir, rel),
    p.join(base, rel),
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }
  return candidates.last;
}

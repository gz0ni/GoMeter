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
    await trayManager.setIcon(_resolveIconPath());
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

  String _resolveIconPath() {
    final rel = Platform.isWindows
        ? p.join('assets', 'images', 'ico', 'gometer.ico')
        : p.join('assets', 'images', 'png', 'icon-64.png');
    final bundled = p.join('data', 'flutter_assets', rel);
    if (File(bundled).existsSync()) return bundled;
    if (File(rel).existsSync()) return rel;
    return rel;
  }
}

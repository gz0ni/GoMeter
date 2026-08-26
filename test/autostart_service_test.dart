import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/autostart/autostart_service.dart';

void main() {
  group('windowsRunCommand', () {
    test('quotes executable and appends --quiet', () {
      expect(
        windowsRunCommand(r'C:\GoMeter\gometer.exe', quiet: true),
        r'"C:\GoMeter\gometer.exe" --quiet',
      );
    });

    test('omits flag when not quiet', () {
      expect(windowsRunCommand(r'C:\GoMeter\gometer.exe', quiet: false),
          r'"C:\GoMeter\gometer.exe"');
    });
  });

  group('linuxDesktopEntry', () {
    test('contains quoted Exec with --quiet', () {
      final entry = linuxDesktopEntry('/opt/gometer/gometer', quiet: true);
      expect(entry, contains('Type=Application'));
      expect(entry, contains('Name=GoMeter'));
      expect(entry, contains('Exec="/opt/gometer/gometer" --quiet'));
    });

    test('exec has no flag by default', () {
      expect(linuxDesktopEntry('/opt/gometer/gometer', quiet: false),
          contains('Exec="/opt/gometer/gometer"'));
      expect(linuxDesktopEntry('/opt/gometer/gometer', quiet: false),
          isNot(contains('--quiet')));
    });
  });

  group('macosLaunchAgentPlist', () {
    test('contains label, program args and RunAtLoad', () {
      final plist = macosLaunchAgentPlist(
        '/Applications/GoMeter.app/Contents/MacOS/gometer',
        quiet: true,
      );
      expect(plist, contains('dev.gometer.gometer'));
      expect(plist, contains('--quiet'));
      expect(plist, contains('<true/>'));
      expect(plist,
          contains('/Applications/GoMeter.app/Contents/MacOS/gometer'));
    });

    test('omits --quiet when not quiet', () {
      final plist = macosLaunchAgentPlist('/opt/gometer', quiet: false);
      expect(plist, isNot(contains('--quiet')));
    });
  });
}

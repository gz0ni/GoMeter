import 'dart:ffi';
import 'dart:io';

int compareVersions(String version1, String version2) {
  final v1 = version1.split('+').first.split('.');
  final v2 = version2.split('+').first.split('.');
  final major1 = int.parse(v1[0]);
  final major2 = int.parse(v2[0]);
  if (major1 != major2) return major1.compareTo(major2);
  final minor1 = v1.length > 1 ? int.parse(v1[1]) : 0;
  final minor2 = v2.length > 1 ? int.parse(v2[1]) : 0;
  if (minor1 != minor2) return minor1.compareTo(minor2);
  final patch1 = v1.length > 2 ? int.parse(v1[2]) : 0;
  final patch2 = v2.length > 2 ? int.parse(v2[2]) : 0;
  if (patch1 != patch2) return patch1.compareTo(patch2);
  final build1 = version1.contains('+') ? int.parse(version1.split('+')[1]) : 0;
  final build2 = version2.contains('+') ? int.parse(version2.split('+')[1]) : 0;
  return build1.compareTo(build2);
}

List<String> parseReleaseBody(String? body) {
  if (body == null) return [];
  return RegExp(r'- \s*(.*)')
      .allMatches(body)
      .map((match) => match.group(1) ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String get currentArch {
  return switch (Abi.current()) {
    Abi.windowsX64 || Abi.macosX64 || Abi.linuxX64 => 'amd64',
    Abi.windowsArm64 || Abi.macosArm64 || Abi.linuxArm64 => 'arm64',
    Abi.androidArm64 => 'arm64-v8a',
    Abi.androidArm => 'armeabi-v7a',
    Abi.androidX64 => 'x86_64',
    Abi.androidIA32 => 'x86',
    _ => 'amd64',
  };
}

String get currentPlatform {
  if (Platform.isWindows) return 'windows';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isLinux) return 'linux';
  if (Platform.isAndroid) return 'android';
  return 'unknown';
}

String get androidAbiName {
  return switch (Abi.current()) {
    Abi.androidArm64 => 'arm64-v8a',
    Abi.androidArm => 'armeabi-v7a',
    Abi.androidX64 => 'x86_64',
    Abi.androidIA32 => 'x86',
    _ => 'arm64-v8a',
  };
}

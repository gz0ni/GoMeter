import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'release_info.dart';
import 'version_utils.dart';

class UpdateService {
  final Dio _dio;
  final PackageInfo _packageInfo;

  UpdateService(this._dio, this._packageInfo);

  Future<ReleaseInfo?> checkForUpdate() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.github.com/repos/gz0ni/GoMeter/releases/latest',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (_) => true,
      ),
    );
    if (response.statusCode != 200 || response.data == null) return null;

    final release = ReleaseInfo.fromJson(response.data!);
    final remote = release.tagName.replaceAll('v', '');
    final local = _packageInfo.version.split('+').first;
    if (compareVersions(remote, local) > 0) return release;
    return null;
  }

  Future<String> downloadAsset(
    ReleaseAsset asset,
    String destDir,
    void Function(int received, int total) onProgress,
  ) async {
    final path = '$destDir/${asset.name}';
    await _dio.download(
      asset.url,
      path,
      onReceiveProgress: onProgress,
      options: Options(
        headers: {'Accept': 'application/octet-stream'},
        responseType: ResponseType.bytes,
      ),
    );
    return path;
  }

  ReleaseAsset? pickAsset(
    ReleaseInfo release, {
    String? platform,
    String? arch,
  }) {
    final assets = release.assets;
    final resolvedPlatform = platform ?? currentPlatform;
    final resolvedArch = arch ?? currentArch;

    if (resolvedPlatform == 'windows') {
      return _firstMatch(assets, [
        'windows-$resolvedArch-setup.exe',
        'windows-$resolvedArch.exe',
        'windows-$resolvedArch.zip',
        'windows-$resolvedArch',
      ]);
    }
    if (resolvedPlatform == 'linux') {
      return _firstMatch(assets, [
        'linux-$resolvedArch.deb',
        'linux-$resolvedArch.tar.gz',
        'linux-$resolvedArch.rpm',
        'linux-$resolvedArch',
      ]);
    }
    if (resolvedPlatform == 'macos') {
      return _firstMatch(assets, [
        'macos-$resolvedArch.dmg',
        'macos-$resolvedArch',
      ]);
    }
    if (resolvedPlatform == 'android') {
      final abi = androidAbiName;
      return _firstMatch(assets, [
        'android-$abi.apk',
        '-$abi',
        '.apk',
      ]);
    }
    return null;
  }

  ReleaseAsset? _firstMatch(
    List<ReleaseAsset> assets,
    List<String> patterns,
  ) {
    for (final pattern in patterns) {
      for (final asset in assets) {
        if (asset.name.toLowerCase().contains(pattern.toLowerCase())) {
          return asset;
        }
      }
    }
    return null;
  }
}

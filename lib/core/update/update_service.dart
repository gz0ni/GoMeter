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
      options: Options(responseType: ResponseType.json),
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

  ReleaseAsset? pickAsset(ReleaseInfo release) {
    final assets = release.assets;
    final platform = currentPlatform;
    final arch = currentArch;

    if (platform == 'windows') {
      return _firstMatch(assets, [
        'windows-$arch-setup.exe',
        'windows-$arch.exe',
        'windows-$arch.zip',
        'windows-$arch',
      ]);
    }
    if (platform == 'linux') {
      return _firstMatch(assets, [
        'linux-$arch.deb',
        'linux-$arch.tar.gz',
        'linux-$arch.rpm',
        'linux-$arch',
      ]);
    }
    if (platform == 'macos') {
      return _firstMatch(assets, [
        'macos-$arch.dmg',
        'macos-$arch',
      ]);
    }
    if (platform == 'android') {
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

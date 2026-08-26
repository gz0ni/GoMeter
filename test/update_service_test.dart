import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/update/release_info.dart';
import 'package:gometer/core/update/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _releaseJson({
  required String tagName,
  List<Map<String, dynamic>> assets = const [],
}) =>
    {
      'tag_name': tagName,
      'body': 'changelog',
      'assets': [
        for (final a in assets)
          {
            'name': a['name'],
            'browser_download_url': a['url'],
            'size': a['size'] ?? 0,
          },
      ],
    };

UpdateService _service(int statusCode, Map<String, dynamic> body,
        PackageInfo packageInfo) =>
    UpdateService(
      Dio()..httpClientAdapter = _FakeAdapter(statusCode, body),
      packageInfo,
    );

PackageInfo _info(String version) => PackageInfo(
      appName: 'gometer',
      packageName: 'gometer',
      version: version,
      buildNumber: '1',
    );

void main() {
  group('UpdateService.checkForUpdate', () {
    test('returns release when remote version is newer', () async {
      final service = _service(
        200,
        _releaseJson(tagName: 'v0.2.0', assets: [
          {'name': 'gometer-windows-x64.exe', 'url': 'https://dl/win.exe'},
        ]),
        _info('0.1.1'),
      );

      final release = await service.checkForUpdate();

      expect(release, isNotNull);
      expect(release!.tagName, 'v0.2.0');
      expect(release.assets.single.name, 'gometer-windows-x64.exe');
    });

    test('returns null when remote version is not newer', () async {
      final service = _service(
        200,
        _releaseJson(tagName: 'v0.1.1'),
        _info('0.1.1'),
      );

      expect(await service.checkForUpdate(), isNull);
    });

    test('returns null on non-200 response', () async {
      final service = _service(404, {}, _info('0.1.1'));

      expect(await service.checkForUpdate(), isNull);
    });
  });

  group('UpdateService.pickAsset', () {
    final release = ReleaseInfo(
      tagName: 'v0.2.0',
      body: '',
      assets: [
        ReleaseAsset(name: 'gometer-windows-amd64.exe', url: 'u', size: 1),
        ReleaseAsset(name: 'gometer-windows-amd64-setup.exe', url: 'u', size: 1),
        ReleaseAsset(name: 'gometer-linux-amd64.deb', url: 'u', size: 1),
        ReleaseAsset(name: 'gometer-macos-amd64.dmg', url: 'u', size: 1),
      ],
    );

    test('prefers dedicated setup asset on windows', () {
      final service = _service(200, {}, _info('0.1.1'));
      expect(
        service.pickAsset(release)!.name,
        'gometer-windows-amd64-setup.exe',
      );
    });
  });
}

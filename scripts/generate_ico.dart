import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const _source = 'assets/images/png/icon-1024.png';
const _appFrameSizes = [16, 24, 32, 48, 64, 128, 256];
const _trayFrameSizes = [16, 20, 24, 32, 48];
const _appIcoTargets = ['windows/runner/resources/app_icon.ico'];
const _trayIcoTargets = ['assets/images/ico/gometer.ico'];

Uint8List _encodeBmpFrame(img.Image image) {
  final w = image.width;
  final h = image.height;
  final andRowBytes = ((w + 31) ~/ 32) * 4;
  final xorSize = w * h * 4;
  final dibSize = 40 + xorSize + andRowBytes * h;
  final dib = Uint8List(dibSize);
  final out = ByteData.view(dib.buffer);

  out.setUint32(0, 40, Endian.little);
  out.setInt32(4, w, Endian.little);
  out.setInt32(8, h * 2, Endian.little);
  out.setUint16(12, 1, Endian.little);
  out.setUint16(14, 32, Endian.little);

  var offset = 40;
  for (var y = h - 1; y >= 0; y--) {
    for (var x = 0; x < w; x++) {
      final p = image.getPixel(x, y);
      dib[offset++] = p.b.toInt();
      dib[offset++] = p.g.toInt();
      dib[offset++] = p.r.toInt();
      dib[offset++] = p.a.toInt();
    }
  }
  for (var y = h - 1; y >= 0; y--) {
    for (var x = 0; x < w; x++) {
      final p = image.getPixel(x, y);
      if (p.a.toInt() < 128) {
        dib[offset + x ~/ 8] |= 0x80 >> (x % 8);
      }
    }
    offset += andRowBytes;
  }
  return dib;
}

Uint8List _encodeIco(List<img.Image> frames) {
  final count = frames.length;
  var dataOffset = 6 + count * 16;
  final headers = <int>[];
  final blobs = <List<int>>[];

  for (final frame in frames) {
    final size = frame.width;
    final blob = _encodeBmpFrame(frame);
    headers
      ..add(size >= 256 ? 0 : size)
      ..add(size >= 256 ? 0 : size)
      ..add(0)
      ..add(0)
      ..add(1)
      ..add(0)
      ..add(32)
      ..add(0)
      ..add(blob.length & 0xff)
      ..add((blob.length >> 8) & 0xff)
      ..add((blob.length >> 16) & 0xff)
      ..add((blob.length >> 24) & 0xff)
      ..add(dataOffset & 0xff)
      ..add((dataOffset >> 8) & 0xff)
      ..add((dataOffset >> 16) & 0xff)
      ..add((dataOffset >> 24) & 0xff);
    blobs.add(blob);
    dataOffset += blob.length;
  }

  final out = BytesBuilder();
  out.add([0, 0, 1, 0, count & 0xff, count >> 8]);
  out.add(headers);
  for (final blob in blobs) {
    out.add(blob);
  }
  return out.toBytes();
}

/// Tray icons read better when the logo fills more of the canvas and the
/// ring/stroke are proportionally heavier. Trim the transparent margins and
/// re-center on a full-size canvas, keeping a small padding for the edge AA.
img.Image _trayCanvas(img.Image source) {
  var minX = source.width, minY = source.height, maxX = -1, maxY = -1;
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      if (source.getPixel(x, y).a.toInt() > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) return source;

  final cropped = img.copyCrop(
    source,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );

  const side = 1024;
  // 2% padding on each side for anti-aliased edges.
  final targetSide = (side * 0.96).round();
  final scale = targetSide / math.max(cropped.width, cropped.height);
  final w = math.max(1, (cropped.width * scale).round());
  final h = math.max(1, (cropped.height * scale).round());

  final resized = img.copyResize(
    cropped,
    width: w,
    height: h,
    interpolation: img.Interpolation.cubic,
  );

  final canvas = img.Image(width: side, height: side, numChannels: 4);
  img.compositeImage(canvas, resized, dstX: (side - w) ~/ 2, dstY: (side - h) ~/ 2);
  return canvas;
}

void _saveIco(List<img.Image> frames, List<String> targets) {
  final ico = _encodeIco(frames);
  for (final target in targets) {
    File(target).writeAsBytesSync(ico);
    stderr.writeln(
      'Saved $target (${ico.length} bytes, ${frames.length} frames)',
    );
  }
}

void main() {
  final source = img.decodeImage(File(_source).readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to read $_source');
    exit(1);
  }

  final appFrames = [
    for (final size in _appFrameSizes) img.copyResizeCropSquare(source, size: size),
  ];
  _saveIco(appFrames, _appIcoTargets);

  final trayCanvas = _trayCanvas(source);
  final trayFrames = [
    for (final size in _trayFrameSizes)
      img.copyResizeCropSquare(trayCanvas, size: size),
  ];
  _saveIco(trayFrames, _trayIcoTargets);
}

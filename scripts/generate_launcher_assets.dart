import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _source = 'assets/images/png/icon-1024.png';
const _foreground = 'assets/images/png/adaptive-foreground.png';
const _background = 'assets/images/png/adaptive-background.png';

/// The adaptive icon safe zone is 66/108 (61.1%) of the canvas. Keep the ring
/// (which occupies 78% of the source canvas) inside it with a small margin.
const _safeDiameter = 1024.0 * 0.56;

void main() {
  final source = img.decodeImage(File(_source).readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to read $_source');
    exit(1);
  }

  final scale = _safeDiameter / math.max(source.width, source.height);
  final size = (math.max(source.width, source.height) * scale).round();
  final content = img.copyResize(
    source,
    width: size,
    height: size,
    interpolation: img.Interpolation.cubic,
  );
  final foreground = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.compositeImage(
    foreground,
    content,
    dstX: (1024 - size) ~/ 2,
    dstY: (1024 - size) ~/ 2,
  );
  File(_foreground).writeAsBytesSync(img.encodePng(foreground));

  final background = img.Image(width: 1024, height: 1024, numChannels: 3);
  final top = img.ColorRgb8(0xE3, 0xF2, 0xFD);
  final bottom = img.ColorRgb8(0xED, 0xE7, 0xF6);
  for (var y = 0; y < 1024; y++) {
    final t = y / 1023;
    final r = (top.r + (bottom.r - top.r) * t).round();
    final g = (top.g + (bottom.g - top.g) * t).round();
    final b = (top.b + (bottom.b - top.b) * t).round();
    final c = img.ColorRgb8(r, g, b);
    for (var x = 0; x < 1024; x++) {
      background.setPixel(x, y, c);
    }
  }
  File(_background).writeAsBytesSync(img.encodePng(background));

  stderr.writeln('Saved $_foreground (ring ${_safeDiameter.round()}px)');
  stderr.writeln('Saved $_background (blue->lavender gradient)');
}

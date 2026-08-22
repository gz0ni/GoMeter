import 'dart:io';
import 'dart:math';
import 'package:image/image.dart';

void main() {
  const size = 1024;
  final img = Image(
    width: size,
    height: size,
    numChannels: 4,
  );
  fill(img, color: ColorUint8.rgba(0, 0, 0, 0));

  const cx = size ~/ 2;
  const cy = size ~/ 2;
  const pad = 80;
  const bgRadius = size ~/ 2 - pad;
  final bg = ColorUint8.rgba(103, 80, 164, 255);
  final fg = ColorUint8.rgba(255, 255, 255, 255);

  fillCircle(
    img,
    x: cx,
    y: cy,
    radius: bgRadius,
    color: bg,
    antialias: true,
  );

  const arcRadius = bgRadius - 180;
  for (var deg = 210.0; deg <= 330.0; deg += 0.5) {
    final rad = deg * pi / 180;
    final x = (cx + arcRadius * cos(rad)).round();
    final y = (cy + arcRadius * sin(rad)).round();
    fillCircle(
      img,
      x: x,
      y: y,
      radius: 22,
      color: fg,
      antialias: true,
    );
  }

  const needleDeg = 258.0;
  final needleRad = needleDeg * pi / 180;
  const needleLen = arcRadius - 40;
  final nx = (cx + needleLen * cos(needleRad)).round();
  final ny = (cy + needleLen * sin(needleRad)).round();
  drawLine(
    img,
    x1: cx,
    y1: cy,
    x2: nx,
    y2: ny,
    color: fg,
    thickness: 40,
    antialias: true,
  );

  fillCircle(
    img,
    x: cx,
    y: cy,
    radius: 32,
    color: fg,
    antialias: true,
  );

  final png = encodePng(img);
  File('assets/images/icon.png').writeAsBytesSync(png);
  stderr.writeln('Saved assets/images/icon.png (${png.length} bytes)');
}

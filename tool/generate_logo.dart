import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;

  final transparent = img.ColorRgba8(0, 0, 0, 0);
  final greenColor = img.ColorRgba8(0, 184, 86, 255);  // #00B856
  final darkBgColor = img.ColorRgba8(17, 17, 17, 255);  // #111111

  // 1. Full App Icon (1024x1024): Dark #111111 circle background with the 3 green #00B856 bars mark centered
  final icon = img.Image(width: size, height: size);
  img.fill(icon, color: transparent);

  final cx = size / 2.0;
  final cy = size / 2.0;
  final r = size / 2.0 - 1;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - cx + 0.5;
      final dy = y - cy + 0.5;
      if (dx * dx + dy * dy <= r * r) {
        icon.setPixel(x, y, darkBgColor);
      }
    }
  }

  // Draw the 3 green bars mark from logo.png centered
  // Scale factor = 1024 / 48 = 21.333
  const double f = size / 48.0;
  // Offset to center the 3 bars vertically and horizontally in 1024x1024
  const double ox = 40.0;
  const double oy = 30.0;

  _drawRRect(icon, ox + 27 * f, oy + 5 * f, 8 * f, 17 * f, 3 * f, greenColor);
  _drawRRect(icon, ox + 22 * f, oy + 24 * f, 8 * f, 6 * f, 3 * f, greenColor);
  _drawRRect(icon, ox + 13 * f, oy + 28 * f, 8 * f, 15 * f, 3 * f, greenColor);

  _savePng(icon, 'assets/images/app_logo.png');

  // 2. Adaptive Icon Foreground (3 green bars on transparent canvas)
  final fg = img.Image(width: size, height: size);
  img.fill(fg, color: transparent);

  const double safeSize = size * 0.60;
  final double aox = (size - safeSize) / 2.0 + 20;
  final double aoy = (size - safeSize) / 2.0 + 15;
  final double sf = safeSize / 48.0;

  _drawRRect(fg, aox + 27 * sf, aoy + 5 * sf, 8 * sf, 17 * sf, 3 * sf, greenColor);
  _drawRRect(fg, aox + 22 * sf, aoy + 24 * sf, 8 * sf, 6 * sf, 3 * sf, greenColor);
  _drawRRect(fg, aox + 13 * sf, aoy + 28 * sf, 8 * sf, 15 * sf, 3 * sf, greenColor);

  _savePng(fg, 'assets/images/app_logo_foreground.png');

  print('✅ Launcher icon PNGs generated successfully.');
}

void _drawRRect(img.Image image, double rx, double ry, double rw, double rh, double radius, img.Color color) {
  final x = rx.round();
  final y = ry.round();
  final w = rw.round();
  final h = rh.round();
  final r = radius.round();

  for (int py = y; py < y + h; py++) {
    for (int px = x; px < x + w; px++) {
      if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;

      bool draw = true;
      if (px < x + r && py < y + r) {
        final dx = px - (x + r);
        final dy = py - (y + r);
        if (dx * dx + dy * dy > r * r) draw = false;
      } else if (px >= x + w - r && py < y + r) {
        final dx = px - (x + w - r);
        final dy = py - (y + r);
        if (dx * dx + dy * dy > r * r) draw = false;
      } else if (px < x + r && py >= y + h - r) {
        final dx = px - (x + r);
        final dy = py - (y + h - r);
        if (dx * dx + dy * dy > r * r) draw = false;
      } else if (px >= x + w - r && py >= y + h - r) {
        final dx = px - (x + w - r);
        final dy = py - (y + h - r);
        if (dx * dx + dy * dy > r * r) draw = false;
      }

      if (draw) image.setPixel(px, py, color);
    }
  }
}

void _savePng(img.Image image, String path) {
  final file = File(path);
  file.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
}

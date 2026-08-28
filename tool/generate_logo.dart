import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;

  final transparent = img.ColorRgba8(0, 0, 0, 0);
  final greenBgColor = img.ColorRgba8(0, 184, 86, 255); // #00B856 Green
  final darkBarColor = img.ColorRgba8(17, 17, 17, 255);  // #111111 Black

  // 1. Full App Icon: Green #00B856 circle background with 3 black #111111 bars inside
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
        icon.setPixel(x, y, greenBgColor);
      }
    }
  }

  // Draw 3 black bars (#111111) inside green circle
  const double f = size / 48.0;
  _drawRRect(icon, 27 * f, 5 * f, 8 * f, 17 * f, 3 * f, darkBarColor);
  _drawRRect(icon, 22 * f, 24 * f, 8 * f, 6 * f, 3 * f, darkBarColor);
  _drawRRect(icon, 13 * f, 28 * f, 8 * f, 15 * f, 3 * f, darkBarColor);

  _savePng(icon, 'assets/images/app_logo.png');

  // 2. Adaptive Icon Foreground (3 black bars on transparent canvas for green adaptive background)
  final fg = img.Image(width: size, height: size);
  img.fill(fg, color: transparent);

  const double safeSize = size * 0.64;
  final double ox = (size - safeSize) / 2.0;
  final double oy = (size - safeSize) / 2.0;
  final double sf = safeSize / 48.0;

  _drawRRect(fg, ox + 27 * sf, oy + 5 * sf, 8 * sf, 17 * sf, 3 * sf, darkBarColor);
  _drawRRect(fg, ox + 22 * sf, oy + 24 * sf, 8 * sf, 6 * sf, 3 * sf, darkBarColor);
  _drawRRect(fg, ox + 13 * sf, oy + 28 * sf, 8 * sf, 15 * sf, 3 * sf, darkBarColor);

  _savePng(fg, 'assets/images/app_logo_foreground.png');

  // ignore: avoid_print
  print('✅ Generated launcher icons: Green #00B856 background + Black #111111 bars foreground');
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

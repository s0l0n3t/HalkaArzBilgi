import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:math';

void main() {
  const int size = 1024; // High-res for all densities

  // Colors from app-gallery-icon.svg:
  // Background circle: #00B856 (R:0, G:184, B:86)
  // Bars (foreground): #111111 (R:17, G:17, B:17)
  final bgColor = img.ColorRgba8(0, 184, 86, 255);
  final barColor = img.ColorRgba8(17, 17, 17, 255);
  final transparent = img.ColorRgba8(0, 0, 0, 0);

  // ─────────────────────────────────────
  // 1. app_logo.png — Full icon (circle + bars), 1024x1024
  // ─────────────────────────────────────
  final icon = img.Image(width: size, height: size);
  img.fill(icon, color: transparent);

  // Draw green circle filling the whole canvas
  final cx = size / 2.0;
  final cy = size / 2.0;
  final r = size / 2.0 - 1;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - cx + 0.5;
      final dy = y - cy + 0.5;
      if (dx * dx + dy * dy <= r * r) {
        icon.setPixel(x, y, bgColor);
      }
    }
  }

  // SVG is 48x48, scale to 1024: factor = 1024/48 = 21.333
  final double f = size / 48.0;
  // rect x=27, y=5,  w=8, h=17, rx=3 (tallest bar, right)
  _drawRRect(icon, 27 * f, 5 * f, 8 * f, 17 * f, 3 * f, barColor);
  // rect x=22, y=24, w=8, h=6,  rx=3 (short bar, middle)
  _drawRRect(icon, 22 * f, 24 * f, 8 * f, 6 * f, 3 * f, barColor);
  // rect x=13, y=28, w=8, h=15, rx=3 (medium bar, left)
  _drawRRect(icon, 13 * f, 28 * f, 8 * f, 15 * f, 3 * f, barColor);

  _savePng(icon, 'assets/images/app_logo.png');

  // ─────────────────────────────────────
  // 2. app_logo_foreground.png — Adaptive icon foreground (bars only, transparent bg)
  //    Android scales this in a 108dp canvas; the safe zone is 72dp center.
  //    We use the same bar proportions but scaled to 1024x1024 centered safely.
  // ─────────────────────────────────────
  final fg = img.Image(width: size, height: size);
  img.fill(fg, color: transparent);

  // Safe zone ≈ 66% of canvas = 675 pixels. Center the 48-unit SVG into 675px.
  final double safeSize = size * 0.66;
  // Offset to center the safe zone
  final double ox = (size - safeSize) / 2.0;
  final double oy = (size - safeSize) / 2.0;
  final double sf = safeSize / 48.0;

  _drawRRect(fg, ox + 27 * sf, oy + 5 * sf, 8 * sf, 17 * sf, 3 * sf, barColor);
  _drawRRect(fg, ox + 22 * sf, oy + 24 * sf, 8 * sf, 6 * sf, 3 * sf, barColor);
  _drawRRect(fg, ox + 13 * sf, oy + 28 * sf, 8 * sf, 15 * sf, 3 * sf, barColor);

  _savePng(fg, 'assets/images/app_logo_foreground.png');

  print('✅ Done — app_logo.png and app_logo_foreground.png generated.');
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
      // Corner rounding check
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
  print('Saved: $path');
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the HalkaArzBilgi logo from the app-gallery-icon.svg Figma asset.
/// Used across auth screens, splash, home etc.
/// [size] controls the width/height of the widget.
/// [withCircle] determines whether to show the green circle background (icon style)
/// or just the 3 green bars standalone (for use on dark backgrounds).
class AppLogo extends StatelessWidget {
  final double size;
  final bool withCircle;

  const AppLogo({super.key, this.size = 64.0, this.withCircle = false});

  @override
  Widget build(BuildContext context) {
    if (withCircle) {
      // Full icon variant: green circle + #111111 bars (matches app-gallery-icon.svg)
      return SvgPicture.asset(
        'assets/app-gallery-icon.svg',
        width: size,
        height: size,
      );
    }

    // Standalone bars variant (green bars on transparent bg — for use on dark screens)
    // Matches the logo shown in the user's reference image:
    // 3 green rounded rectangles arranged as a bar chart (tall right, short middle, medium left)
    final double scale = size / 64.0;
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(
        painter: _LogoBarsPainter(scale: scale),
      ),
    );
  }
}

class _LogoBarsPainter extends CustomPainter {
  final double scale;
  const _LogoBarsPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00B856);
    final double r = 4 * scale;

    // Based on app-gallery-icon.svg scaled to 64x64:
    // SVG is 48x48, scale to 64: factor = 64/48 = 1.333
    final double f = scale * (64 / 48);

    // Rect 1 (right / tall): x=27, y=5, w=8, h=17 → tallest bar on right
    _drawRRect(canvas, paint, 27 * f, 5 * f, 8 * f, 17 * f, r);
    // Rect 2 (middle / short): x=22, y=24, w=8, h=6 → short bar in middle
    _drawRRect(canvas, paint, 22 * f, 24 * f, 8 * f, 6 * f, r);
    // Rect 3 (left / medium): x=13, y=28, w=8, h=15 → medium bar on left
    _drawRRect(canvas, paint, 13 * f, 28 * f, 8 * f, 15 * f, r);
  }

  void _drawRRect(
      Canvas canvas, Paint paint, double x, double y, double w, double h, double r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

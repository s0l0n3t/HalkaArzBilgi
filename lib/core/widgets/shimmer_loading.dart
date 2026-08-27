import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';

/// Shimmer efektinin uygulandığı alanlar için ortak kontrolcü ve sarmalayıcı.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark ? AppColors.surface : const Color(0xFFE5E7EB));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF353538) : const Color(0xFFF3F4F6));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.1, 0.3, 0.4, 0.6, 0.9],
              colors: [
                base,
                base,
                highlight,
                base,
                base,
              ],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Skeleton kutucukları oluşturmak için yardımcı widget.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape,
    this.color,
  });

  const SkeletonBox.circular({
    super.key,
    required double size,
    this.color,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: shape != null
          ? ShapeDecoration(
              color: color ?? AppColors.surface,
              shape: shape!,
            )
          : BoxDecoration(
              color: color ?? AppColors.surface,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
    );
  }
}

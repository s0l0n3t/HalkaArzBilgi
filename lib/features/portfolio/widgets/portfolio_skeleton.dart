import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// PortfolioScreen için 1:1 geometriye sahip Shimmer Skeleton bileşeni.
/// Donut Chart Kartı, kare legend ve bordersız Hisse Tablosu listesini tam taklit eder.
/// aria-busy="true" karşılığı liveRegion: true ile ekran okuyucu bildirimi sağlar.
class PortfolioSkeleton extends StatelessWidget {
  const PortfolioSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Portföy bilgileri yükleniyor',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: ShimmerLoading(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Donut Pasta Grafiği Kartı Skeleton
              _buildDonutChartCardSkeleton(),
              const SizedBox(height: 16),

              // 2. Hisse Tablosu Skeleton (Bordersız, doğrudan kart altı)
              _buildPortfolioTableSkeleton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonutChartCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dış Halka
                Container(
                  width: 204,
                  height: 204,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E2E33),
                      width: 24,
                    ),
                  ),
                ),
                // Merkez Bilgi
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBox(
                      width: 75,
                      height: 12,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                    SizedBox(height: 6),
                    SkeletonBox(
                      width: 110,
                      height: 20,
                      borderRadius: 4,
                      color: Color(0xFF2E2E33),
                    ),
                    SizedBox(height: 6),
                    SkeletonBox(
                      width: 58,
                      height: 14,
                      borderRadius: 6,
                      color: Color(0xFF27272A),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Legend İskeleti: Kare + İsim + Yüzde
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 11, height: 11, borderRadius: 2.5, color: Color(0xFF2E2E33)),
              SizedBox(width: 6),
              SkeletonBox(width: 45, height: 13, borderRadius: 3, color: Color(0xFF2E2E33)),
              SizedBox(width: 4),
              SkeletonBox(width: 32, height: 12, borderRadius: 3, color: Color(0xFF27272A)),
              SizedBox(width: 16),
              SkeletonBox(width: 11, height: 11, borderRadius: 2.5, color: Color(0xFF2E2E33)),
              SizedBox(width: 6),
              SkeletonBox(width: 45, height: 13, borderRadius: 3, color: Color(0xFF2E2E33)),
              SizedBox(width: 4),
              SkeletonBox(width: 32, height: 12, borderRadius: 3, color: Color(0xFF27272A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTableSkeleton() {
    return Column(
      children: [
        // Başlık İskeleti: Hisse, Maliyet, Kazanç, % Kazanç
        const Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: SkeletonBox(width: 40, height: 14.5, borderRadius: 3, color: Color(0xFF27272A)),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonBox(width: 45, height: 14.5, borderRadius: 3, color: Color(0xFF27272A)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonBox(width: 45, height: 14.5, borderRadius: 3, color: Color(0xFF27272A)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonBox(width: 50, height: 14.5, borderRadius: 3, color: Color(0xFF27272A)),
                ),
              ),
            ],
          ),
        ),
        Divider(color: const Color(0xFF3F3F46), height: 1),

        // Satır İskeletleri
        ...List.generate(3, (index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                child: Row(
                  children: [
                    // Kare Kutu + Sembol
                    const Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          SkeletonBox(width: 12, height: 12, borderRadius: 3, color: Color(0xFF2E2E33)),
                          SizedBox(width: 8),
                          SkeletonBox(width: 54, height: 15.5, borderRadius: 3, color: Color(0xFF2E2E33)),
                        ],
                      ),
                    ),
                    // Maliyet
                    const Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SkeletonBox(width: 60, height: 14, borderRadius: 3, color: Color(0xFF2E2E33)),
                      ),
                    ),
                    // Kazanç
                    const Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SkeletonBox(width: 60, height: 14, borderRadius: 3, color: Color(0xFF27272A)),
                      ),
                    ),
                    // % Kazanç
                    const Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SkeletonBox(width: 50, height: 14, borderRadius: 3, color: Color(0xFF27272A)),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 2)
                const _SkeletonDashedDivider(),
            ],
          );
        }),
        const _SkeletonDashedDivider(),
      ],
    );
  }
}

class _SkeletonDashedDivider extends StatelessWidget {
  const _SkeletonDashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(
        painter: _SkeletonDashedLinePainter(),
        size: const Size(double.infinity, 1),
      ),
    );
  }
}

class _SkeletonDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E2E33)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      final endX = (startX + 4.0).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += 4.0 + 3.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

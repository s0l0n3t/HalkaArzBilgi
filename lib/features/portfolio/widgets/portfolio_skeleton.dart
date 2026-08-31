import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_item_skeleton.dart';

/// PortfolioScreen için 1:1 geometriye sahip Shimmer Skeleton bileşeni.
/// Donut Chart Kartı, Legend rozetleri ve Hisse Kartları listesini tam taklit eder.
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
              const SizedBox(height: 24),

              // 2. Hisse Listesi Başlığı
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(
                    width: 100,
                    height: 20,
                    borderRadius: 4,
                    color: Color(0xFF2E2E33),
                  ),
                  SkeletonBox(
                    width: 50,
                    height: 16,
                    borderRadius: 3,
                    color: Color(0xFF27272A),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Hisse Kartları Listesi Skeleton
              const WatchlistItemSkeleton(),
              const SizedBox(height: 12),
              const WatchlistItemSkeleton(),
              const SizedBox(height: 12),
              const WatchlistItemSkeleton(),
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
          // Donut Chart Dairesi & Merkez Metin
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dış Halka
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E2E33),
                      width: 20,
                    ),
                  ),
                ),
                // Merkez Bilgi
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBox(
                      width: 70,
                      height: 12,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                    SizedBox(height: 6),
                    SkeletonBox(
                      width: 90,
                      height: 18,
                      borderRadius: 4,
                      color: Color(0xFF2E2E33),
                    ),
                    SizedBox(height: 4),
                    SkeletonBox(
                      width: 50,
                      height: 12,
                      borderRadius: 3,
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

          // Legend Rozetleri
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(
                width: 60,
                height: 14,
                borderRadius: 4,
                color: Color(0xFF27272A),
              ),
              SizedBox(width: 16),
              SkeletonBox(
                width: 60,
                height: 14,
                borderRadius: 4,
                color: Color(0xFF27272A),
              ),
              SizedBox(width: 16),
              SkeletonBox(
                width: 60,
                height: 14,
                borderRadius: 4,
                color: Color(0xFF27272A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

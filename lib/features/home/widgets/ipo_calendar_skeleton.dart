import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// IpoCalendarWidget ile 1:1 aynı geometriye sahip Shimmer Skeleton.
/// Ay/Hafta başlığı ve 7 günlük takvim sütunlarını şablon olarak korur.
class IpoCalendarSkeleton extends StatelessWidget {
  const IpoCalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Halka arz takvimi yükleniyor',
      child: ShimmerLoading(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Genişletme İkonu
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(
                    width: 130,
                    height: 20,
                    borderRadius: 6,
                    color: Color(0xFF2E2E33),
                  ),
                  SkeletonBox(
                    width: 20,
                    height: 20,
                    borderRadius: 4,
                    color: Color(0xFF2E2E33),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 7 Günlük Takvim Çubuğu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  return Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        SkeletonBox(
                          width: 18,
                          height: 12,
                          borderRadius: 3,
                          color: Color(0xFF2E2E33),
                        ),
                        SizedBox(height: 8),
                        SkeletonBox(
                          width: 22,
                          height: 18,
                          borderRadius: 4,
                          color: Color(0xFF27272A),
                        ),
                        SizedBox(height: 6),
                        SkeletonBox.circular(
                          size: 6,
                          color: Color(0xFF35353A),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

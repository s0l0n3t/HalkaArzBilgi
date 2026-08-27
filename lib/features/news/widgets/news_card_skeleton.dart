import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// NewsCard ile 1:1 aynı geometriye sahip Shimmer Skeleton satırı.
/// Minimal: Başlık bloğu + alt satır (zaman + sembol rozeti) + divider.
class NewsCardSkeleton extends StatelessWidget {
  final bool hasTag;
  final bool showDivider;

  const NewsCardSkeleton({
    super.key,
    this.hasTag = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Haber kartı yükleniyor',
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Başlık Satırları (2 satır)
                  const SkeletonBox(
                    width: double.infinity,
                    height: 14,
                    borderRadius: 4,
                    color: Color(0xFF2E2E33),
                  ),
                  const SizedBox(height: 6),
                  const SkeletonBox(
                    width: 220,
                    height: 14,
                    borderRadius: 4,
                    color: Color(0xFF2E2E33),
                  ),
                  const SizedBox(height: 10),

                  // 2. Alt Satır: Zaman + Sembol Rozeti
                  Row(
                    children: [
                      const SkeletonBox(
                        width: 60,
                        height: 12,
                        borderRadius: 4,
                        color: Color(0xFF27272A),
                      ),
                      if (hasTag) ...[
                        const SizedBox(width: 10),
                        const SkeletonBox(
                          width: 64,
                          height: 22,
                          borderRadius: 4,
                          color: Color(0xFF2B2B2F),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.border.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}

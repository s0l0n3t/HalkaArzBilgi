import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// Bildirim Ayarları ekranındaki hisse tercihleri listesi için Shimmer Skeleton.
/// Sadece bildirimler ve tavan bildirimleri açıkken hisse listesi alanında gösterilir.
/// aria-busy="true" karşılığı liveRegion: true ile ekran okuyucu bildirimli.
class NotificationStockListSkeleton extends StatelessWidget {
  const NotificationStockListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Hisseler yükleniyor',
      child: ShimmerLoading(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Column(
            children: List.generate(4, (index) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SkeletonBox.circular(
                          size: 32,
                          color: Color(0xFF2E2E33),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(
                                width: 60,
                                height: 15,
                                borderRadius: 4,
                                color: Color(0xFF2E2E33),
                              ),
                              SizedBox(height: 4),
                              SkeletonBox(
                                width: 140,
                                height: 12,
                                borderRadius: 3,
                                color: Color(0xFF27272A),
                              ),
                            ],
                          ),
                        ),
                        SkeletonBox(
                          width: 40,
                          height: 24,
                          borderRadius: 12,
                          color: Color(0xFF2E2E33),
                        ),
                      ],
                    ),
                  ),
                  if (index < 3)
                    const Divider(
                      color: AppColors.border,
                      height: 0.5,
                      thickness: 0.5,
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

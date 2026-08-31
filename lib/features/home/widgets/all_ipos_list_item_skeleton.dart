import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// AllIposListItem ve AllIposSection ile 1:1 aynı geometriye sahip Shimmer Skeleton satırı.
class AllIposListItemSkeleton extends StatelessWidget {
  final bool showDivider;

  const AllIposListItemSkeleton({
    super.key,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo kutucuğu
              SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
              SizedBox(width: 12),
              // Şirket & Tarih bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBox(
                      width: 75,
                      height: 16,
                      borderRadius: 4,
                      color: Color(0xFF2E2E33),
                    ),
                    SizedBox(height: 4),
                    SkeletonBox(
                      width: 130,
                      height: 12,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                    SizedBox(height: 4),
                    SkeletonBox(
                      width: 90,
                      height: 12,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                  ],
                ),
              ),
              // Alarm ve Takip Buton yerleşimleri
              SkeletonBox.circular(
                size: 24,
                color: Color(0xFF27272A),
              ),
              SizedBox(width: 8),
              SkeletonBox.circular(
                size: 24,
                color: Color(0xFF27272A),
              ),
              SizedBox(width: 10),
              // Fiyat & Yüzde Rozeti
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(
                    width: 65,
                    height: 16,
                    borderRadius: 4,
                    color: Color(0xFF2E2E33),
                  ),
                  SizedBox(height: 4),
                  SkeletonBox(
                    width: 48,
                    height: 16,
                    borderRadius: 4,
                    color: Color(0xFF27272A),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            color: Color(0xFF333333),
            height: 1,
          ),
      ],
    );
  }
}

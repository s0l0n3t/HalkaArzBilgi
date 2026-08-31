import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// IpoListItem ve NewIposSection ile 1:1 aynı geometriye sahip Shimmer Skeleton satırı.
class IpoListItemSkeleton extends StatelessWidget {
  final bool showDivider;

  const IpoListItemSkeleton({
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
            children: [
              // Logo kutucuğu
              SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
              SizedBox(width: 12),
              // Bilgi sütunu: Sembol + Şirket adı + Tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBox(
                      width: 80,
                      height: 16,
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
                    SizedBox(height: 4),
                    SkeletonBox(
                      width: 110,
                      height: 12,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                  ],
                ),
              ),
              // Fiyat kutucuğu
              SkeletonBox(
                width: 70,
                height: 18,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
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

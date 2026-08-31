import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// WatchlistItem ile 1:1 aynı geometriye sahip Shimmer Skeleton kartı.
class WatchlistItemSkeleton extends StatelessWidget {
  const WatchlistItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222224),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 0.5,
        ),
      ),
      child: const Row(
        children: [
          // Logo kutucuğu
          SkeletonBox(
            width: 48,
            height: 48,
            borderRadius: 4,
            color: Color(0xFF2E2E33),
          ),
          SizedBox(width: 12),

          // Sembol / Lotlar / Maliyet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(
                  width: 70,
                  height: 16,
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
                SizedBox(height: 6),
                Row(
                  children: [
                    SkeletonBox(
                      width: 70,
                      height: 14,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                    SizedBox(width: 8),
                    SkeletonBox(
                      width: 45,
                      height: 14,
                      borderRadius: 3,
                      color: Color(0xFF27272A),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Güncel Fiyat + Yüzde Rozeti
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBox(
                width: 75,
                height: 18,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
              SizedBox(height: 6),
              SkeletonBox(
                width: 50,
                height: 20,
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

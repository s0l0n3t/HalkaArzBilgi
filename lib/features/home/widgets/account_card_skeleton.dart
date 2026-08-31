import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// AccountCard ile 1:1 aynı geometriye sahip Shimmer Skeleton.
/// aria-busy="true" karşılığı liveRegion: true ile erişilebilirlik bildirimli.
class AccountCardSkeleton extends StatelessWidget {
  const AccountCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Hesap bilgileri yükleniyor',
      child: const ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: Kullanıcı Adı + İkon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: 140,
                  height: 24,
                  borderRadius: 6,
                  color: Color(0xFF2E2E33),
                ),
                SkeletonBox(
                  width: 24,
                  height: 24,
                  borderRadius: 6,
                  color: Color(0xFF2E2E33),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Toplam Bakiye (Büyük Başlık)
            SkeletonBox(
              width: 180,
              height: 38,
              borderRadius: 8,
              color: Color(0xFF2E2E33),
            ),
            SizedBox(height: 10),
            // Kar/Zarar Satırı + Yüzde Rozeti
            Row(
              children: [
                SkeletonBox(
                  width: 100,
                  height: 18,
                  borderRadius: 4,
                  color: Color(0xFF27272A),
                ),
                SizedBox(width: 8),
                SkeletonBox(
                  width: 54,
                  height: 20,
                  borderRadius: 4,
                  color: Color(0xFF27272A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

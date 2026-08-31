import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// StockDetailScreen için 1:1 geometriye sahip Shimmer Skeleton bileşeni.
/// StockInfoCard, StockPriceHeader ve StockDetailsTable bölümlerini tam taklit eder.
/// aria-busy="true" karşılığı liveRegion: true ile ekran okuyucu bildirimi sağlar.
class StockDetailSkeleton extends StatelessWidget {
  const StockDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Hisse detayları yükleniyor',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: ShimmerLoading(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. StockInfoCard Skeleton (Logo + Sembol + Şirket)
              const Row(
                children: [
                  SkeletonBox(
                    width: 64,
                    height: 64,
                    borderRadius: 12,
                    color: Color(0xFF2E2E33),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: 90,
                          height: 24,
                          borderRadius: 4,
                          color: Color(0xFF2E2E33),
                        ),
                        SizedBox(height: 6),
                        SkeletonBox(
                          width: 170,
                          height: 16,
                          borderRadius: 3,
                          color: Color(0xFF27272A),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. StockPriceHeader Skeleton (Fiyat + Değişim + Rozet)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 160,
                    height: 40,
                    borderRadius: 6,
                    color: Color(0xFF2E2E33),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SkeletonBox(
                        width: 90,
                        height: 18,
                        borderRadius: 4,
                        color: Color(0xFF27272A),
                      ),
                      SizedBox(width: 12),
                      SkeletonBox(
                        width: 60,
                        height: 22,
                        borderRadius: 4,
                        color: Color(0xFF27272A),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. StockDetailsTable Skeleton (Kart içinde tablo satırları)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF222224),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(6, (index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SkeletonBox(
                                width: index.isEven ? 100 : 80,
                                height: 16,
                                borderRadius: 4,
                                color: const Color(0xFF27272A),
                              ),
                              SkeletonBox(
                                width: index.isEven ? 80 : 110,
                                height: 16,
                                borderRadius: 4,
                                color: const Color(0xFF2E2E33),
                              ),
                            ],
                          ),
                        ),
                        if (index < 5)
                          const Divider(
                            color: Color(0xFF333333),
                            height: 24,
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

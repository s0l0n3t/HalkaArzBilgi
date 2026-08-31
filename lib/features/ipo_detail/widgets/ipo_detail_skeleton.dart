import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// IpoDetailScreen için 1:1 geometriye sahip Shimmer Skeleton bileşeni.
/// Tüm bölümlerin (Header, Info, Tavan, Grafik, Tahsisat, Sonuçlar, Dökümanlar)
/// yapısını ve boyutlarını şablon olarak korur.
/// aria-busy="true" karşılığı liveRegion: true ile ekran okuyucu bildirimi sağlar.
class IpoDetailSkeleton extends StatelessWidget {
  const IpoDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Halka arz detayları yükleniyor',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: ShimmerLoading(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Logo + Ad/Sembol + Fiyat)
              _buildHeaderSkeleton(),
              const SizedBox(height: 16),

              // 1.5. Hesabım Kartı Skeleton
              _buildAccountCardSkeleton(),
              const SizedBox(height: 16),

              // 2. Bilgi Satırları Skeleton
              _buildBasicInfoSkeleton(),
              const SizedBox(height: 24),

              // 3. Tavan Serisi Skeleton (Gün daireleri)
              _buildTavanSkeleton(),
              const SizedBox(height: 28),

              // 4. Grafik & Zaman butonları Skeleton
              _buildGraphSkeleton(),
              const SizedBox(height: 28),

              // 5. Tahsisat Grupları Skeleton
              _buildAllocationSkeleton(),
              const SizedBox(height: 28),

              // 6. Halka Arz Sonuçları Skeleton
              _buildResultsSkeleton(),
              const SizedBox(height: 28),

              // 7. Dökümanlar Skeleton
              _buildDocumentsSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return const Row(
      children: [
        SkeletonBox(
          width: 56,
          height: 56,
          borderRadius: 8,
          color: Color(0xFF2E2E33),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: 100,
                height: 22,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
              SizedBox(height: 6),
              SkeletonBox(
                width: 160,
                height: 14,
                borderRadius: 3,
                color: Color(0xFF27272A),
              ),
            ],
          ),
        ),
        SkeletonBox(
          width: 70,
          height: 24,
          borderRadius: 4,
          color: Color(0xFF2E2E33),
        ),
      ],
    );
  }

  Widget _buildAccountCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C30), width: 0.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: 90,
                height: 13,
                borderRadius: 3,
                color: Color(0xFF27272A),
              ),
              SizedBox(height: 6),
              SkeletonBox(
                width: 120,
                height: 20,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBox(
                width: 60,
                height: 13,
                borderRadius: 3,
                color: Color(0xFF27272A),
              ),
              SizedBox(height: 6),
              SkeletonBox(
                width: 80,
                height: 18,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(
                width: 110,
                height: 14,
                borderRadius: 3,
                color: Color(0xFF27272A),
              ),
              SkeletonBox(
                width: index.isEven ? 130 : 90,
                height: 14,
                borderRadius: 3,
                color: const Color(0xFF2E2E33),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTavanSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 110,
          height: 16,
          borderRadius: 4,
          color: Color(0xFF2E2E33),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return const SkeletonBox.circular(
              size: 48,
              color: Color(0xFF27272A),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGraphSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zaman seçiciler
        Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SkeletonBox(
                width: 44,
                height: 28,
                borderRadius: 8,
                color: index == 0 ? const Color(0xFF2E2E33) : const Color(0xFF222226),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Grafik alanı
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2C30), width: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 130,
          height: 16,
          borderRadius: 4,
          color: Color(0xFF2E2E33),
        ),
        const SizedBox(height: 12),
        const SkeletonBox(
          width: double.infinity,
          height: 12,
          borderRadius: 6,
          color: Color(0xFF27272A),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SkeletonBox.circular(size: 8, color: Color(0xFF27272A)),
            const SizedBox(width: 6),
            const SkeletonBox(width: 80, height: 12, borderRadius: 3, color: Color(0xFF27272A)),
            const SizedBox(width: 16),
            const SkeletonBox.circular(size: 8, color: Color(0xFF27272A)),
            const SizedBox(width: 6),
            const SkeletonBox(width: 90, height: 12, borderRadius: 3, color: Color(0xFF27272A)),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(
            width: 140,
            height: 16,
            borderRadius: 4,
            color: Color(0xFF2E2E33),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonBox(width: 100, height: 13, borderRadius: 3, color: Color(0xFF27272A)),
                  SkeletonBox(width: index == 0 ? 80 : 60, height: 13, borderRadius: 3, color: const Color(0xFF2E2E33)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocumentsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 100,
          height: 16,
          borderRadius: 4,
          color: Color(0xFF2E2E33),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              SkeletonBox(width: 28, height: 28, borderRadius: 6, color: Color(0xFF27272A)),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonBox(width: 140, height: 14, borderRadius: 3, color: Color(0xFF2E2E33)),
              ),
              SkeletonBox(width: 18, height: 18, borderRadius: 4, color: Color(0xFF27272A)),
            ],
          ),
        ),
      ],
    );
  }
}

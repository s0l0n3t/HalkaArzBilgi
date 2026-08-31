import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

/// Arama ve Piyasa (SearchScreen) sayfası için Isı Haritası / Liste görünümü Skeleton bileşeni.
/// aria-busy="true" karşılığı liveRegion: true ile yükleme durumunu duyurur.
class SearchScreenSkeleton extends StatelessWidget {
  final bool isSearching;

  const SearchScreenSkeleton({
    super.key,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: isSearching
          ? 'Arama sonuçları yükleniyor'
          : 'Piyasa ısı haritası yükleniyor',
      child: isSearching ? _buildListSkeleton() : _buildHeatmapSkeleton(),
    );
  }

  /// Arama Listesi Görünümü Skeleton
  Widget _buildListSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: const ShimmerLoading(
            child: Row(
              children: [
                // Logo çemberi
                SkeletonBox.circular(
                  size: 38,
                  color: Color(0xFF2E2E33),
                ),
                SizedBox(width: 12),
                // Sembol + Şirket adı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 70,
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
                    ],
                  ),
                ),
                // Fiyat + Değişim rozeti
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBox(
                      width: 60,
                      height: 14,
                      borderRadius: 4,
                      color: Color(0xFF2E2E33),
                    ),
                    SizedBox(height: 6),
                    SkeletonBox(
                      width: 48,
                      height: 18,
                      borderRadius: 4,
                      color: Color(0xFF27272A),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// TradingView Isı Haritası Mozaik Geometrisini Koruyan Skeleton
  Widget _buildHeatmapSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ShimmerLoading(
        child: Column(
          children: [
            // Üst blok: Sol büyük kareler + Sağ ızgara
            SizedBox(
              height: 520,
              child: Row(
                children: [
                  // Sol sütun (2 büyük kare)
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildTileSkeleton(const Color(0xFF1B2E26)),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: _buildTileSkeleton(const Color(0xFF1B2E26)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Sağ sütun
                  Expanded(
                    flex: 11,
                    child: Column(
                      children: [
                        // Üst satır (2 orta kare)
                        Expanded(
                          flex: 11,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTileSkeleton(const Color(0xFF2C1E1E)),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: _buildTileSkeleton(const Color(0xFF1B2E26)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Orta satır (3 küçük kare)
                        Expanded(
                          flex: 9,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTileSkeleton(const Color(0xFF222226)),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: _buildTileSkeleton(const Color(0xFF1B2E26)),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: _buildTileSkeleton(const Color(0xFF2C1E1E)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Alt mikro grid (2 satır)
                        Expanded(
                          flex: 10,
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTileSkeleton(const Color(0xFF222226)),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: _buildTileSkeleton(const Color(0xFF1B2E26)),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: _buildTileSkeleton(const Color(0xFF222226)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTileSkeleton(const Color(0xFF2C1E1E)),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: _buildTileSkeleton(const Color(0xFF222226)),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: _buildTileSkeleton(const Color(0xFF1B2E26)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileSkeleton(Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF38383E),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 28,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E33),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

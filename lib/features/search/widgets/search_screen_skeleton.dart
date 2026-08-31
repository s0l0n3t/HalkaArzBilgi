import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';

enum _SkeletonTileSize { large, medium, small, mini, micro }

/// Arama ve Piyasa (SearchScreen) sayfası için Isı Haritası / Liste görünümü Skeleton bileşeni.
/// aria-busy="true" karşılığı liveRegion: true ile yükleme durumunu duyurur.
/// İki Katmanlı Zengin Asimetrik Mozaik Treemap (45 Hisse: 22 Üst + 23 Alt) geometrisi ile 1:1 eşleşir.
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
      shrinkWrap: true,
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

  /// İki Katmanlı Zengin Mozaik Treemap Geometrisini Birebir Koruyan Skeleton (45 Hisse)
  Widget _buildHeatmapSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ShimmerLoading(
        child: Column(
          children: [
            // ── 1. ÜST MOZAİK GRUBU (1-22. Hisse — 520px) ───────────────────
            SizedBox(
              height: 520,
              child: Row(
                children: [
                  // Sol Sütun: 2 Dev Blok
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildTileSkeleton(
                            size: _SkeletonTileSize.large,
                            bg: const Color(0xFF1B2E26),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: _buildTileSkeleton(
                            size: _SkeletonTileSize.large,
                            bg: const Color(0xFF1B2E26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Sağ Sütun: Çok Katmanlı Izgara
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        // 1. Satır: 2 Orta Blok (Flex 6 ve Flex 5)
                        Expanded(
                          flex: 13,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildTileSkeleton(
                                  size: _SkeletonTileSize.medium,
                                  bg: const Color(0xFF1B2E26),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                flex: 5,
                                child: _buildTileSkeleton(
                                  size: _SkeletonTileSize.medium,
                                  bg: const Color(0xFF1B2E26),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // 2. Satır: 3 Orta Blok
                        Expanded(
                          flex: 11,
                          child: Row(
                            children: [
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // 3. Satır: 3 Orta Blok
                        Expanded(
                          flex: 11,
                          child: Row(
                            children: [
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // 4. Bölüm (Alt Karma Izgara)
                        Expanded(
                          flex: 20,
                          child: Row(
                            children: [
                              // Sol Dikey 3 Blok
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF2C1E1E))),
                                    const SizedBox(height: 2),
                                    Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF1B2E26))),
                                    const SizedBox(height: 2),
                                    Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF2C1E1E))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2),

                              // Sağ Mozaik
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    // Üst Küçük Satır (2 Blok)
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF2C1E1E))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    // Orta Mini Satır (3 Blok)
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.mini, bg: const Color(0xFF222226))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.mini, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.mini, bg: const Color(0xFF222226))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    // Alt Micro Satır (4 Blok)
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF222226))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF222226))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF1B2E26))),
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
            const SizedBox(height: 2),

            // ── 2. ALT MOZAİK GRUBU (23-45. Hisse — 520px) ───────────────────
            SizedBox(
              height: 520,
              child: Row(
                children: [
                  // Sol Sütun: 2 Büyük Blok
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildTileSkeleton(
                            size: _SkeletonTileSize.large,
                            bg: const Color(0xFF1B2E26),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: _buildTileSkeleton(
                            size: _SkeletonTileSize.large,
                            bg: const Color(0xFF1B2E26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Sağ Sütun: Çok Katmanlı Izgara
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        // 1. Satır: 2 Orta Blok (Flex 6 ve Flex 5)
                        Expanded(
                          flex: 13,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildTileSkeleton(
                                  size: _SkeletonTileSize.medium,
                                  bg: const Color(0xFF1B2E26),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                flex: 5,
                                child: _buildTileSkeleton(
                                  size: _SkeletonTileSize.medium,
                                  bg: const Color(0xFF1B2E26),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // 2. Satır: 3 Orta Blok
                        Expanded(
                          flex: 11,
                          child: Row(
                            children: [
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // 3. Satır: 3 Orta Blok
                        Expanded(
                          flex: 11,
                          child: Row(
                            children: [
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                              const SizedBox(width: 2),
                              Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.medium, bg: const Color(0xFF1B2E26))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),

                        // 4. Bölüm (Alt Karma Izgara)
                        Expanded(
                          flex: 20,
                          child: Row(
                            children: [
                              // Sol Dikey 3 Blok
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF2C1E1E))),
                                    const SizedBox(height: 2),
                                    Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF1B2E26))),
                                    const SizedBox(height: 2),
                                    Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF2C1E1E))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2),

                              // Sağ Mozaik (10 Blok)
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    // Üst Küçük Satır (2 Blok)
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.small, bg: const Color(0xFF2C1E1E))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    // Orta Mini Satır (3 Blok)
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.mini, bg: const Color(0xFF222226))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.mini, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.mini, bg: const Color(0xFF222226))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    // Alt Micro Satır (5 Blok)
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF222226))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF222226))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF1B2E26))),
                                          const SizedBox(width: 2),
                                          Expanded(child: _buildTileSkeleton(size: _SkeletonTileSize.micro, bg: const Color(0xFF222226))),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTileSkeleton({
    required _SkeletonTileSize size,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bg,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: _buildTileContentSkeleton(size),
    );
  }

  Widget _buildTileContentSkeleton(_SkeletonTileSize size) {
    switch (size) {
      case _SkeletonTileSize.large:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFF2E2E33),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 58,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF38383E),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 46,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E33),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );

      case _SkeletonTileSize.medium:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF2E2E33),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 38,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF38383E),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 30,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E33),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );

      case _SkeletonTileSize.small:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF2E2E33),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 30,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF38383E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E33),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );

      case _SkeletonTileSize.mini:
        return Center(
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF2E2E33),
              shape: BoxShape.circle,
            ),
          ),
        );

      case _SkeletonTileSize.micro:
        return Center(
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFF2E2E33),
              shape: BoxShape.circle,
            ),
          ),
        );
    }
  }
}

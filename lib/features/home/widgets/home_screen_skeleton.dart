import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/shimmer_loading.dart';
import 'package:halkaarzbilgi/features/home/widgets/account_card_skeleton.dart';
import 'package:halkaarzbilgi/features/home/widgets/all_ipos_list_item_skeleton.dart';
import 'package:halkaarzbilgi/features/home/widgets/ipo_calendar_skeleton.dart';
import 'package:halkaarzbilgi/features/home/widgets/ipo_list_item_skeleton.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_item_skeleton.dart';

/// HomeScreen'in tüm yapısını yansıtan ana Skeleton bileşeni.
/// aria-busy="true" karşılığı liveRegion: true ile ekran okuyuculara bildirir.
class HomeScreenSkeleton extends StatelessWidget {
  final bool isLoggedIn;

  const HomeScreenSkeleton({
    super.key,
    this.isLoggedIn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Ana sayfa yükleniyor',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hesap Kartı (Sadece Giriş Yapmışsa)
            if (isLoggedIn) ...[
              const AccountCardSkeleton(),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 56), // Banner boşluğu
            ],

            // 2. Takvim Widgetı Skeleton
            const IpoCalendarSkeleton(),
            const SizedBox(height: 24),

            // 3. Yeni Halka Arzlar Bölümü
            const ShimmerLoading(
              child: SkeletonBox(
                width: 150,
                height: 20,
                borderRadius: 4,
                color: Color(0xFF2E2E33),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF222224),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ShimmerLoading(
                child: Column(
                  children: [
                    IpoListItemSkeleton(showDivider: true),
                    IpoListItemSkeleton(showDivider: true),
                    IpoListItemSkeleton(showDivider: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Portföy / İzleme Listesi Bölümü
            if (isLoggedIn) ...[
              const ShimmerLoading(
                child: SkeletonBox(
                  width: 130,
                  height: 20,
                  borderRadius: 4,
                  color: Color(0xFF2E2E33),
                ),
              ),
              const SizedBox(height: 12),
              const ShimmerLoading(
                child: Column(
                  children: [
                    WatchlistItemSkeleton(),
                    SizedBox(height: 12),
                    WatchlistItemSkeleton(),
                  ],
                ),
              ),
            ] else ...[
              const ShimmerLoading(
                child: SkeletonBox(
                  width: 130,
                  height: 20,
                  borderRadius: 4,
                  color: Color(0xFF2E2E33),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF222224),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ShimmerLoading(
                  child: Column(
                    children: [
                      AllIposListItemSkeleton(showDivider: true),
                      AllIposListItemSkeleton(showDivider: true),
                      AllIposListItemSkeleton(showDivider: false),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

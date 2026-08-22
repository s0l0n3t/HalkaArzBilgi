import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/auth_bottom_sheet.dart';

/// Giriş yapmamış kullanıcılar için ana sayfanın üstünde sabit kalan bilgi barı.
/// SliverPersistentHeader ile kullanılarak sticky (pinned) davranış sağlar.
class GuestStickyBanner extends StatelessWidget {
  const GuestStickyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _GuestStickyBannerDelegate(),
    );
  }
}

class _GuestStickyBannerDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return GestureDetector(
      onTap: () => AuthBottomSheet.show(context),
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Info icon — çember arka plan yok, sadece yeşil filled ikon
            const Icon(
              Icons.info_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
            const SizedBox(width: 12),
            // Info text
            Expanded(
              child: Text(
                'Halka arz için bildirim almak ve portföyünüzü ekleyebilmeniz için üye girişi yapın.',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

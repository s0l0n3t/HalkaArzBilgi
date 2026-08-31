import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/features/home/widgets/account_card.dart';
import 'package:halkaarzbilgi/features/home/widgets/all_ipos_section.dart';
import 'package:halkaarzbilgi/features/home/widgets/guest_sticky_banner.dart';
import 'package:halkaarzbilgi/features/home/widgets/ipo_calendar_widget.dart';
import 'package:halkaarzbilgi/features/home/widgets/new_ipos_section.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_section.dart';
import 'package:halkaarzbilgi/features/home/widgets/home_screen_skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool isLoading;

  const HomeScreen({
    super.key,
    this.isLoading = false,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 250;
    if (shouldShow != _showBackToTop) {
      setState(() {
        _showBackToTop = shouldShow;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: widget.isLoading
              ? HomeScreenSkeleton(
                  key: const ValueKey('home_skeleton'),
                  isLoggedIn: isLoggedIn,
                )
              : Stack(
                  key: const ValueKey('home_content'),
                  children: [
                    // Scroll content
                    isLoggedIn
                        ? _buildLoggedInBody()
                        : _buildGuestBody(),

                    // Floating banner (sadece giriş yapmamış kullanıcılar)
                    if (!isLoggedIn)
                      const Positioned(
                        top: 24,
                        left: 0,
                        right: 0,
                        child: GuestFloatingBanner(),
                      ),

            // Scroll-to-top button
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedScale(
                scale: _showBackToTop ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _showBackToTop ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _scrollToTop,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.background,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  /// Giriş yapmış kullanıcılar: mevcut SingleChildScrollView akışı.
  Widget _buildLoggedInBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountCard(),
            const SizedBox(height: 24),
            const IpoCalendarWidget(),
            const SizedBox(height: 24),
            const NewIposSection(),
            const SizedBox(height: 24),
            const WatchlistSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Giriş yapmamış kullanıcılar: düz SingleChildScrollView, banner üstte yüzer.
  Widget _buildGuestBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner için üstte boşluk (24px offset + banner yüksekliği sonrası içerik başlar)
            const SizedBox(height: 56),
            const IpoCalendarWidget(),
            const SizedBox(height: 24),
            const NewIposSection(),
            const SizedBox(height: 24),
            const AllIposSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

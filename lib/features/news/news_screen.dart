import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/tab_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/accessible_loading_spinner.dart';
import 'package:halkaarzbilgi/features/news/models/news_model.dart';
import 'package:halkaarzbilgi/features/news/providers/news_provider.dart';
import 'package:halkaarzbilgi/features/news/widgets/news_card.dart';
import 'package:halkaarzbilgi/features/news/widgets/news_card_skeleton.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late String _randomSymbolHint;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Her sayfa açılışında rastgele bir hisse kodu seç
    _randomSymbolHint = _pickRandomSymbol();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Popüler hisseler arasından rastgele birini seçer.
  String _pickRandomSymbol() {
    final symbols = NewsModel.popularSymbols;
    return symbols[Random().nextInt(symbols.length)];
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sekme geçişi dinleyicisi: Haberler sekmesine her geri dönüldüğünde sıfırla
    ref.listen<int>(tabIndexProvider, (previous, next) {
      if (next == 1 && previous != 1) {
        _searchController.clear();
        ref.read(newsProvider.notifier).resetFilters();
        setState(() {
          _randomSymbolHint = _pickRandomSymbol();
        });
        FocusScope.of(context).unfocus();
      }
    });

    final newsState = ref.watch(newsProvider);
    final notifier = ref.read(newsProvider.notifier);
    final symbolChips = NewsModel.newsSymbols;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Başlık: "Haberler" ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Text(
                'Haberler',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // ── 2. Arama Çubuğu (Rastgele hisse placeholder & Arama İkonu) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: notifier.setSearchQuery,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: _randomSymbolHint,
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (newsState.searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── 3. Hisse Sembol Çipleri (#SARAE, #TKNKA vb.) ──
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: symbolChips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final symbol = symbolChips[index];
                  final isSelected = newsState.selectedSymbol == symbol;
                  return GestureDetector(
                    onTap: () => notifier.selectSymbol(symbol),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen.withValues(alpha: 0.5)
                              : AppColors.border.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            symbol,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── 4. Ana İçerik Alanı ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: _buildContent(newsState, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(NewsState state, NewsNotifier notifier) {
    // 1. Hata Durumu
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.lossRed,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => notifier.loadInitialNews(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Yükleme Durumu (Skeleton — aria-busy karşılığı liveRegion)
    if (state.isLoading) {
      return Semantics(
        key: const ValueKey('news_loading_skeleton'),
        container: true,
        liveRegion: true,
        label: 'Haberler yükleniyor, lütfen bekleyin',
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            NewsCardSkeleton(hasTag: true),
            NewsCardSkeleton(hasTag: false),
            NewsCardSkeleton(hasTag: true),
            NewsCardSkeleton(hasTag: true),
            NewsCardSkeleton(hasTag: false),
          ],
        ),
      );
    }

    // 3. Boş Sonuç Durumu
    final filtered = state.filteredNews;
    if (filtered.isEmpty) {
      return Center(
        key: const ValueKey('news_empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.newspaper_rounded,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Haber bulunamadı',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Arama filtrenizi değiştirmeyi deneyebilirsiniz',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // 4. Başarılı Veri Durumu
    return Semantics(
      key: const ValueKey('news_data_list'),
      container: true,
      label: 'Haber listesi',
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        backgroundColor: AppColors.surface,
        onRefresh: () => notifier.refresh(),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filtered.length) {
              // Alt Sayfalama Yükleyicisi (role="status" / liveRegion: true)
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: AccessibleLoadingSpinner(
                  label: 'Yükleniyor...',
                  size: 24,
                  strokeWidth: 2.5,
                  showLabelText: true,
                ),
              );
            }

            final news = filtered[index];
            return NewsCard(
              news: news,
              showDivider: index < filtered.length - 1,
            );
          },
        ),
      ),
    );
  }
}

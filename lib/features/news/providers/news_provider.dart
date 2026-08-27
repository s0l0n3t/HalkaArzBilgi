import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/features/news/models/news_model.dart';

class NewsState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final NewsCategory selectedCategory;
  final String? selectedSymbol;
  final String searchQuery;
  final List<NewsModel> allNews;
  final String? errorMessage;
  final bool hasMore;

  const NewsState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.selectedCategory = NewsCategory.all,
    this.selectedSymbol,
    this.searchQuery = '',
    this.allNews = const [],
    this.errorMessage,
    this.hasMore = true,
  });

  List<NewsModel> get filteredNews {
    return allNews.where((item) {
      // Kategori filtresi
      final matchesCategory = selectedCategory == NewsCategory.all ||
          item.category == selectedCategory;
      if (!matchesCategory) return false;

      // Sembol filtresi (# çipleri)
      if (selectedSymbol != null && selectedSymbol!.isNotEmpty) {
        if (item.symbol != selectedSymbol) return false;
      }

      // Arama filtresi
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      final inTitle = item.title.toLowerCase().contains(q);
      final inSummary = item.summary.toLowerCase().contains(q);
      final inSymbol = item.symbol?.toLowerCase().contains(q) ?? false;
      final inSource = item.source.toLowerCase().contains(q);
      return inTitle || inSummary || inSymbol || inSource;
    }).toList();
  }

  NewsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    NewsCategory? selectedCategory,
    String? selectedSymbol,
    bool clearSymbol = false,
    String? searchQuery,
    List<NewsModel>? allNews,
    String? errorMessage,
    bool? hasMore,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSymbol: clearSymbol ? null : (selectedSymbol ?? this.selectedSymbol),
      searchQuery: searchQuery ?? this.searchQuery,
      allNews: allNews ?? this.allNews,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier() : super(const NewsState()) {
    loadInitialNews();
  }

  Future<void> loadInitialNews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Gerçekçi ağ gecikmesi simülasyonu (Skeleton görünümü için)
      await Future.delayed(const Duration(milliseconds: 900));
      state = state.copyWith(
        isLoading: false,
        allNews: NewsModel.mockNews,
        hasMore: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Haberler yüklenirken bir hata oluştu.',
      );
    }
  }

  Future<void> selectCategory(NewsCategory category) async {
    if (state.selectedCategory == category) return;
    
    // Kategori değiştiğinde skeleton görünümünü tetikle
    state = state.copyWith(
      selectedCategory: category,
      isLoading: true,
      errorMessage: null,
    );

    await Future.delayed(const Duration(milliseconds: 550));
    state = state.copyWith(isLoading: false);
  }

  /// Hisse sembolüne göre filtreleme (# çipleri).
  /// Zaten seçiliyse filtreyi kaldır (toggle).
  void selectSymbol(String symbol) {
    if (state.selectedSymbol == symbol) {
      state = state.copyWith(clearSymbol: true);
    } else {
      state = state.copyWith(selectedSymbol: symbol);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  /// Tüm arama metni ve seçili sembol/kategori filtrelerini sıfırlar.
  void resetFilters() {
    state = state.copyWith(
      clearSymbol: true,
      searchQuery: '',
      selectedCategory: NewsCategory.all,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      isRefreshing: false,
      allNews: NewsModel.mockNews,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    await Future.delayed(const Duration(milliseconds: 1000));

    // Ekstra haberler simülasyonu
    final moreNews = [
      NewsModel(
        id: 'news_${DateTime.now().millisecondsSinceEpoch}_1',
        title: 'Borsa İstanbul\'da yabancı yatırımcı girişi hız kazandı',
        summary: 'Merkezi Kayıt Kuruluşu verilerine göre yabancı payı bu hafta %38 seviyesine ulaştı.',
        source: 'Foreks',
        category: NewsCategory.bist,
        timeAgo: '12 saat önce',
      ),
      NewsModel(
        id: 'news_${DateTime.now().millisecondsSinceEpoch}_2',
        title: 'ASELS savunma sanayii ihracatında yeni anlaşma imzaladı',
        summary: 'Uluslararası bir müşteriyle 45 milyon dolarlık elektro-optik sistem tedarik sözleşmesi yapıldı.',
        source: 'KAP',
        category: NewsCategory.company,
        timeAgo: '14 saat önce',
        symbol: 'ASELS',
      ),
    ];

    state = state.copyWith(
      isLoadingMore: false,
      allNews: [...state.allNews, ...moreNews],
      hasMore: state.allNews.length < 14,
    );
  }
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier();
});

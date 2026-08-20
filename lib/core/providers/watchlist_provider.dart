import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/features/ipo_detail/services/chart_data_service.dart';
import 'package:halkaarzbilgi/features/ipo_detail/models/chart_data_model.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
/// Manages the set of symbols that have alerts (notifications) enabled.
/// All stocks in the user's watchlist start with alerts active by default.
class WatchlistNotifier extends StateNotifier<Set<String>> {
  WatchlistNotifier()
      : super(
          StockModel.mockWatchlist.map((s) => s.symbol).toSet(),
        );

  bool isAlertActive(String symbol) => state.contains(symbol);

  void toggleAlert(String symbol) {
    if (state.contains(symbol)) {
      state = {...state}..remove(symbol);
    } else {
      state = {...state, symbol};
    }
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, Set<String>>((ref) {
  return WatchlistNotifier();
});

/// A single portfolio entry tracking a user's position in a stock/IPO.
class UserPortfolioEntry {
  final String symbol;
  final String companyName;
  final int lots;
  final double costPrice; // halka arz fiyatı veya alış fiyatı

  const UserPortfolioEntry({
    required this.symbol,
    required this.companyName,
    required this.lots,
    required this.costPrice,
  });
}

/// Enriched stats that combine user's portfolio data with live market data.
class UserPortfolioStats {
  final UserPortfolioEntry entry;
  final double currentPrice;

  const UserPortfolioStats({
    required this.entry,
    required this.currentPrice,
  });

  /// Toplam maliyet
  double get totalCost => entry.lots * entry.costPrice;

  /// Toplam güncel değer
  double get totalValue => entry.lots * currentPrice;

  /// Birim kâr/zarar (TL)
  double get personalChange => currentPrice - entry.costPrice;

  /// Toplam TL kâr/zarar
  double get totalGainLoss => entry.lots * personalChange;

  /// Yüzdelik kişisel kâr/zarar
  double get personalChangePercent {
    if (entry.costPrice == 0) return 0;
    return (personalChange / entry.costPrice) * 100;
  }

  bool get isGain => personalChange >= 0;
}

/// Manages the user's portfolio (watchlist with lot data).
class WatchlistMarkNotifier extends StateNotifier<Map<String, UserPortfolioEntry>> {
  WatchlistMarkNotifier()
      : super({
          'ATATR': const UserPortfolioEntry(
            symbol: 'ATATR',
            companyName: 'Ata Turizm İşletmecilik',
            lots: 65,
            costPrice: 77.36,
          ),
          'SARAE': const UserPortfolioEntry(
            symbol: 'SARAE',
            companyName: 'Saray Enerji',
            lots: 35,
            costPrice: 38.00,
          ),
          'AAGYO': const UserPortfolioEntry(
            symbol: 'AAGYO',
            companyName: 'AA Gayrimenkul Yatırım',
            lots: 65,
            costPrice: 50.00,
          ),
        });

  bool isWatchlisted(String symbol) => state.containsKey(symbol);

  UserPortfolioEntry? getEntry(String symbol) => state[symbol];

  /// Add a stock to the portfolio with the given lot count.
  void addStock({
    required String symbol,
    required String companyName,
    required int lots,
    required double ipoPrice,
  }) {
    state = {
      ...state,
      symbol: UserPortfolioEntry(
        symbol: symbol,
        companyName: companyName,
        lots: lots,
        costPrice: ipoPrice,
      ),
    };
  }

  /// Remove a stock from the portfolio.
  void removeStock(String symbol) {
    state = Map.from(state)..remove(symbol);
  }
}

final watchlistMarkProvider = StateNotifierProvider<WatchlistMarkNotifier,
    Map<String, UserPortfolioEntry>>((ref) {
  return WatchlistMarkNotifier();
});

/// Combined provider that merges UserPortfolioEntry with the real-time StockModel price.
final portfolioStatsProvider = Provider<List<UserPortfolioStats>>((ref) {
  final portfolioMap = ref.watch(watchlistMarkProvider);
  // Use chart service to get deterministic latest price based on entry's cost price
  final chartService = MockChartDataService();

  return portfolioMap.values.map((entry) {
    // Generate daily chart data using the entry's cost price as the base
    final chartData = chartService.getChartData(
      symbol: entry.symbol,
      period: ChartPeriod.day,
      basePrice: entry.costPrice,
    );
    final latestPrice = chartData.lastPrice;
    return UserPortfolioStats(entry: entry, currentPrice: latestPrice);
  }).toList();
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final double costPrice; // halka arz fiyatı (alış fiyatı)
  final double currentPrice;
  final double change; // TL fiyat değişimi
  final double changePercent;

  const UserPortfolioEntry({
    required this.symbol,
    required this.companyName,
    required this.lots,
    required this.costPrice,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
  });

  /// Toplam maliyet = lots * costPrice
  double get totalCost => lots * costPrice;

  /// Toplam güncel değer = lots * currentPrice
  double get totalValue => lots * currentPrice;

  /// Toplam TL kar/zarar = lots * change
  double get totalGainLoss => lots * change;

  bool get isGain => change >= 0;
}

/// Manages the user's portfolio (watchlist with lot data).
/// State is a `Map<String, UserPortfolioEntry>` keyed by symbol.
class WatchlistMarkNotifier
    extends StateNotifier<Map<String, UserPortfolioEntry>> {
  WatchlistMarkNotifier()
      : super({
          // Seed from mock watchlist data
          for (final s in StockModel.mockWatchlist)
            s.symbol: UserPortfolioEntry(
              symbol: s.symbol,
              companyName: s.companyName,
              lots: s.lots,
              costPrice: s.costPrice,
              currentPrice: s.currentPrice,
              change: s.change,
              changePercent: s.changePercent,
            ),
        });

  bool isWatchlisted(String symbol) => state.containsKey(symbol);

  UserPortfolioEntry? getEntry(String symbol) => state[symbol];

  /// Add a stock to the portfolio with the given lot count.
  /// Uses IpoModel data to compute cost/current price/change.
  void addStock({
    required String symbol,
    required String companyName,
    required int lots,
    required double ipoPrice,
    required double currentPrice,
    required double change,
    required double changePercent,
  }) {
    state = {
      ...state,
      symbol: UserPortfolioEntry(
        symbol: symbol,
        companyName: companyName,
        lots: lots,
        costPrice: ipoPrice,
        currentPrice: currentPrice,
        change: change,
        changePercent: changePercent,
      ),
    };
  }

  /// Remove a stock from the portfolio.
  void removeStock(String symbol) {
    state = Map.from(state)..remove(symbol);
  }

  /// Total portfolio value across all entries.
  double get totalPortfolioValue =>
      state.values.fold(0.0, (sum, e) => sum + e.totalCost);

  /// Total gain/loss in TL across all entries.
  double get totalGainLoss =>
      state.values.fold(0.0, (sum, e) => sum + e.totalGainLoss);

  /// Total gain/loss percentage (weighted).
  double get totalGainLossPercent {
    final total = totalPortfolioValue;
    if (total == 0) return 0;
    return (totalGainLoss / total) * 100;
  }
}

final watchlistMarkProvider = StateNotifierProvider<WatchlistMarkNotifier,
    Map<String, UserPortfolioEntry>>((ref) {
  return WatchlistMarkNotifier();
});


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

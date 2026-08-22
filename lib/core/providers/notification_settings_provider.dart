import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:permission_handler/permission_handler.dart';

/// State model representing all notification preferences.
class NotificationSettingsState {
  final bool masterEnabled;
  final bool tavanEnabled;
  final bool newsEnabled;
  final bool newIposEnabled;
  final Set<String> enabledStocks;

  const NotificationSettingsState({
    required this.masterEnabled,
    required this.tavanEnabled,
    required this.newsEnabled,
    required this.newIposEnabled,
    required this.enabledStocks,
  });

  NotificationSettingsState copyWith({
    bool? masterEnabled,
    bool? tavanEnabled,
    bool? newsEnabled,
    bool? newIposEnabled,
    Set<String>? enabledStocks,
  }) {
    return NotificationSettingsState(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      tavanEnabled: tavanEnabled ?? this.tavanEnabled,
      newsEnabled: newsEnabled ?? this.newsEnabled,
      newIposEnabled: newIposEnabled ?? this.newIposEnabled,
      enabledStocks: enabledStocks ?? this.enabledStocks,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier()
      : super(NotificationSettingsState(
          masterEnabled: true,
          tavanEnabled: true,
          newsEnabled: true,
          newIposEnabled: true,
          enabledStocks: StockModel.mockWatchlist.map((s) => s.symbol).toSet(),
        ));

  void toggleMaster() {
    final newValue = !state.masterEnabled;
    state = state.copyWith(
      masterEnabled: newValue,
    );
    if (newValue) {
      Permission.notification.request();
    }
  }

  void toggleTavan() => state = state.copyWith(tavanEnabled: !state.tavanEnabled);
  void toggleNews() => state = state.copyWith(newsEnabled: !state.newsEnabled);
  void toggleNewIpos() => state = state.copyWith(newIposEnabled: !state.newIposEnabled);

  void toggleStock(String symbol) {
    final newSet = Set<String>.from(state.enabledStocks);
    if (newSet.contains(symbol)) {
      newSet.remove(symbol);
    } else {
      newSet.add(symbol);
    }
    state = state.copyWith(enabledStocks: newSet);
  }

  void selectAllStocks(Iterable<String> symbols) {
    state = state.copyWith(enabledStocks: Set<String>.from(symbols));
  }

  void deselectAllStocks() {
    state = state.copyWith(enabledStocks: {});
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier();
});

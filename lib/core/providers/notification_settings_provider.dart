import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State model representing all notification preferences.
class NotificationSettingsState {
  final bool masterEnabled;
  final bool tavanEnabled;
  final bool newsEnabled;
  final bool newIposEnabled;
  final Set<String> enabledStocks;
  final bool isLoaded;

  const NotificationSettingsState({
    required this.masterEnabled,
    required this.tavanEnabled,
    required this.newsEnabled,
    required this.newIposEnabled,
    required this.enabledStocks,
    this.isLoaded = false,
  });

  NotificationSettingsState copyWith({
    bool? masterEnabled,
    bool? tavanEnabled,
    bool? newsEnabled,
    bool? newIposEnabled,
    Set<String>? enabledStocks,
    bool? isLoaded,
  }) {
    return NotificationSettingsState(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      tavanEnabled: tavanEnabled ?? this.tavanEnabled,
      newsEnabled: newsEnabled ?? this.newsEnabled,
      newIposEnabled: newIposEnabled ?? this.newIposEnabled,
      enabledStocks: enabledStocks ?? this.enabledStocks,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  static const _keyMaster = 'notif_master_enabled';
  static const _keyTavan = 'notif_tavan_enabled';
  static const _keyNews = 'notif_news_enabled';
  static const _keyNewIpos = 'notif_new_ipos_enabled';
  static const _keyStocks = 'notif_enabled_stocks';

  NotificationSettingsNotifier()
      : super(NotificationSettingsState(
          masterEnabled: false,
          tavanEnabled: true,
          newsEnabled: true,
          newIposEnabled: true,
          enabledStocks: StockModel.mockWatchlist.map((s) => s.symbol).toSet(),
          isLoaded: false,
        )) {
    loadSettings();
  }

  /// Cihaz hafızasındaki ayarları yükler ve sistem izniyle senkronize eder.
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = await Permission.notification.status;
      final isSystemGranted = status.isGranted;

      final savedMaster = prefs.getBool(_keyMaster) ?? true;
      final savedTavan = prefs.getBool(_keyTavan) ?? true;
      final savedNews = prefs.getBool(_keyNews) ?? true;
      final savedNewIpos = prefs.getBool(_keyNewIpos) ?? true;
      final savedStocksList = prefs.getStringList(_keyStocks);

      final Set<String> effectiveStocks = savedStocksList != null
          ? savedStocksList.toSet()
          : StockModel.mockWatchlist.map((s) => s.symbol).toSet();

      // Cihaz sistem izni yoksa master şalter açık başlayamaz
      final effectiveMaster = isSystemGranted ? savedMaster : false;

      state = NotificationSettingsState(
        masterEnabled: effectiveMaster,
        tavanEnabled: savedTavan,
        newsEnabled: savedNews,
        newIposEnabled: savedNewIpos,
        enabledStocks: effectiveStocks,
        isLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  /// Cihaz işletim sistemi bildirim iznini kontrol edip şalteri senkronize eder.
  Future<void> syncWithSystemPermission() async {
    try {
      final status = await Permission.notification.status;
      final isSystemGranted = status.isGranted;

      if (!isSystemGranted && state.masterEnabled) {
        state = state.copyWith(masterEnabled: false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyMaster, false);
      } else if (isSystemGranted) {
        final prefs = await SharedPreferences.getInstance();
        final savedMaster = prefs.getBool(_keyMaster) ?? true;
        if (state.masterEnabled != savedMaster) {
          state = state.copyWith(masterEnabled: savedMaster);
        }
      }
    } catch (_) {}
  }

  Future<void> toggleMaster() async {
    final newValue = !state.masterEnabled;
    state = state.copyWith(masterEnabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaster, newValue);
  }

  Future<void> setMasterEnabled(bool value) async {
    state = state.copyWith(masterEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaster, value);
  }

  Future<void> toggleTavan() async {
    final newValue = !state.tavanEnabled;
    state = state.copyWith(tavanEnabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTavan, newValue);
  }

  Future<void> toggleNews() async {
    final newValue = !state.newsEnabled;
    state = state.copyWith(newsEnabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNews, newValue);
  }

  Future<void> toggleNewIpos() async {
    final newValue = !state.newIposEnabled;
    state = state.copyWith(newIposEnabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNewIpos, newValue);
  }

  Future<void> toggleStock(String symbol) async {
    final newSet = Set<String>.from(state.enabledStocks);
    if (newSet.contains(symbol)) {
      newSet.remove(symbol);
    } else {
      newSet.add(symbol);
    }
    state = state.copyWith(enabledStocks: newSet);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyStocks, newSet.toList());
  }

  Future<void> selectAllStocks(Iterable<String> symbols) async {
    final newSet = Set<String>.from(symbols);
    state = state.copyWith(enabledStocks: newSet);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyStocks, newSet.toList());
  }

  Future<void> deselectAllStocks() async {
    state = state.copyWith(enabledStocks: {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyStocks, []);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier();
});

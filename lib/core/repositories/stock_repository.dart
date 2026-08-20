import 'package:halkaarzbilgi/features/home/models/stock_model.dart';

/// Tüm borsa verilerini (hisseler, kâr/zarar, günlük değişim) çeken katmanın arayüzü.
abstract class IStockRepository {
  /// Tüm piyasa hisselerini getirir.
  Future<List<StockModel>> getAllStocks();
  
  /// Belirli bir hissenin detayını getirir.
  Future<StockModel?> getStockBySymbol(String symbol);
}

/// Uzak sunucudan veri gelmesini (ör. REST API) simüle eden sahte repository.
/// Veritabanı (Supabase/Firebase/REST API) entegrasyonu tamamlandığında 
/// bu sınıf yerine `RestStockRepository` yazılacaktır.
class MockRemoteStockRepository implements IStockRepository {
  @override
  Future<List<StockModel>> getAllStocks() async {
    // Ağ gecikmesini simüle et (1 saniye)
    await Future.delayed(const Duration(seconds: 1));
    
    // Şimdilik StockModel içindeki mock veriyi döndürüyoruz.
    // Gerçek yapıda burada http.get veya Supabase query çalışacak.
    return StockModel.mockWatchlist;
  }

  @override
  Future<StockModel?> getStockBySymbol(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return StockModel.mockWatchlist.firstWhere((s) => s.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
}

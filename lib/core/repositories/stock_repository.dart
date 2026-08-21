import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/features/ipo_detail/models/chart_data_model.dart';
import 'package:halkaarzbilgi/features/ipo_detail/services/chart_data_service.dart';

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
  final MockChartDataService _chartService = MockChartDataService();

  @override
  Future<List<StockModel>> getAllStocks() async {
    // Ağ gecikmesini simüle et (150ms)
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Tüm hisseleri grafikteki 1 günlük değişim ve son fiyat bilgileriyle dinamik oluştur
    return IpoModel.mockAllIpos.asMap().entries.map((entry) {
      final index = entry.key;
      final ipo = entry.value;

      final chartData = _chartService.getChartData(
        symbol: ipo.symbol,
        period: ChartPeriod.day,
        basePrice: ipo.price,
      );

      return StockModel(
        id: (index + 1).toString(),
        symbol: ipo.symbol,
        companyName: ipo.companyName,
        currentPrice: chartData.lastPrice,
        change: chartData.changeTL,
        changePercent: chartData.changePercent,
        logoUrl: ipo.logoUrl,
        tavanSeriDays: ipo.tavanSeriDays,
        tavanSeriCompleted: ipo.tavanSeriCompleted,
      );
    }).toList();
  }

  @override
  Future<StockModel?> getStockBySymbol(String symbol) async {
    final all = await getAllStocks();
    try {
      return all.firstWhere((s) => s.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
}

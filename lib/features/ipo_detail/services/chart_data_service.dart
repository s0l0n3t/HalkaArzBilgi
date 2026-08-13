import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:halkaarzbilgi/features/ipo_detail/models/chart_data_model.dart';

/// BIST hisselerine benzer gerçekçi stokastik fiyat verisi üreten mock servis.
/// İleride Yahoo Finance API ile değiştirilecek.
class MockChartDataService {
  /// Belirli bir hisse ve periyot için grafik verisi üretir.
  /// [symbol] bazlı seed kullanılır — aynı hisse her zaman aynı veriyi üretir.
  /// [basePrice] hissenin temel fiyatı (IPO fiyatı veya mevcut fiyat).
  ChartData getChartData({
    required String symbol,
    required ChartPeriod period,
    required double basePrice,
  }) {
    // Symbol bazlı deterministik seed
    final seed = symbol.codeUnits.fold<int>(0, (sum, c) => sum * 31 + c);
    // Her periyot için farklı seed
    final periodSeed = seed + period.index * 1000;
    final random = Random(periodSeed);

    final int pointCount = _getPointCount(period);
    final double volatility = _getVolatility(period);
    final double drift = _getDrift(period, random);

    // Stokastik fiyat serisi üret (Geometric Brownian Motion benzeri)
    final List<double> prices = _generatePrices(
      random: random,
      basePrice: basePrice,
      pointCount: pointCount,
      volatility: volatility,
      drift: drift,
    );

    // Zaman damgaları oluştur
    final List<ChartDataPoint> dataPoints = _generateDataPoints(
      period: period,
      prices: prices,
    );

    // FlSpot listesine dönüştür
    final List<FlSpot> spots = List.generate(
      prices.length,
      (i) => FlSpot(i.toDouble(), prices[i]),
    );

    final double minPrice = prices.reduce(min);
    final double maxPrice = prices.reduce(max);

    return ChartData(
      spots: spots,
      openPrice: prices.first,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lastPrice: prices.last,
      period: period,
      dataPoints: dataPoints,
    );
  }

  /// Periyoda göre veri noktası sayısı
  int _getPointCount(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.day:
        return 480; // 10:00-18:00, her 1 dk
      case ChartPeriod.week:
        return 240; // 5 iş günü, her 10 dk (48/gün × 5)
      case ChartPeriod.month:
        return 22; // ~22 iş günü
      case ChartPeriod.threeMonths:
        return 66; // ~66 iş günü
      case ChartPeriod.year:
        return 252; // ~252 iş günü
      case ChartPeriod.all:
        return 504; // ~2 yıl iş günü
    }
  }

  /// Periyoda göre volatilite (dalgalanma şiddeti)
  double _getVolatility(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.day:
        return 0.002; // Dakikalık: düşük volatilite
      case ChartPeriod.week:
        return 0.003; // 10 dk'lık: orta-düşük
      case ChartPeriod.month:
        return 0.015; // Günlük: orta
      case ChartPeriod.threeMonths:
        return 0.018; // Günlük: orta-yüksek
      case ChartPeriod.year:
        return 0.020; // Günlük: yüksek
      case ChartPeriod.all:
        return 0.022; // Günlük: en yüksek
    }
  }

  /// Rastgele trend yönü (yukarı/aşağı/yatay)
  double _getDrift(ChartPeriod period, Random random) {
    // -1 ile 1 arası rastgele drift
    final baseDrift = (random.nextDouble() - 0.4) * 0.001;
    switch (period) {
      case ChartPeriod.day:
        return baseDrift * 0.5;
      case ChartPeriod.week:
        return baseDrift * 0.8;
      case ChartPeriod.month:
        return baseDrift * 1.0;
      case ChartPeriod.threeMonths:
        return baseDrift * 1.2;
      case ChartPeriod.year:
        return baseDrift * 1.5;
      case ChartPeriod.all:
        return baseDrift * 2.0;
    }
  }

  /// Geometric Brownian Motion benzeri fiyat serisi üretir
  List<double> _generatePrices({
    required Random random,
    required double basePrice,
    required int pointCount,
    required double volatility,
    required double drift,
  }) {
    final prices = <double>[basePrice];

    for (int i = 1; i < pointCount; i++) {
      final prevPrice = prices[i - 1];

      // Box-Muller dönüşümü ile normal dağılım
      final u1 = random.nextDouble();
      final u2 = random.nextDouble();
      final normalRandom = sqrt(-2 * log(u1)) * cos(2 * pi * u2);

      // GBM formülü: S(t+1) = S(t) * exp(drift + volatility * Z)
      final change = exp(drift + volatility * normalRandom);
      var newPrice = prevPrice * change;

      // Fiyatın sıfırın altına düşmesini engelle
      if (newPrice < basePrice * 0.3) {
        newPrice = basePrice * 0.3 + random.nextDouble() * basePrice * 0.05;
      }

      prices.add(double.parse(newPrice.toStringAsFixed(2)));
    }

    return prices;
  }

  /// Periyoda göre zaman damgalı veri noktaları oluşturur
  List<ChartDataPoint> _generateDataPoints({
    required ChartPeriod period,
    required List<double> prices,
  }) {
    final now = DateTime.now();
    final dataPoints = <ChartDataPoint>[];

    switch (period) {
      case ChartPeriod.day:
        // Bugünün 10:00'ından itibaren her dakika
        final startOfDay = DateTime(now.year, now.month, now.day, 10, 0);
        for (int i = 0; i < prices.length; i++) {
          dataPoints.add(ChartDataPoint(
            time: startOfDay.add(Duration(minutes: i)),
            price: prices[i],
          ));
        }
        break;

      case ChartPeriod.week:
        // Son 5 iş gününü bul, her gün 48 veri noktası (10 dk aralıklı)
        final businessDays = _getLastBusinessDays(now, 5);
        int priceIndex = 0;
        for (final day in businessDays) {
          final startOfDay = DateTime(day.year, day.month, day.day, 10, 0);
          for (int j = 0; j < 48 && priceIndex < prices.length; j++) {
            dataPoints.add(ChartDataPoint(
              time: startOfDay.add(Duration(minutes: j * 10)),
              price: prices[priceIndex],
            ));
            priceIndex++;
          }
        }
        break;

      case ChartPeriod.month:
        // Son ~22 iş günü
        final businessDays = _getLastBusinessDays(now, prices.length);
        for (int i = 0; i < prices.length && i < businessDays.length; i++) {
          dataPoints.add(ChartDataPoint(
            time: businessDays[i],
            price: prices[i],
          ));
        }
        break;

      case ChartPeriod.threeMonths:
        final businessDays = _getLastBusinessDays(now, prices.length);
        for (int i = 0; i < prices.length && i < businessDays.length; i++) {
          dataPoints.add(ChartDataPoint(
            time: businessDays[i],
            price: prices[i],
          ));
        }
        break;

      case ChartPeriod.year:
        final businessDays = _getLastBusinessDays(now, prices.length);
        for (int i = 0; i < prices.length && i < businessDays.length; i++) {
          dataPoints.add(ChartDataPoint(
            time: businessDays[i],
            price: prices[i],
          ));
        }
        break;

      case ChartPeriod.all:
        final businessDays = _getLastBusinessDays(now, prices.length);
        for (int i = 0; i < prices.length && i < businessDays.length; i++) {
          dataPoints.add(ChartDataPoint(
            time: businessDays[i],
            price: prices[i],
          ));
        }
        break;
    }

    return dataPoints;
  }

  /// Belirli bir tarihten geriye doğru N iş günü döndürür (hafta sonları hariç)
  List<DateTime> _getLastBusinessDays(DateTime fromDate, int count) {
    final days = <DateTime>[];
    var current = fromDate;

    while (days.length < count) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        days.add(current);
      }
      current = current.subtract(const Duration(days: 1));
    }

    // Eski tarihten yeniye doğru sırala
    return days.reversed.toList();
  }

  // === X Ekseni Etiket Yardımcıları ===

  /// Periyoda göre X ekseni etiketi döndürür
  String? getBottomTitle(ChartPeriod period, int index, List<ChartDataPoint> dataPoints) {
    if (index < 0 || index >= dataPoints.length) return null;

    switch (period) {
      case ChartPeriod.day:
        return _getDayLabel(index);
      case ChartPeriod.week:
        return _getWeekLabel(index, dataPoints);
      case ChartPeriod.month:
        return _getMonthLabel(index, dataPoints);
      case ChartPeriod.threeMonths:
        return _getThreeMonthLabel(index, dataPoints);
      case ChartPeriod.year:
        return _getYearLabel(index, dataPoints);
      case ChartPeriod.all:
        return _getAllLabel(index, dataPoints);
    }
  }

  /// Günlük: Her 2 saatte bir etiket (10:00, 12:00, 14:00, 16:00, 18:00)
  String? _getDayLabel(int index) {
    // 480 dk = 10:00-18:00, her 120 dk (2 saat) = 0, 120, 240, 360, 479
    if (index == 0) return '10:00';
    if (index == 120) return '12:00';
    if (index == 240) return '14:00';
    if (index == 360) return '16:00';
    if (index == 479) return '18:00';
    return null;
  }

  /// Haftalık: Her günün başında gün adı
  String? _getWeekLabel(int index, List<ChartDataPoint> dataPoints) {
    // Her 48 indeks = 1 gün
    if (index % 48 == 0 && index < dataPoints.length) {
      final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
      final weekday = dataPoints[index].time.weekday;
      return dayNames[weekday - 1];
    }
    return null;
  }

  /// Aylık: Her 5 iş gününde bir tarih
  String? _getMonthLabel(int index, List<ChartDataPoint> dataPoints) {
    if (index % 5 == 0 && index < dataPoints.length) {
      final dt = dataPoints[index].time;
      return '${dt.day} ${_shortMonthName(dt.month)}';
    }
    return null;
  }

  /// 3 Aylık: Her ayın başında ay adı
  String? _getThreeMonthLabel(int index, List<ChartDataPoint> dataPoints) {
    if (index >= dataPoints.length) return null;
    if (index == 0) {
      return _shortMonthName(dataPoints[0].time.month);
    }
    // Ay değiştiğinde etiket göster
    if (index > 0 &&
        dataPoints[index].time.month != dataPoints[index - 1].time.month) {
      return _shortMonthName(dataPoints[index].time.month);
    }
    return null;
  }

  /// Yıllık: Her ayın başında ay adı
  String? _getYearLabel(int index, List<ChartDataPoint> dataPoints) {
    if (index >= dataPoints.length) return null;
    if (index == 0) {
      return _shortMonthName(dataPoints[0].time.month);
    }
    if (index > 0 &&
        dataPoints[index].time.month != dataPoints[index - 1].time.month) {
      return _shortMonthName(dataPoints[index].time.month);
    }
    return null;
  }

  /// Hepsi: Her 3 ayda bir etiket
  String? _getAllLabel(int index, List<ChartDataPoint> dataPoints) {
    if (index >= dataPoints.length) return null;
    if (index == 0) {
      final dt = dataPoints[0].time;
      return '${_shortMonthName(dt.month)} ${dt.year.toString().substring(2)}';
    }
    if (index > 0 &&
        dataPoints[index].time.month != dataPoints[index - 1].time.month &&
        dataPoints[index].time.month % 3 == 1) {
      final dt = dataPoints[index].time;
      return '${_shortMonthName(dt.month)} ${dt.year.toString().substring(2)}';
    }
    return null;
  }

  /// Kısa ay adı
  String _shortMonthName(int month) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return months[month - 1];
  }
}

import 'package:fl_chart/fl_chart.dart';

/// Grafik zaman periyodu
enum ChartPeriod {
  day,       // 1 Gün
  week,      // 1 Hafta
  month,     // 1 Ay
  threeMonths, // 3 Ay
  year,      // 1 Yıl
  all,       // Hepsi
}

/// Tek bir grafik veri noktası
class ChartDataPoint {
  final DateTime time;
  final double price;

  const ChartDataPoint({required this.time, required this.price});
}

/// Bir periyot için tüm grafik verisini tutan sınıf
class ChartData {
  final List<FlSpot> spots;
  final double openPrice;    // Periyodun açılış fiyatı
  final double minPrice;     // En düşük fiyat
  final double maxPrice;     // En yüksek fiyat
  final double lastPrice;    // Son fiyat
  final ChartPeriod period;
  final List<ChartDataPoint> dataPoints; // Zaman damgalı veri noktaları

  const ChartData({
    required this.spots,
    required this.openPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.lastPrice,
    required this.period,
    required this.dataPoints,
  });

  /// Kâr durumu: son fiyat >= açılış fiyatı
  bool get isGain => lastPrice >= openPrice;

  /// TL değişim
  double get changeTL => lastPrice - openPrice;

  /// Yüzde değişim
  double get changePercent =>
      openPrice != 0 ? ((lastPrice - openPrice) / openPrice) * 100 : 0.0;
}

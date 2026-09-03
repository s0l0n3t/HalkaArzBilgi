import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';
import 'package:halkaarzbilgi/features/ipo_detail/models/chart_data_model.dart';
import 'package:halkaarzbilgi/features/ipo_detail/services/chart_data_service.dart';
import 'package:url_launcher/url_launcher.dart';

class _ChartScaleConfig {
  final double minY;
  final double maxY;
  final double step;
  final double? referenceLine;

  const _ChartScaleConfig({
    required this.minY,
    required this.maxY,
    required this.step,
    this.referenceLine,
  });
}

class IpoGraphSection extends StatefulWidget {
  final IpoModel ipo;

  const IpoGraphSection({super.key, required this.ipo});

  @override
  State<IpoGraphSection> createState() => _IpoGraphSectionState();
}

class _IpoGraphSectionState extends State<IpoGraphSection> {
  int _selectedPeriod = 0;
  final List<String> _periods = [
    '1 Gün',
    '1 Hafta',
    '1 Ay',
    '3 Ay',
    '1 Yıl',
    'Hepsi'
  ];

  static const List<ChartPeriod> _chartPeriods = [
    ChartPeriod.day,
    ChartPeriod.week,
    ChartPeriod.month,
    ChartPeriod.threeMonths,
    ChartPeriod.year,
    ChartPeriod.all,
  ];

  final MockChartDataService _chartService = MockChartDataService();

  // Periyot bazlı cache — her periyot için veriyi bir kez üretir
  final Map<int, ChartData> _chartDataCache = {};

  ChartData _getChartData() {
    if (!_chartDataCache.containsKey(_selectedPeriod)) {
      _chartDataCache[_selectedPeriod] = _chartService.getChartData(
        symbol: widget.ipo.symbol,
        period: _chartPeriods[_selectedPeriod],
        basePrice: widget.ipo.price,
      );
    }
    return _chartDataCache[_selectedPeriod]!;
  }

  /// O(1) deterministik matematiksel formülle:
  /// - Günlük hariç tüm periyotlarda tam 6 fiyat skalası (5 eşit aralık)
  /// - Günlük periyotta ise 4 fiyat skalası ve referans çizgisi hesaplar
  _ChartScaleConfig _calculateScaleConfig(ChartData chartData, bool isDay) {
    if (isDay) {
      final double open = chartData.openPrice;
      final double minP = min(chartData.minPrice, open);
      final double maxP = max(chartData.maxPrice, open);
      final double range = maxP - minP;

      final double step = range > 0 ? range / 2.0 : (maxP > 0 ? maxP * 0.05 : 1.0);
      final int k = (minP / step).floor();
      final double minY = k * step;
      final double maxY = minY + 3.0 * step;

      return _ChartScaleConfig(
        minY: minY,
        maxY: maxY,
        step: step,
        referenceLine: open,
      );
    } else {
      final double minP = chartData.minPrice;
      final double maxP = chartData.maxPrice;
      final double range = maxP - minP;

      // 5 eşit aralık -> tam 6 seviye oluşturacak kesin O(1) formül
      final double step = range > 0 ? range / 3.8 : (maxP > 0 ? maxP * 0.05 : 1.0);
      final int k = (minP / step).floor();
      final double minY = k * step;
      final double maxY = minY + 5.0 * step;

      return _ChartScaleConfig(
        minY: minY,
        maxY: maxY,
        step: step,
      );
    }
  }

  /// Fiyat bareminin genişliğini metin uzunluğuna göre dinamik ölçer
  double _calculatePriceLabelWidth(double maxPrice) {
    final sampleText = maxPrice.toStringAsFixed(2).replaceAll('.', ',');
    final textPainter = TextPainter(
      text: TextSpan(
        text: sampleText,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    final spots = chartData.spots;
    final bool isGain = chartData.isGain;

    // Renk: açılış fiyatına göre yeşil veya kırmızı
    final Color chartColor =
        isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30);

    final bool isDay = _chartPeriods[_selectedPeriod] == ChartPeriod.day;
    final scaleConfig = _calculateScaleConfig(chartData, isDay);

    // Fiyat etiketinin genişliğini dinamik hesapla ve saat etiketlerindeki gibi 12px boşluk ekle
    final labelWidth = _calculatePriceLabelWidth(scaleConfig.maxY);
    final rightReservedSize = (labelWidth + 12.0).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Son Fiyat + TL Değişim + Yüzde Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${chartData.lastPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${isGain ? '+' : ''}${chartData.changeTL.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: chartColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            PercentageBadge(
              percent: chartData.changePercent,
              isGain: isGain,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dinamik Grafik (Yahoo Finance tarzı ferah ve 6 fiyat skalalı)
        Container(
          height: 205,
          padding: const EdgeInsets.only(top: 16, right: 0, bottom: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: scaleConfig.step,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Color(0xFF222224),
                    strokeWidth: 0.8,
                  );
                },
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  if (isDay && scaleConfig.referenceLine != null)
                    HorizontalLine(
                      y: scaleConfig.referenceLine!,
                      color: const Color(0xFF8E8E93),
                      strokeWidth: 1.0,
                      dashArray: [4, 4],
                    ),
                ],
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                // Yahoo Finance tarzı: altta saat/tarih etiketleri
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final label = _chartService.getBottomTitle(
                        _chartPeriods[_selectedPeriod],
                        index,
                        chartData.dataPoints,
                      );
                      if (label != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8E8E93),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Sağ tarafta dinamik fiyat seviyeleri (Sağa yaslı, üst çizgiyle hizalı)
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: rightReservedSize,
                    interval: scaleConfig.step,
                    getTitlesWidget: (value, meta) {
                      return Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          value.toStringAsFixed(2).replaceAll('.', ','),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: scaleConfig.minY,
              maxY: scaleConfig.maxY,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF222224),
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final priceStr =
                          '${spot.y.toStringAsFixed(2).replaceAll('.', ',')} TL';

                      if (chartData.dataPoints.isEmpty) {
                        return LineTooltipItem(
                          priceStr,
                          GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }

                      final index = spot.x
                          .toInt()
                          .clamp(0, chartData.dataPoints.length - 1);
                      final point = chartData.dataPoints[index];
                      final timeStr = _formatTooltipDate(
                        point.time,
                        _chartPeriods[_selectedPeriod],
                      );

                      return LineTooltipItem(
                        '$priceStr\n',
                        GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: timeStr,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8E8E93),
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: chartColor,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      // Son veri noktasında nokta göster
                      return spot.x == barData.spots.last.x;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: chartColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        chartColor.withValues(alpha: 0.2),
                        chartColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          ),
        ),
        const SizedBox(height: 16),
        // Zaman aralığı butonları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _periods.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = _selectedPeriod == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF333333)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Saat / Gecikme uyarısı & Yahoo Finance ikonu
        GestureDetector(
          onTap: _launchYahooFinance,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '15:34  (15 dakika gecikmeli)',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8E8E93),
                  fontSize: 12,
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: AppColors.surface,
              //     borderRadius: BorderRadius.circular(6),
              //     border: Border.all(
              //       color: AppColors.surface,
              //       width: 1,
              //     ),
              //   ),
              //   child: SvgPicture.asset(
              //     'assets/yahoo-finance-icon.svg',
              //     height: 16,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchYahooFinance() async {
    final symbol = widget.ipo.symbol;
    final url = Uri.parse('https://finance.yahoo.com/quote/$symbol.IS/');
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı açılamadı: $url'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı açılamadı: $url'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Seçilen periyoda uygun olarak tooltip için tarih ve saat metni üretir
  String _formatTooltipDate(DateTime dt, ChartPeriod period) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    switch (period) {
      case ChartPeriod.day:
        return '$day $month $year, $hour:$minute';
      case ChartPeriod.week:
        const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        final dayName = days[dt.weekday - 1];
        return '$day $month $dayName, $hour:$minute';
      case ChartPeriod.month:
      case ChartPeriod.threeMonths:
      case ChartPeriod.year:
      case ChartPeriod.all:
        return '$day $month $year';
    }
  }
}


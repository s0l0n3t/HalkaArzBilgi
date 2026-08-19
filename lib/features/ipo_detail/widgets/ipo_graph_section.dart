import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';
import 'package:halkaarzbilgi/features/ipo_detail/models/chart_data_model.dart';
import 'package:halkaarzbilgi/features/ipo_detail/services/chart_data_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    final spots = chartData.spots;
    final bool isGain = chartData.isGain;

    // Renk: açılış fiyatına göre yeşil veya kırmızı
    final Color chartColor =
        isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30);

    // Y ekseni dinamik aralık (padding ile)
    final double priceRange = chartData.maxPrice - chartData.minPrice;
    final double yPadding = priceRange * 0.15;
    final double minY = chartData.minPrice - yPadding;
    final double maxY = chartData.maxPrice + yPadding;

    // Sağ eksen için fiyat seviyeleri hesapla (3 seviye)
    final double yStep = priceRange / 3;
    final double level1 = chartData.minPrice + yStep * 0.5;
    final double level2 = chartData.minPrice + yStep * 1.5;
    final double level3 = chartData.minPrice + yStep * 2.5;

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
        // Dinamik Grafik
        Container(
          height: 180,
          padding: const EdgeInsets.only(top: 16, right: 8),
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
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  // Açılış fiyatı referans çizgisi (kesikli)
                  final diff = (value - chartData.openPrice).abs();
                  if (diff < yStep * 0.05) {
                    return const FlLine(
                      color: Color(0xFF555555),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  }
                  return const FlLine(
                    color: Colors.transparent,
                    strokeWidth: 0,
                  );
                },
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
                    reservedSize: 22,
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
                              color: const Color(0xFF666666),
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Sağ tarafta dinamik fiyat seviyeleri
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      // 3 dinamik fiyat seviyesi göster
                      final diff1 = (value - level1).abs();
                      final diff2 = (value - level2).abs();
                      final diff3 = (value - level3).abs();
                      final threshold = yStep * 0.08;

                      String? label;
                      if (diff1 < threshold) {
                        label = level1.toStringAsFixed(1);
                      } else if (diff2 < threshold) {
                        label = level2.toStringAsFixed(1);
                      } else if (diff3 < threshold) {
                        label = level3.toStringAsFixed(1);
                      }

                      if (label != null) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF666666),
                              fontSize: 11,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
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


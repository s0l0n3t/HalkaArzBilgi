import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';

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

  // Farklı zaman periyotları için mock veri noktaları
  final Map<int, List<FlSpot>> _periodData = {
    0: const [
      FlSpot(0, 110),
      FlSpot(1, 140),
      FlSpot(2, 90),
      FlSpot(3, 105),
      FlSpot(4, 80),
      FlSpot(5, 120),
      FlSpot(6, 150),
      FlSpot(7, 130),
      FlSpot(8, 138),
    ],
    1: const [
      FlSpot(0, 85),
      FlSpot(1, 95),
      FlSpot(2, 120),
      FlSpot(3, 110),
      FlSpot(4, 140),
      FlSpot(5, 135),
      FlSpot(6, 148),
    ],
    2: const [
      FlSpot(0, 70),
      FlSpot(1, 88),
      FlSpot(2, 102),
      FlSpot(3, 95),
      FlSpot(4, 125),
      FlSpot(5, 142),
      FlSpot(6, 138),
    ],
    3: const [
      FlSpot(0, 65),
      FlSpot(1, 80),
      FlSpot(2, 100),
      FlSpot(3, 130),
      FlSpot(4, 115),
      FlSpot(5, 145),
      FlSpot(6, 150),
    ],
    4: const [
      FlSpot(0, 50),
      FlSpot(1, 75),
      FlSpot(2, 90),
      FlSpot(3, 110),
      FlSpot(4, 130),
      FlSpot(5, 120),
      FlSpot(6, 152),
    ],
    5: const [
      FlSpot(0, 40),
      FlSpot(1, 60),
      FlSpot(2, 85),
      FlSpot(3, 115),
      FlSpot(4, 135),
      FlSpot(5, 145),
      FlSpot(6, 155),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final spots = _periodData[_selectedPeriod] ?? _periodData[0]!;

    // Dinamik fiyat hesaplaması: son nokta = son fiyat, ilk nokta = başlangıç fiyatı
    final double lastPrice = spots.last.y;
    final double firstPrice = spots.first.y;
    final double changeTL = lastPrice - firstPrice;
    final double changePercent = firstPrice != 0
        ? ((lastPrice - firstPrice) / firstPrice) * 100
        : 0.0;
    final bool isGain = changeTL >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Son Fiyat + TL Değişim + Yüzde Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${lastPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${isGain ? '+' : ''}${changeTL.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: isGain
                    ? const Color(0xFF00B856)
                    : const Color(0xFFFF3B30),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            PercentageBadge(
              percent: changePercent,
              isGain: isGain,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dinamik Yeşil Çizgi Grafik
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
                horizontalInterval: 30,
                getDrawingHorizontalLine: (value) {
                  // Ortadaki referans çizgisini kesikli çiz
                  if (value == 100) {
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
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                // Sağ tarafta fiyat seviyeleri: 70, 130, 150
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value == 150 || value == 130 || value == 70) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            '${value.toInt()}',
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
              minY: 40,
              maxY: 160,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF222224),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(2)} TL',
                        GoogleFonts.inter(
                          color: const Color(0xFF00B856),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
                  color: const Color(0xFF00B856),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      // Son veri noktasında yeşil nokta göster
                      return spot.x == barData.spots.last.x;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF00B856),
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
                        const Color(0xFF00B856).withValues(alpha: 0.2),
                        const Color(0xFF00B856).withValues(alpha: 0.0),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15:34  (15 dakika gecikmeli)',
              style: GoogleFonts.inter(
                color: const Color(0xFF8E8E93),
                fontSize: 12,
              ),
            ),
            SvgPicture.asset(
              'assets/yahoo-finance-icon.svg',
              height: 18,
            ),
          ],
        ),
      ],
    );
  }
}

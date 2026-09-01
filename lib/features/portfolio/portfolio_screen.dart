import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/features/portfolio/widgets/portfolio_skeleton.dart';

class PortfolioScreen extends ConsumerWidget {
  final bool isLoading;

  const PortfolioScreen({
    super.key,
    this.isLoading = false,
  });

  static const List<Color> _sliceColors = [
    Color(0xFF00E676), // Elektrik Zümrüt Yeşil
    Color(0xFF00B0FF), // Canlı Camgöbeği Mavi
    Color(0xFFFF3D00), // Canlı Mercan / Neon Kırmızı
    Color(0xFFFFD600), // Parlak Altın Sarı
    Color(0xFFA855F7), // Elektrik Menekşe / Mor
    Color(0xFFFF007F), // Neon Pembe / Magenta
    Color(0xFF2979FF), // Kraliyet Kobalt Mavisi
    Color(0xFFFF9100), // Parlak Turuncu
    Color(0xFF1DE9B6), // Canlı Nane / Turkuaz
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(portfolioStatsProvider);

    final totalValue = entries.fold<double>(0.0, (sum, e) => sum + e.totalValue);
    final totalGainLoss = entries.fold<double>(0.0, (sum, e) => sum + e.totalGainLoss);
    final totalCost = entries.fold<double>(0.0, (sum, e) => sum + e.totalCost);
    final gainLossPercent = totalCost > 0 ? (totalGainLoss / totalCost) * 100 : 0.0;
    final isGain = totalGainLoss >= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Portföyüm',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: isLoading
              ? const PortfolioSkeleton(key: ValueKey('portfolio_skeleton'))
              : entries.isEmpty
                  ? KeyedSubtree(
                      key: const ValueKey('portfolio_empty_state'),
                      child: _buildEmptyState(),
                    )
                  : SingleChildScrollView(
                      key: const ValueKey('portfolio_content'),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── 1. Donut Pasta Grafiği Kartı ──────────────────────
                          _buildDonutChartCard(
                            entries: entries,
                            totalValue: totalValue,
                            totalGainLoss: totalGainLoss,
                            gainLossPercent: gainLossPercent,
                            isGain: isGain,
                          ),
                          const SizedBox(height: 16),

                          // ── 2. Hisse Tablo Listesi ───────────────────────────
                          _buildPortfolioTable(entries, totalValue),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildDonutChartCard({
    required List<UserPortfolioStats> entries,
    required double totalValue,
    required double totalGainLoss,
    required double gainLossPercent,
    required bool isGain,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Her ekrana duyarlı (responsive) dinamik ölçülendirme
          final isSmallScreen = constraints.maxWidth < 320;
          final chartHeight = isSmallScreen ? 210.0 : 240.0;
          final centerSpaceRadius = isSmallScreen ? 68.0 : 78.0;
          final mainRingRadius = isSmallScreen ? 20.0 : 24.0;
          final innerGlowRadius = isSmallScreen ? 6.0 : 8.0;
          final innerCenterSpaceRadius = centerSpaceRadius - innerGlowRadius;
          final centerContentWidth = (centerSpaceRadius * 2) - 16;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: chartHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Katman: İçteki açık/saydam derinlik halkası
                    PieChart(
                      PieChartData(
                        sectionsSpace: entries.length > 1 ? 3.5 : 0,
                        centerSpaceRadius: innerCenterSpaceRadius,
                        startDegreeOffset: -90,
                        sections: entries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final color = _sliceColors[index % _sliceColors.length];
                          final value = item.totalValue > 0 ? item.totalValue : 1.0;

                          return PieChartSectionData(
                            color: color.withValues(alpha: 0.25),
                            value: value,
                            title: '',
                            radius: innerGlowRadius,
                          );
                        }).toList(),
                      ),
                    ),
                    // 2. Katman: Dıştaki ana canlı renkli halka
                    PieChart(
                      PieChartData(
                        sectionsSpace: entries.length > 1 ? 3.5 : 0,
                        centerSpaceRadius: centerSpaceRadius,
                        startDegreeOffset: -90,
                        sections: entries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final color = _sliceColors[index % _sliceColors.length];
                          final value = item.totalValue > 0 ? item.totalValue : 1.0;

                          return PieChartSectionData(
                            color: color,
                            value: value,
                            title: '',
                            radius: mainRingRadius,
                          );
                        }).toList(),
                      ),
                    ),
                    // Ferah ve Taşma Korumalı Merkez Alanı
                    SizedBox(
                      width: centerContentWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Toplam Değer',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${totalValue.toStringAsFixed(2).replaceAll('.', ',')} TL',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGain ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                                color: isGain ? AppColors.primaryGreen : AppColors.lossRed,
                                size: 18,
                              ),
                              Text(
                                '${isGain ? '%' : '-%'}${gainLossPercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                                style: GoogleFonts.inter(
                                  color: isGain ? AppColors.primaryGreen : AppColors.lossRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              // Legend: Her hissenin kare rengi, adı ve portföy yüzdesi (parantez içinde)
              Wrap(
                spacing: 16,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final color = _sliceColors[index % _sliceColors.length];
                  final percent = totalValue > 0 ? (item.totalValue / totalValue) * 100 : 0.0;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.entry.symbol,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(%${percent.toStringAsFixed(1).replaceAll('.', ',')})',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Düz (flat) tablo tasarımı: Arka plan renklendirmesi yok, 14px zarif ince sayılar
  Widget _buildPortfolioTable(List<UserPortfolioStats> entries, double totalValue) {
    return Column(
      children: [
        // Tablo Başlık Satırı
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hisse',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Maliyet',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Kazanç',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '% Kazanç',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: const Color(0xFF3F3F46), height: 1),

        // Tablo Satırları
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const _DashedDivider(),
          itemBuilder: (context, index) {
            final item = entries[index];
            final color = _sliceColors[index % _sliceColors.length];
            final isGain = item.isGain;
            final gainColor = isGain ? AppColors.primaryGreen : AppColors.lossRed;

            return InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                context.push('/ipo/${item.entry.symbol}');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                child: Row(
                  children: [
                    // 1. Sütun: Kare Renk Kutusu + Hisse Kodu (15.5px w500)
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.entry.symbol,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 2. Sütun: Toplam Maliyet (TL) - 14px w400
                    Expanded(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${item.totalCost.toStringAsFixed(2).replaceAll('.', ',')} TL',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    // 3. Sütun: Toplam Kazanç (TL) - 14px w500 Renkli
                    Expanded(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${item.totalGainLoss >= 0 ? '+' : ''}${item.totalGainLoss.toStringAsFixed(2).replaceAll('.', ',')} TL',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            color: gainColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // 4. Sütun: Yüzde Kazanç (%) - 14px w500 Renkli
                    Expanded(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${item.personalChangePercent >= 0 ? '%' : '-%'}${item.personalChangePercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            color: gainColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // En alttaki hissenin altındaki kesikli çizgi
        if (entries.isNotEmpty) const _DashedDivider(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.pie_chart_outline_rounded,
                color: AppColors.textSecondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Portföyünüz Boş',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Takip listenize veya portföyünüze henüz hisse eklemediniz.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Görseldeki gibi zarif ve belirgin kesikli (dashed) ayraç çizgisi
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      child: CustomPaint(
        painter: _DashedLinePainter(),
        size: Size(double.infinity, 1),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F3F46)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      final endX = (startX + 4.0).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += 4.0 + 3.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

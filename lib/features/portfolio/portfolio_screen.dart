import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_item.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  static const List<Color> _sliceColors = [
    Color(0xFF00B856), // Green
    Color(0xFF32ADE6), // Blue
    Color(0xFFFF9F0A), // Orange
    Color(0xFFAF52DE), // Purple
    Color(0xFFFF453A), // Red
    Color(0xFF5E5CE6), // Indigo
    Color(0xFFFFD60A), // Yellow
    Color(0xFF64D2FF), // Cyan
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
        child: entries.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
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
                    const SizedBox(height: 24),

                    // ── 2. Hisse Listesi Başlığı ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hisselerim',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${entries.length} hisse',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── 3. Hisse Kartları Listesi ────────────────────────
                    ...List.generate(entries.length, (index) {
                      final stats = entries[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < entries.length - 1 ? 12.0 : 0.0,
                        ),
                        child: WatchlistItem(stats: stats),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
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
      child: Column(
        children: [
          // Donut Chart with Center Text
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 65,
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
                        radius: 20,
                      );
                    }).toList(),
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Toplam Değer',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalValue.toStringAsFixed(2).replaceAll('.', ',')} TL',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGain ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: isGain ? AppColors.primaryGreen : AppColors.lossRed,
                          size: 16,
                        ),
                        Text(
                          '${isGain ? '+' : ''}%${gainLossPercent.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: GoogleFonts.inter(
                            color: isGain ? AppColors.primaryGreen : AppColors.lossRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Legend / Distribution Breakdown
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
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.entry.symbol,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '%${percent.toStringAsFixed(1).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
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

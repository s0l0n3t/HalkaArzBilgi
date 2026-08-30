import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';

/// "Hesabım" card displayed on the IPO detail page for logged-in users
/// who have the stock in their watchlist/portfolio.
///
/// Shows: info icon, "Hesabım" title, "Satın alınan hisse", lot count,
/// total cost, and gain/loss amount in #23A983 / #FF3B30 color.
class IpoAccountSection extends ConsumerWidget {
  final String symbol;

  const IpoAccountSection({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioStats = ref.watch(portfolioStatsProvider);
    final statsIndex = portfolioStats.indexWhere((s) => s.entry.symbol == symbol);

    // If not in portfolio, show nothing
    if (statsIndex == -1) {
      return const SizedBox.shrink();
    }

    final stats = portfolioStats[statsIndex];
    final isGain = stats.isGain;
    final changeColor =
        isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30);
    final changePrefix = isGain ? '+' : '-';
    final formattedGainLoss =
        '$changePrefix${stats.totalGainLoss.abs().toStringAsFixed(2).replaceAll('.', ',')} TL (${isGain ? '%' : '-%'}${stats.personalChangePercent.abs().toStringAsFixed(2).replaceAll('.', ',')})';

    final formattedTotalCost = stats.totalCost
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Info SVG icon
          SvgPicture.asset(
            'assets/information_icon.svg',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),

          // Title, subtitle, lots + cost row
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Hesabım" title — Inter semi-bold
                Text(
                  'Hesabım',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B856),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                // 1. Satır: "Satın alınan hisse" ⟷ "4.500 TL" (Toplam Maliyet)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Satın alınan hisse',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E8E93),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formattedTotalCost,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: ' TL',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 2. Satır: "100 lot" ⟷ "+449,80 TL (%8,95)" (Lot Sayısı + Kar/Zarar ve Yüzde)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Lot number clean weight + lighter unit
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${stats.entry.lots}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: ' lot',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Kar / Zarar ve Yüzde birlikte
                    Text(
                      formattedGainLoss,
                      style: GoogleFonts.inter(
                        color: changeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

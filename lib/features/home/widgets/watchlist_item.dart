import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';
import 'package:halkaarzbilgi/core/widgets/price_change_text.dart';

/// WatchlistItem driven by UserPortfolioStats from the portfolio stats provider.
class WatchlistItem extends StatelessWidget {
  final UserPortfolioStats stats;

  const WatchlistItem({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.push('/ipo/${stats.entry.symbol}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF222224),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFF00B856), width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.close, color: Color(0xFF00B856), size: 24),
              ),
            ),
            const SizedBox(width: 12),

            // Symbol / Lots / Cost + Change
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hisse Kodu: 16pt SemiBold
                  Text(
                    stats.entry.symbol,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Lot Bilgisi: 12pt
                  Text(
                    '${stats.entry.lots} lot',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Maliyet ve Kar/Zarar: 14pt
                  Row(
                    children: [
                      Text(
                        '${stats.totalCost.toStringAsFixed(2).replaceAll('.', ',')} TL',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      PriceChangeText(
                        change: stats.totalGainLoss,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Current price + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stats.currentPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                PercentageBadge(
                  percent: stats.personalChangePercent,
                  isGain: stats.isGain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

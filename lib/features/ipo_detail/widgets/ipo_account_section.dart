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
    final portfolio = ref.watch(watchlistMarkProvider);
    final entry = portfolio[symbol];

    // If not in portfolio, show nothing
    if (entry == null) {
      return const SizedBox.shrink();
    }

    final isGain = entry.isGain;
    final changeColor =
        isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30);
    final changePrefix = isGain ? '+' : '';

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
          // Info SVG icon — outlined green circle
          SvgPicture.asset(
            'assets/information_alternatives.svg',
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
                // "Satın alınan hisse" subtitle — Inter regular
                Text(
                  'Satın alınan hisse',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                // Lot count + cost and gain/loss on the same row
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
                            text: '${entry.lots}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: ' lot',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8E8E93),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Total cost + gain/loss inline
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: entry.totalCost
                                    .toStringAsFixed(0)
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]}.',
                                    ),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: ' TL',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF8E8E93),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$changePrefix${entry.totalGainLoss.toStringAsFixed(2).replaceAll('.', ',')} TL',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

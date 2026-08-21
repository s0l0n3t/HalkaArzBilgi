import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';

class AccountCard extends ConsumerWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authProvider).userName;
    final stats = ref.watch(portfolioStatsProvider);

    final totalValue = stats.fold<double>(0.0, (sum, item) => sum + item.totalCost);
    final totalGainLoss = stats.fold<double>(0.0, (sum, item) => sum + item.totalGainLoss);
    final totalPercent = totalValue == 0 ? 0.0 : (totalGainLoss / totalValue) * 100;

    final isGain = totalGainLoss >= 0;

    final changeColor =
        isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30);
    final changePrefix = isGain ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              userName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SvgPicture.asset(
              'assets/icons/7.svg',
              width: 24,
              height: 24,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${totalValue.toStringAsFixed(2).replaceAll('.', ',')} TL',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$changePrefix${totalGainLoss.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: changeColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: changeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isGain ? '%' : '-%'}${totalPercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

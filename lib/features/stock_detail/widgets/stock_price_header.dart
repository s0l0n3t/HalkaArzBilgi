import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';

class StockPriceHeader extends StatelessWidget {
  final StockModel stock;

  const StockPriceHeader({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${stock.currentPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${stock.change > 0 ? '+' : ''}${stock.change.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: stock.isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            PercentageBadge(
              percent: stock.changePercent,
              isGain: stock.isGain,
            ),
          ],
        ),
      ],
    );
  }
}

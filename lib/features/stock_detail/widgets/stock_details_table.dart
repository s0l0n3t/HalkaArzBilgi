import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';

class StockDetailsTable extends StatelessWidget {
  final StockModel stock;
  final UserPortfolioStats? portfolioStats;

  const StockDetailsTable({super.key, required this.stock, this.portfolioStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222224),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (portfolioStats != null) ...[
            _buildRow('Lot Sayısı', '${portfolioStats!.entry.lots}'),
            const Divider(color: Color(0xFF333333), height: 24),
            _buildRow('Maliyet', '${portfolioStats!.entry.costPrice.toStringAsFixed(2).replaceAll('.', ',')} TL'),
            const Divider(color: Color(0xFF333333), height: 24),
            _buildRow('Toplam Değer', '${portfolioStats!.totalValue.toStringAsFixed(2).replaceAll('.', ',')} TL'),
            const Divider(color: Color(0xFF333333), height: 24),
            _buildRow(
              'Kar/Zarar (Kişisel)',
              '${portfolioStats!.personalChange > 0 ? '+' : ''}${(portfolioStats!.totalGainLoss).toStringAsFixed(2).replaceAll('.', ',')} TL',
              valueColor: portfolioStats!.isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30),
            ),
            const Divider(color: Color(0xFF333333), height: 24),
          ],
          _buildRow('Güncel Fiyat', '${stock.currentPrice.toStringAsFixed(2).replaceAll('.', ',')} TL'),
          const Divider(color: Color(0xFF333333), height: 24),
          _buildRow(
            'Günlük Değişim',
            '${stock.isGain ? '%' : '-%'}${stock.changePercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
            valueColor: stock.isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF888888),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

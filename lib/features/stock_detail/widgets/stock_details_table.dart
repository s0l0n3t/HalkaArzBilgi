import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';

class StockDetailsTable extends StatelessWidget {
  final StockModel stock;

  const StockDetailsTable({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final double totalValue = stock.lots * stock.currentPrice;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222224),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRow('Lot Sayısı', '${stock.lots}'),
          const Divider(color: Color(0xFF333333), height: 24),
          _buildRow('Maliyet', '${stock.costPrice.toStringAsFixed(2).replaceAll('.', ',')} TL'),
          const Divider(color: Color(0xFF333333), height: 24),
          _buildRow('Toplam Değer', '${totalValue.toStringAsFixed(2).replaceAll('.', ',')} TL'),
          const Divider(color: Color(0xFF333333), height: 24),
          _buildRow(
            'Kar/Zarar',
            '${stock.change > 0 ? '+' : ''}${stock.change.toStringAsFixed(2).replaceAll('.', ',')} TL',
            valueColor: stock.isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30),
          ),
          const Divider(color: Color(0xFF333333), height: 24),
          _buildRow('Halka Arz Tarihi', '-'),
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

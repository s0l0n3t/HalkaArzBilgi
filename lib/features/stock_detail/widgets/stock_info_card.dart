import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';

class StockInfoCard extends StatelessWidget {
  final StockModel stock;

  const StockInfoCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00B856)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.close, color: Color(0xFF00B856), size: 32),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.symbol,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stock.companyName,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

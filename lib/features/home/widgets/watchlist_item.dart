import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';
import 'package:halkaarzbilgi/core/widgets/price_change_text.dart';

class WatchlistItem extends StatelessWidget {
  final StockModel stock;

  const WatchlistItem({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/stock/${stock.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B856)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.close, color: Color(0xFF00B856)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${stock.lots} lot',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${stock.costPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      PriceChangeText(change: stock.change),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stock.currentPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                PercentageBadge(
                  percent: stock.changePercent,
                  isGain: stock.isGain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

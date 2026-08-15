import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_item.dart';

class WatchlistSection extends StatelessWidget {
  const WatchlistSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = StockModel.mockWatchlist;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portföy listem >',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(stocks.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < stocks.length - 1 ? 12.0 : 0.0,
            ),
            child: WatchlistItem(stock: stocks[index]),
          );
        }),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_item.dart';

class WatchlistSection extends StatelessWidget {
  const WatchlistSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        ...StockModel.mockWatchlist.map((stock) => WatchlistItem(stock: stock)),
      ],
    );
  }
}

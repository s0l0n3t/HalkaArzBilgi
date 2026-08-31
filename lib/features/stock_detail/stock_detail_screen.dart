import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';
import 'package:halkaarzbilgi/features/stock_detail/widgets/stock_info_card.dart';
import 'package:halkaarzbilgi/features/stock_detail/widgets/stock_price_header.dart';
import 'package:halkaarzbilgi/features/stock_detail/widgets/stock_details_table.dart';
import 'package:halkaarzbilgi/features/stock_detail/widgets/stock_detail_skeleton.dart';

class StockDetailScreen extends ConsumerWidget {
  final String id;
  final bool isLoading;

  const StockDetailScreen({
    super.key,
    required this.id,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find stock from mock data
    final stock = StockModel.mockWatchlist.firstWhere(
      (s) => s.id == id,
      orElse: () => StockModel.mockWatchlist.first,
    );

    final portfolioStats = ref.watch(portfolioStatsProvider);
    final statsIndex = portfolioStats.indexWhere((s) => s.entry.symbol == stock.symbol);
    final stats = statsIndex != -1 ? portfolioStats[statsIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          stock.symbol,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: isLoading
              ? const StockDetailSkeleton(key: ValueKey('stock_detail_skeleton'))
              : SingleChildScrollView(
                  key: const ValueKey('stock_detail_content'),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StockInfoCard(stock: stock),
                        const SizedBox(height: 32),
                        StockPriceHeader(stock: stock),
                        const SizedBox(height: 32),
                        StockDetailsTable(stock: stock, portfolioStats: stats),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

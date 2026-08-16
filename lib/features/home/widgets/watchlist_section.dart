import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_item.dart';

class WatchlistSection extends ConsumerWidget {
  const WatchlistSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(watchlistMarkProvider);
    final entries = portfolio.values.toList();

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portföy listem >',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(entries.length, (index) {
          final entry = entries[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < entries.length - 1 ? 12.0 : 0.0,
            ),
            child: WatchlistItemFromPortfolio(entry: entry),
          );
        }),
      ],
    );
  }
}

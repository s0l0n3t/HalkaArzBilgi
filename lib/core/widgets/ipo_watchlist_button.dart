import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';

/// Shared watchlist (add/remove) button used in IpoDetailScreen AppBar
/// and AllIposListItem.
///
/// - Hidden for guest / unauthenticated users.
/// - Shows [add_watchlist.png] when inactive (not in watchlist).
/// - Shows [add_watchlist_active.png] when active (in watchlist).
/// - Toggles watchlist state via [watchlistMarkProvider].
class IpoWatchlistButton extends ConsumerWidget {
  final String symbol;
  final double size;

  const IpoWatchlistButton({
    super.key,
    required this.symbol,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    // Hidden for non-authenticated users
    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }

    final isActive = ref.watch(watchlistMarkProvider).contains(symbol);

    return GestureDetector(
      onTap: () {
        ref.read(watchlistMarkProvider.notifier).toggleWatchlist(symbol);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: isActive
              ? Image.asset(
                  'assets/add_watchlist_active.png',
                  key: const ValueKey('watchlist_active'),
                  height: size,
                  width: size,
                  fit: BoxFit.contain,
                )
              : Image.asset(
                  'assets/add_watchlist.png',
                  key: const ValueKey('watchlist_inactive'),
                  height: size,
                  width: size,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}

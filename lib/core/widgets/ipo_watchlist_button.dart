import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

/// Shared watchlist (add/remove) button used in IpoDetailScreen AppBar
/// and AllIposListItem.
///
/// - Hidden for guest / unauthenticated users.
/// - Shows [add_watchlist.png] when inactive (not in watchlist).
/// - Shows [add_watchlist_active.png] when active (in watchlist).
/// - On tap (inactive): opens a lot-input dialog, then adds to watchlist.
/// - On tap (active): opens a remove-confirmation dialog, then removes.
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

    final isActive = ref.watch(watchlistMarkProvider).containsKey(symbol);

    return GestureDetector(
      onTap: () {
        if (isActive) {
          _showRemoveConfirmDialog(context, ref);
        } else {
          _showLotInputDialog(context, ref);
        }
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

  /// Shows a dark-themed modal dialog asking the user to enter lot count.
  void _showLotInputDialog(BuildContext context, WidgetRef ref) {
    // Find the IPO data for this symbol
    final ipo = IpoModel.mockAllIpos.firstWhere(
      (i) => i.symbol == symbol,
      orElse: () => IpoModel.mockAllIpos.first,
    );

    final lotController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final lotText = lotController.text.trim();
            final lots = int.tryParse(lotText) ?? 0;
            
            final priceText = priceController.text.trim().replaceAll(',', '.');
            final enteredPrice = double.tryParse(priceText);
            final purchasePrice = enteredPrice ?? ipo.price;
            
            final totalCost = lots * purchasePrice;

            return Dialog(
              backgroundColor: const Color(0xFF1A1A1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Takip Listesine Ekle',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ipo.symbol} — ${ipo.companyName}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lot input field
                    Text(
                      'Satın alınan lot miktarı',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lotController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Örn: 50',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF48484A),
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF111111),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2C2C2E), width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2C2C2E), width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B856), width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price input field
                    Text(
                      'Satın alınan fiyat (İsteğe bağlı)',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Halka arz fiyatı: ${ipo.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF48484A),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF111111),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2C2C2E), width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2C2C2E), width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B856), width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cost preview
                    if (lots > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border.fromBorderSide(
                            BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam maliyet',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8E8E93),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${totalCost.toStringAsFixed(2).replaceAll('.', ',')} TL',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else
                      const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Color(0xFF2C2C2E), width: 0.5),
                              ),
                            ),
                            child: Text(
                              'İptal',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8E8E93),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: lots > 0
                                ? () {
                                    ref
                                        .read(
                                            watchlistMarkProvider.notifier)
                                        .addStock(
                                          symbol: ipo.symbol,
                                          companyName: ipo.companyName,
                                          lots: lots,
                                          ipoPrice: purchasePrice,
                                        );
                                    Navigator.of(dialogContext).pop();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B856),
                              disabledBackgroundColor:
                                  const Color(0xFF00B856).withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Onayla',
                              style: GoogleFonts.inter(
                                color: lots > 0
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a dark-themed confirmation dialog to remove from watchlist.
  void _showRemoveConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF222224),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$symbol" takip listesinden çıkartılsın mı?',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bu işlem sonucunda hisse takip listenizden ve portföy hesabınızdan kaldırılacaktır.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E8E93),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Right-aligned action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF333336),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(watchlistMarkProvider.notifier)
                            .removeStock(symbol);
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Çıkart',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/widgets/ipo_alert_button.dart';
import 'package:halkaarzbilgi/core/widgets/ipo_watchlist_button.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_header_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_basic_info_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_tavan_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_graph_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_allocation_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_results_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_account_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_documents_section.dart';

class IpoDetailScreen extends ConsumerWidget {
  final String symbol;

  const IpoDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipo = IpoModel.findBySymbol(symbol);

    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ipo.symbol,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: (isLoggedIn && ipo.isTraded)
            ? [
                // Alert button — synced with notificationSettingsProvider
                IpoAlertButton(symbol: ipo.symbol, size: 24),
                const SizedBox(width: 4),
                // Watchlist (add/remove) button
                IpoWatchlistButton(symbol: ipo.symbol, size: 24),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Logo + Ad/Sembol)
              //Alert butonu efekti fixle
              IpoHeaderSection(ipo: ipo),
              const SizedBox(height: 16),

              // 1.5. Hesabım kartı (portföye eklenmiş hisseler için — sadece işlem görenler)
              if (isLoggedIn && ipo.isTraded) ...[
                IpoAccountSection(symbol: ipo.symbol),
                const SizedBox(height: 16),
              ],

              // 2. Bilgi Satırları (Kutusuz düz liste)
              //İçerik düzenlemesi yapılacak.
              IpoBasicInfoSection(ipo: ipo),
              const SizedBox(height: 24),

              // 3. Tavan Serisi (Animasyonlu gün daireleri) — sadece işlem görenler
              if (ipo.isTraded) ...[
                IpoTavanSection(
                  totalDays: ipo.tavanSeriDays ?? 3,
                  completedDays: ipo.tavanSeriCompleted ?? 2,
                ),
                const SizedBox(height: 24),
              ],

              // 4. Grafik & Zaman butonları & Yahoo Finance — sadece işlem görenler
              if (ipo.isTraded) ...[
                //Grafik için logo ve fiyat bilgilerini buraya ekle
                IpoGraphSection(ipo: ipo),
                const SizedBox(height: 28),
              ],

              // 5. Tahsisat Grupları
              if (ipo.allocationGroups != null &&
                  ipo.allocationGroups!.isNotEmpty) ...[
                IpoAllocationSection(groups: ipo.allocationGroups!),
                const SizedBox(height: 28),
              ],

              // 6. Halka Arz Sonuçları — sadece işlem görenler
              if (ipo.isTraded &&
                  ((ipo.distributionResults != null &&
                          ipo.distributionResults!.isNotEmpty) ||
                      (ipo.demandResults != null &&
                          ipo.demandResults!.isNotEmpty))) ...[
                IpoResultsSection(
                  distributionResults: ipo.distributionResults,
                  demandResults: ipo.demandResults,
                  perPersonLot: ipo.perPersonLot,
                ),
                const SizedBox(height: 28),
              ],

              // 7. Dökümanlar
              if (ipo.documents != null && ipo.documents!.isNotEmpty)
                IpoDocumentsSection(documents: ipo.documents!),
            ],
          ),
        ),
      ),
    );
  }
}

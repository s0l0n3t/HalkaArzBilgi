import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_header_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_basic_info_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_tavan_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_graph_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_allocation_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_results_section.dart';
import 'package:halkaarzbilgi/features/ipo_detail/widgets/ipo_documents_section.dart';

class IpoDetailScreen extends StatelessWidget {
  final String symbol;

  const IpoDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final ipo = IpoModel.mockAllIpos.firstWhere(
      (i) => i.symbol == symbol,
      orElse: () => IpoModel.mockAllIpos.first,
    );

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Logo + Ad/Sembol + Alert Butonu)
              IpoHeaderSection(ipo: ipo),
              const SizedBox(height: 20),

              // 2. Bilgi Satırları (Kutusuz düz liste)
              IpoBasicInfoSection(ipo: ipo),
              const SizedBox(height: 24),

              // 3. Tavan Serisi (Animasyonlu gün daireleri)
              IpoTavanSection(
                totalDays: ipo.tavanSeriDays ?? 3,
                completedDays: ipo.tavanSeriCompleted ?? 2,
              ),
              const SizedBox(height: 24),

              // 4. Grafik & Zaman butonları & Yahoo Finance
              const IpoGraphSection(),
              const SizedBox(height: 28),

              // 5. Tahsisat Grupları
              if (ipo.allocationGroups != null &&
                  ipo.allocationGroups!.isNotEmpty) ...[
                IpoAllocationSection(groups: ipo.allocationGroups!),
                const SizedBox(height: 28),
              ],

              // 6. Halka Arz Sonuçları
              if (ipo.ipoResults != null && ipo.ipoResults!.isNotEmpty) ...[
                IpoResultsSection(rows: ipo.ipoResults!),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/core/widgets/ipo_alert_button.dart';

class IpoHeaderSection extends ConsumerWidget {
  final IpoModel ipo;

  const IpoHeaderSection({super.key, required this.ipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Logo kutusu (yeşil çerçeve ve X ikonu / yeşil stil)
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00B856), width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Icon(Icons.close, color: Color(0xFF00B856), size: 28),
          ),
        ),
        const SizedBox(width: 14),
        // Şirket kodu & Adı
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ipo.symbol,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ipo.companyName,
                style: GoogleFonts.inter(
                  color: const Color(0xFF8E8E93),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Zil / Alert butonu (paylaşımlı, guest için gizli)
        IpoAlertButton(symbol: ipo.symbol),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';

class AllIposListItem extends StatelessWidget {
  final IpoModel ipo;

  const AllIposListItem({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to stock detail
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo box (green outline)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B856), width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.close, color: Color(0xFF00B856), size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Company & Date info (Responsive flex column)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hisse Kodu: 16pt SemiBold
                  Text(
                    ipo.symbol,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Şirket Adı: 12pt
                  Text(
                    ipo.companyName,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Halka Arz Tarihi: 14pt
                  Text(
                    ipo.ipoDate,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price & Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${ipo.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (ipo.changePercent != null) ...[
                  const SizedBox(height: 4),
                  PercentageBadge(
                    percent: ipo.changePercent!,
                    isGain: ipo.isGain,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

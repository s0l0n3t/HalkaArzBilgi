import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoListItem extends StatelessWidget {
  final IpoModel ipo;

  const IpoListItem({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/ipo/${ipo.symbol}');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
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
                    ipo.formattedIpoDates,
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
            Text(
              '${ipo.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

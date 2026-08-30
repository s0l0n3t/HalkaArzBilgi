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
                border: Border.all(color: const Color(0xFF00B856)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.close, color: Color(0xFF00B856)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ipo.symbol,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ipo.companyName,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    ipo.formattedIpoDates,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF888888),
                      fontSize: 12,
                    ),
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

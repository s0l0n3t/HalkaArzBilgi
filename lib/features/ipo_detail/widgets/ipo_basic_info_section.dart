import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoBasicInfoSection extends StatelessWidget {
  final IpoModel ipo;

  const IpoBasicInfoSection({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      _InfoRow(
        label: 'Halka arz fiyatı:',
        value: ipo.ipoPrice ?? '${ipo.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
      ),
      _InfoRow(
        label: 'Halka arz tarihleri:',
        value: ipo.formattedIpoDates,
      ),
      _InfoRow(
        label: 'Dağıtım yöntemi:',
        value: ipo.distributionMethod ?? 'Eşit dağıtım',
      ),
      _InfoRow(
        label: 'Pazar:',
        value: ipo.market ?? 'Yıldız Pazar',
      ),
      _InfoRow(
        label: 'Halka arz edilecek paylar:',
        value: ipo.halkaArzEdilecekPaylar ?? ipo.shares ?? ipo.sharesOffered ?? '-',
      ),
      _InfoRow(
        label: 'Halka açıklık oranı:',
        value: ipo.halkaAciklikOrani ?? (ipo.publicShareRatio != null ? '%${ipo.publicShareRatio!.toStringAsFixed(1).replaceAll('.', ',')}' : '-'),
      ),
      _InfoRow(
        label: 'Fiyat istikrarı:',
        value: ipo.fiyatIstikrari ?? 'Planlanmıyor',
      ),
      _InfoRow(
        label: 'Katılım endeksi:',
        value: ipo.katilimEndeksi ?? (ipo.participationIndex != null ? 'Evet' : 'Katılmıyor'),
      ),
      _InfoRow(
        label: 'Bist ilk işlem tarihi:',
        value: ipo.formattedFirstTradeDate,
      ),
    ];

    return Column(
      children: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    row.value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (index != rows.length - 1)
              const Divider(
                color: Color(0xFF333333),
                height: 1,
                thickness: 1,
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow({required this.label, required this.value});
}

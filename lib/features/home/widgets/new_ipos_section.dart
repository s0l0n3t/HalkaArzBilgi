import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/features/home/widgets/ipo_list_item.dart';

class NewIposSection extends StatelessWidget {
  const NewIposSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Tappable header
          },
          child: Text(
            'Yeni Halka Arzlar >',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF222224),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ...IpoModel.mockIpos.asMap().entries.map((entry) {
                final int index = entry.key;
                final IpoModel ipo = entry.value;
                return Column(
                  children: [
                    IpoListItem(ipo: ipo),
                    if (index != IpoModel.mockIpos.length - 1)
                      const Divider(color: Color(0xFF333333)),
                  ],
                );
              }),
              const SizedBox(height: 12),
              Text(
                'Yeni çıkan diğer halka arzlar için tıklayınız.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF888888),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/features/home/widgets/all_ipos_list_item.dart';

class AllIposSection extends StatelessWidget {
  const AllIposSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to all IPOs list
          },
          child: Text(
            'Halka Arzlar >',
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
              ...IpoModel.mockAllIpos.asMap().entries.map((entry) {
                final int index = entry.key;
                final IpoModel ipo = entry.value;
                return Column(
                  children: [
                    AllIposListItem(ipo: ipo),
                    if (index != IpoModel.mockAllIpos.length - 1)
                      const Divider(color: Color(0xFF333333)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoAllocationSection extends StatelessWidget {
  final List<AllocationGroup> groups;

  const IpoAllocationSection({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tahsisat Grupları',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
            children: groups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index != groups.length - 1 ? 16 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8E8E93),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '%${group.percent.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: group.percent / 100.0,
                        backgroundColor: const Color(0xFF333333),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B856)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

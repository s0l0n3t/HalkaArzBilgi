import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoDocumentsSection extends StatelessWidget {
  final List<IpoDocument> documents;

  const IpoDocumentsSection({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halka Arz Dökümanları',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF222224),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: const Color(0xFF333333),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Column(
              children: documents.asMap().entries.map((entry) {
                final index = entry.key;
                final doc = entry.value;
                return Column(
                  children: [
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Color(0xFFE74C3C),
                            size: 20,
                          ),
                        ),
                      ),
                      title: Text(
                        doc.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        doc.fileType,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E93),
                          fontSize: 12,
                        ),
                      ),
                      iconColor: const Color(0xFF8E8E93),
                      collapsedIconColor: const Color(0xFF8E8E93),
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.download_rounded,
                              color: Color(0xFF00B856),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'İndir',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF00B856),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (index != documents.length - 1)
                      const Divider(
                        color: Color(0xFF333333),
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

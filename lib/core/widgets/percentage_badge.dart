import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PercentageBadge extends StatelessWidget {
  final double percent;
  final bool isGain;

  const PercentageBadge({super.key, required this.percent, required this.isGain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isGain ? '%' : '-%'}${percent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

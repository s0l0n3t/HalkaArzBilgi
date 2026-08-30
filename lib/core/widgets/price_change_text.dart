import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PriceChangeText extends StatelessWidget {
  final double change;
  final double fontSize;

  const PriceChangeText({
    super.key,
    required this.change,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGain = change >= 0;
    return Text(
      '${isGain ? '+' : ''}${change.toStringAsFixed(2).replaceAll('.', ',')} TL',
      style: GoogleFonts.inter(
        color: isGain ? const Color(0xFF23A983) : const Color(0xFFFF3B30),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    );
  }
}

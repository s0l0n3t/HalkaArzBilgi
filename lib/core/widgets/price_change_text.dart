import 'package:flutter/material.dart';

class PriceChangeText extends StatelessWidget {
  final double change;

  const PriceChangeText({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final bool isGain = change >= 0;
    return Text(
      '${isGain ? '+' : ''}${change.toStringAsFixed(2).replaceAll('.', ',')} TL',
      style: TextStyle(
        color: isGain ? const Color(0xFF00B856) : const Color(0xFFFF3B30),
        fontSize: 12,
      ),
    );
  }
}

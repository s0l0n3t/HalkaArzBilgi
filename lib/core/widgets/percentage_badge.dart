import 'package:flutter/material.dart';

class PercentageBadge extends StatelessWidget {
  final double percent;
  final bool isGain;

  const PercentageBadge({super.key, required this.percent, required this.isGain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isGain ? const Color(0xFF00B856) : const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isGain ? '+' : ''}${percent.toStringAsFixed(2)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

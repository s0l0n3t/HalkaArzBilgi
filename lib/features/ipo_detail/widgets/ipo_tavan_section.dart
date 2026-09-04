import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/core/widgets/tavan_serisi_widget.dart';

/// Wrapper for the detail page — delegates to the shared [TavanSerisiWidget]
/// so both the watchlist cards and the detail screen render the identical
/// pixel-perfect tavan.png design.
class IpoTavanSection extends StatelessWidget {
  final int totalDays;
  final int completedDays;

  const IpoTavanSection({
    super.key,
    this.totalDays = 0,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    return TavanSerisiWidget(
      totalDays: totalDays,
      completedDays: completedDays,
    );
  }
}


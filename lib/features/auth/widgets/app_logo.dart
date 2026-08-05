import 'package:flutter/material.dart';

/// Renders the official HalkaArzBilgi logo asset (assets/logo.png).
/// This ensures consistent brand appearance across all devices and screen densities.
class AppLogo extends StatelessWidget {
  final double width;

  const AppLogo({super.key, this.width = 180.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}

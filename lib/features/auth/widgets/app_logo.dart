import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({super.key, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    // scale based on size relative to 48
    final double scale = size / 48.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // bottom-left tall
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 12 * scale,
              height: 32 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF00B856),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ),
          // middle short
          Positioned(
            left: 18 * scale,
            bottom: 8 * scale,
            child: Container(
              width: 12 * scale,
              height: 24 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF00B856),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ),
          // top-right tall
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12 * scale,
              height: 32 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF00B856),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

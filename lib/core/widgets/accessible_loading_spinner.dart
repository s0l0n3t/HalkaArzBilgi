import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';

/// Ekran okuyucular ve erişilebilirlik ağacı için role="status" karşılığı
/// canlı bölge (liveRegion) bildirimli ve marka renkli yükleme göstergesi.
class AccessibleLoadingSpinner extends StatelessWidget {
  final String label;
  final double size;
  final double strokeWidth;
  final Color color;
  final bool showLabelText;

  const AccessibleLoadingSpinner({
    super.key,
    this.label = 'Yükleniyor...',
    this.size = 28.0,
    this.strokeWidth = 2.5,
    this.color = AppColors.primaryGreen,
    this.showLabelText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              if (showLabelText) ...[
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

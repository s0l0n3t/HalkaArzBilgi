import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

enum SocialIconType { google, apple, mail }

class SocialLoginButton extends StatelessWidget {
  final String text;
  final SocialIconType iconType;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconType,
    required this.onTap,
  });

  Widget _buildIcon() {
    switch (iconType) {
      case SocialIconType.google:
        return SvgPicture.asset(
          'assets/google-icon.svg',
          width: 22,
          height: 22,
        );
      case SocialIconType.apple:
        return SvgPicture.asset(
          'assets/apple-icon.svg',
          width: 22,
          height: 22,
        );
      case SocialIconType.mail:
        return const Icon(Icons.mail_outline, color: Colors.white, size: 22);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case SocialIconType.apple:
        return const Icon(Icons.apple, color: Colors.white, size: 28);
      case SocialIconType.mail:
        return const Icon(Icons.mail_outline, color: Colors.white, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF333333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            _buildIcon(),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 24), // balance icon width
          ],
        ),
      ),
    );
  }
}

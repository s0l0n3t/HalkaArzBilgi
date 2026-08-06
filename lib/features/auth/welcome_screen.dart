import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/features/auth/widgets/app_logo.dart';
import 'package:halkaarzbilgi/features/auth/widgets/social_login_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Top area: Logo & Subtitle
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(width: 250),
                  const SizedBox(height: 24),
                  Text(
                    'Yeni halka arzları keşfedin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // Bottom section: Actions matching the reference design
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mail login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.push('/login');
                      },
                      child: Text(
                        'Mail ile giriş yap',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with "Veya"
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFF333333), thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Veya',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF777777),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFF333333), thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Apple Login button
                  SocialLoginButton(
                    text: 'Apple ile giriş yap',
                    iconType: SocialIconType.apple,
                    onTap: () {
                      // Apple Sign-in handler
                    },
                  ),

                  const SizedBox(height: 14),

                  // Google Login button
                  SocialLoginButton(
                    text: 'Google ile giriş yap',
                    iconType: SocialIconType.google,
                    onTap: () {
                      // Google Sign-in handler
                    },
                  ),

                  const SizedBox(height: 24),

                  // Skip login text link
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      ref.read(authProvider.notifier).setGuest();
                      context.go('/home');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Giriş yapmadan devam et',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E93),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

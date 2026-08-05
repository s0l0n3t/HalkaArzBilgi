import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/auth/widgets/app_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(flex: 1),
              // Center-top area
              Column(
                children: [
                  const AppLogo(size: 80),
                  const SizedBox(height: 24),
                  Text(
                    'HalkaArzBilgi',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Yeni halka arzları keşfedin',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF888888),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              // Bottom section
              Column(
                children: [
                  Text(
                    'Bildirim alabilmek için giriş yapın.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF333333)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        context.push('/register');
                      },
                      child: Text(
                        'Giriş Yap',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    child: Text(
                      'Giriş yapmadan devam et',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF888888),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/auth/widgets/app_logo.dart';
import 'package:halkaarzbilgi/features/auth/widgets/auth_text_field.dart';
import 'package:halkaarzbilgi/features/auth/widgets/social_login_button.dart';
import 'package:halkaarzbilgi/features/auth/widgets/kvkk_checkbox.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Header using logo.png
              const AppLogo(width: 180),
              const SizedBox(height: 32),
              
              // Text Fields
              const Row(
                children: [
                  Expanded(
                    child: AuthTextField(
                      label: 'Ad',
                      hint: 'Adınız',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AuthTextField(
                      label: 'Soyadı',
                      hint: 'Soyadınız',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AuthTextField(
                label: 'E-mail adresi',
                hint: 'E-mail adresiniz',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const AuthTextField(
                label: 'Parola',
                hint: 'Parolanız',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              const AuthTextField(
                label: 'Parola tekrarı',
                hint: 'Parolayı tekrarlayınız',
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              const KvkkCheckbox(),
              const SizedBox(height: 32),
              
              SocialLoginButton(
                text: 'Google ile giriş yap',
                iconType: SocialIconType.google,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              SocialLoginButton(
                text: 'Apple ile giriş yap',
                iconType: SocialIconType.apple,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              SocialLoginButton(
                text: 'Mail ile giriş yap',
                iconType: SocialIconType.mail,
                onTap: () {
                  context.push('/login');
                },
              ),
              
              const SizedBox(height: 32),
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
                    context.go('/home');
                  },
                  child: Text(
                    'Üye Ol',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

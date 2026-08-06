import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/auth/widgets/app_logo.dart';
import 'package:halkaarzbilgi/features/auth/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_emailController.text.trim().isNotEmpty) {
      setState(() => _isSent = true);
    }
  }

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
              const AppLogo(width: 180),
              const SizedBox(height: 40),

              // Başlık
              Text(
                'Parolanızı mı unuttunuz?',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Açıklama
              Text(
                'E-posta adresinizi girin, şifre sıfırlama\nbağlantısını göndereceğiz.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8E8E93),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              AuthTextField(
                label: 'E-mail adresi',
                hint: 'E-mail adresiniz',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSent
                        ? const Color(0xFF00B856)
                        : const Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSent ? null : _handleSend,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSent) ...[
                        const Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isSent ? 'Gönderildi' : 'Sıfırlama Bağlantısı Gönder',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Şifrenizi hatırladınız mı? ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E93),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'Giriş Yap',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00B856),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

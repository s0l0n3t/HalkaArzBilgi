import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/constants/legal_texts.dart';

class KvkkCheckbox extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const KvkkCheckbox({super.key, this.onChanged});

  @override
  State<KvkkCheckbox> createState() => _KvkkCheckboxState();
}

class _KvkkCheckboxState extends State<KvkkCheckbox> {
  bool _isChecked = false;
  late final TapGestureRecognizer _kvkkRecognizer;
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _kvkkRecognizer = TapGestureRecognizer()
      ..onTap = () {
        LegalTexts.showLegalBottomSheet(
          context,
          title: LegalTexts.kvkkTitle,
          content: LegalTexts.kvkkText,
        );
      };
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        LegalTexts.showLegalBottomSheet(
          context,
          title: LegalTexts.termsTitle,
          content: LegalTexts.termsText,
        );
      };
  }

  @override
  void dispose() {
    _kvkkRecognizer.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value ?? false;
              });
              widget.onChanged?.call(_isChecked);
            },
            activeColor: const Color(0xFF00B856),
            checkColor: Colors.white,
            side: const BorderSide(color: Color(0xFF333333)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: const Color(0xFF888888),
                fontSize: 12,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'KVKK',
                  recognizer: _kvkkRecognizer,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B856),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' ve '),
                TextSpan(
                  text: 'Kullanım Koşulları',
                  recognizer: _termsRecognizer,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B856),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' belgelerini okudum ve kabul ediyorum.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

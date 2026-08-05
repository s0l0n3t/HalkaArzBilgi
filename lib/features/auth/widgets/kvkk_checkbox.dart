import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KvkkCheckbox extends StatefulWidget {
  const KvkkCheckbox({super.key});

  @override
  State<KvkkCheckbox> createState() => _KvkkCheckboxState();
}

class _KvkkCheckboxState extends State<KvkkCheckbox> {
  bool _isChecked = false;

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
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B856),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' ve '),
                TextSpan(
                  text: 'Kullanım Koşulları',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B856),
                    fontWeight: FontWeight.w500,
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoHeaderSection extends StatefulWidget {
  final IpoModel ipo;

  const IpoHeaderSection({super.key, required this.ipo});

  @override
  State<IpoHeaderSection> createState() => _IpoHeaderSectionState();
}

class _IpoHeaderSectionState extends State<IpoHeaderSection> {
  bool _isAlarmAnimating = false;

  void _triggerAlarmAnimation() {
    setState(() {
      _isAlarmAnimating = true;
    });

    // 2.8 saniye sonra animasyonu sonlandır
    Future.delayed(const Duration(milliseconds: 2833), () {
      if (mounted) {
        setState(() {
          _isAlarmAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo kutusu (yeşil çerçeve ve X ikonu / yeşil stil)
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00B856), width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Icon(Icons.close, color: Color(0xFF00B856), size: 28),
          ),
        ),
        const SizedBox(width: 14),
        // Şirket kodu & Adı
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.ipo.symbol,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.ipo.companyName,
                style: GoogleFonts.inter(
                  color: const Color(0xFF8E8E93),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Zil / Alert butonu
        GestureDetector(
          onTap: _triggerAlarmAnimation,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: _isAlarmAnimating
                ? SvgPicture.asset(
                    'assets/alarm-animation.svg',
                    width: 28,
                    height: 28,
                  )
                : const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF848484),
                    size: 28,
                  ),
          ),
        ),
      ],
    );
  }
}

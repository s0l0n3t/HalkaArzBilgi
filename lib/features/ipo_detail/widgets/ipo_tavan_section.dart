import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IpoTavanSection extends StatefulWidget {
  final int totalDays;
  final int completedDays;

  const IpoTavanSection({
    super.key,
    required this.totalDays,
    required this.completedDays,
  });

  @override
  State<IpoTavanSection> createState() => _IpoTavanSectionState();
}

class _IpoTavanSectionState extends State<IpoTavanSection>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fillAnimations;
  late List<Animation<double>> _checkAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.totalDays,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _fillAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      );
    }).toList();

    _checkAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
        ),
      );
    }).toList();

    _startSequentialAnimation();
  }

  void _startSequentialAnimation() async {
    for (int i = 0; i < widget.completedDays; i++) {
      await Future.delayed(Duration(milliseconds: i * 250));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tavan serisi',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.completedDays} Gün',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(widget.totalDays, (index) {
            final dayNumber = index + 1;
            final isCompleted = index < widget.completedDays;

            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      final fillVal = isCompleted ? _fillAnimations[index].value : 0.0;
                      final checkVal = isCompleted ? _checkAnimations[index].value : 0.0;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Arka plan çemberi
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00B856),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Yeşil dolgu çemberi (Animasyonlu scale)
                          Transform.scale(
                            scale: fillVal,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00B856),
                              ),
                            ),
                          ),
                          // Tik işareti (Animasyonlu opacity & scale)
                          if (isCompleted)
                            Transform.scale(
                              scale: checkVal,
                              child: Opacity(
                                opacity: checkVal.clamp(0.0, 1.0),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dayNumber',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          'Günler',
          style: GoogleFonts.inter(
            color: const Color(0xFF8E8E93),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFF333333), height: 1, thickness: 1),
      ],
    );
  }
}

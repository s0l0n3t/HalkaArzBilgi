import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';

/// Reusable Tavan Serisi widget — pixel-perfect replica of assets/tavan.png.
/// Uses Ellipse 8.svg (green circle with inner shadow) and Frame.svg (checkmark).
/// Used in both WatchlistItem cards and IpoTavanSection on the detail page.
class TavanSerisiWidget extends StatefulWidget {
  final int totalDays;
  final int completedDays;

  const TavanSerisiWidget({
    super.key,
    required this.totalDays,
    required this.completedDays,
  });

  @override
  State<TavanSerisiWidget> createState() => _TavanSerisiWidgetState();
}

class _TavanSerisiWidgetState extends State<TavanSerisiWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fillAnimations;
  late List<Animation<double>> _checkAnimations;

  int get _effectiveDays => widget.totalDays > 0 ? widget.totalDays : 0;
  int get _effectiveCompleted =>
      widget.completedDays.clamp(0, _effectiveDays);

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    _startSequentialAnimation();
  }

  void _buildAnimations() {
    _controllers = List.generate(
      _effectiveDays,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _fillAnimations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: c,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      );
    }).toList();

    _checkAnimations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: c,
          curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
        ),
      );
    }).toList();
  }

  Future<void> _startSequentialAnimation() async {
    for (int i = 0; i < _effectiveCompleted; i++) {
      await Future.delayed(Duration(milliseconds: i * 250));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnded = widget.totalDays == 0;
    final String dayLabel =
        isEnded ? '0 Gün' : '$_effectiveCompleted Gün';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title row ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tavan serisi',
              style: GoogleFonts.inter(
                color: const Color(0xFFE0E0E0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dayLabel,
              style: GoogleFonts.inter(
                color: const Color(0xFFE0E0E0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Day circles ────────────────────────────────────────────
        if (isEnded)
          Text(
            'Tavan serisi sona erdi',
            style: GoogleFonts.inter(
              color: const Color(0xFF8E8E93),
              fontSize: 12,
            ),
          )
        else
          Row(
            children: List.generate(_effectiveDays, (index) {
              final isCompleted = index < _effectiveCompleted;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < _effectiveDays - 1 ? 10.0 : 0.0,
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controllers[index],
                      builder: (context, child) {
                        final fillVal =
                            isCompleted ? _fillAnimations[index].value : 0.0;
                        final checkVal =
                            isCompleted ? _checkAnimations[index].value : 0.0;

                        return SizedBox(
                          width: 30,
                          height: 30,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background: empty circle (border only) for pending days
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1C1C1E),
                                  border: Border.all(
                                    color: isCompleted
                                        ? const Color(0xFF00B856)
                                        : const Color(0xFF3A3A3C),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Green circle (BoxDecoration gradient + shadow)
                              if (fillVal > 0.0)
                                Opacity(
                                  opacity: fillVal.clamp(0.0, 1.0),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF00D462),
                                          AppColors.primaryGreen,
                                          Color(0xFF009645),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFF3A3A3C),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Checkmark image (checkmark.png)
                              if (isCompleted)
                                Transform.scale(
                                  scale: checkVal,
                                  child: Opacity(
                                    opacity: checkVal.clamp(0.0, 1.0),
                                    child: Image.asset(
                                      'assets/checkmark.png',
                                      width: 17,
                                      height: 17,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

        // ── "Günler" label ─────────────────────────────────────────
        if (!isEnded) ...[
          const SizedBox(height: 12),
          Text(
            'Günler',
            style: GoogleFonts.inter(
              color: const Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        const SizedBox(height: 10),
        const Divider(color: Color(0xFF2C2C2E), height: 1, thickness: 1),
      ],
    );
  }
}

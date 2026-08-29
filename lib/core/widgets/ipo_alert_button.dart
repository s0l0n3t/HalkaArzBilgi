import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/notification_settings_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';

/// Shared alert (bell) button used in AllIposListItem and IpoDetailScreen.
///
/// - Hidden for guest / unauthenticated users.
/// - State is synced with [notificationSettingsProvider] → enabledStocks.
/// - On tap to activate: plays the 2.84s bell ringing animation,
///   then toggles the stock in [notificationSettingsProvider].
/// - If [tavanEnabled] is false when activating, shows a 15-second SnackBar
///   with a CupertinoSwitch to enable Tavan notifications inline.
/// - On tap to deactivate: reverts smoothly to the grey bell.
class IpoAlertButton extends ConsumerStatefulWidget {
  final String symbol;
  final double size;

  const IpoAlertButton({
    super.key,
    required this.symbol,
    this.size = 28,
  });

  @override
  ConsumerState<IpoAlertButton> createState() => _IpoAlertButtonState();
}

class _IpoAlertButtonState extends ConsumerState<IpoAlertButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _swingController;
  late Animation<double> _swingAnimation;

  // Exact transform-origin pivot from alarm-animation.svg: (10.667px / 22px, 13.333px / 27px)
  static const FractionalOffset _bellPivot = FractionalOffset(
    10.667 / 22.0,
    13.333 / 27.0,
  );

  @override
  void initState() {
    super.initState();
    // Duration: 1.2s for snappy, responsive feedback
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Exact keyframe percentages, radian angles and bezier splines from alarm-animation.svg:
    // 0% -> 0 rad
    // 30.42% -> 0.564 rad (cubic-bezier(0.5, 0, 0.5, 1))
    // 56.69% -> -0.639 rad (cubic-bezier(0.405, 0, 0.259, 1))
    // 100% -> 0 rad
    _swingAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.564)
            .chain(CurveTween(curve: const Cubic(0.5, 0.0, 0.5, 1.0))),
        weight: 3042,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.564, end: -0.639)
            .chain(CurveTween(curve: const Cubic(0.405, 0.0, 0.259, 1.0))),
        weight: 2627,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.639, end: 0.0)
            .chain(CurveTween(curve: const Cubic(0.5, 0.0, 0.5, 1.0))),
        weight: 2817,
      ),
    ]).animate(_swingController);
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  /// Shows a 15-second SnackBar warning when tavanEnabled is false,
  /// with an inline CupertinoSwitch to enable Tavan Bildirimleri.
  /// If the user taps anywhere on screen outside the SnackBar or if it times out
  /// without enabling tavanEnabled, the stock notification is automatically reverted back to inactive.
  Future<void> _showTavanWarningSnackBar(BuildContext ctx) async {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();

    bool isTappingSnackBar = false;

    void onPointerRoute(PointerEvent event) {
      if (event is PointerDownEvent) {
        if (!isTappingSnackBar) {
          // Tap is outside the SnackBar — hide it immediately
          ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
        }
        isTappingSnackBar = false;
      }
    }

    GestureBinding.instance.pointerRouter.addGlobalRoute(onPointerRoute);

    final controller = ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 15),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        content: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            isTappingSnackBar = true;
          },
          child: _TavanWarningSnackBarContent(
            ref: ref,
            onToggledOn: () {
              ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
            },
          ),
        ),
      ),
    );

    try {
      // Wait until the SnackBar closes (15s timeout, tap outside, or onToggledOn dismiss)
      await controller.closed;
    } finally {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(onPointerRoute);
    }

    // After closing, check if tavanEnabled was activated
    final currentSettings = ref.read(notificationSettingsProvider);
    if (!currentSettings.tavanEnabled) {
      // Tavan notifications were not enabled — revert the stock to inactive
      if (currentSettings.enabledStocks.contains(widget.symbol)) {
        ref.read(notificationSettingsProvider.notifier).toggleStock(widget.symbol);
      }
    }
  }

  Future<void> _onTap() async {
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final settings = ref.read(notificationSettingsProvider);
    final isCurrentlyActive = settings.enabledStocks.contains(widget.symbol);

    if (isCurrentlyActive) {
      // Deactivate — just toggle off
      notifier.toggleStock(widget.symbol);
    } else {
      // Activate — run the alarm-animation.svg swing, then switch to active green icon
      if (!_swingController.isAnimating) {
        await _swingController.forward(from: 0.0);
        if (mounted) {
          notifier.toggleStock(widget.symbol);

          // If tavanEnabled is false, show the 15-second warning SnackBar
          final updatedSettings = ref.read(notificationSettingsProvider);
          if (!updatedSettings.tavanEnabled && mounted) {
            _showTavanWarningSnackBar(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    // Hidden for non-authenticated users
    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }

    final settings = ref.watch(notificationSettingsProvider);
    final isActive = settings.enabledStocks.contains(widget.symbol);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: isActive
            ? SvgPicture.asset(
                'assets/alert_active.svg',
                height: widget.size,
                fit: BoxFit.contain,
              )
            : AnimatedBuilder(
                animation: _swingAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: _bellPivot,
                    transform: Matrix4.identity()
                      ..rotateZ(_swingAnimation.value),
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  'assets/alert_inactive.svg',
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}

/// The content widget for the Tavan warning SnackBar.
/// Rendered as a dark card with inline CupertinoSwitch.
class _TavanWarningSnackBarContent extends ConsumerWidget {
  final WidgetRef ref;
  final VoidCallback onToggledOn;

  const _TavanWarningSnackBarContent({
    required this.ref,
    required this.onToggledOn,
  });

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final settings = watchRef.watch(notificationSettingsProvider);
    final notifier = watchRef.read(notificationSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tavan bildirimleri kapalı olduğu için hisse bildirimi almayacaksınız. Aktif etmek ister misiniz ?',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: settings.tavanEnabled,
            activeTrackColor: const Color(0xFF00A34C),
            onChanged: (val) {
              notifier.toggleTavan();
              if (!settings.masterEnabled) {
                notifier.setMasterEnabled(true);
              }
              if (val) {
                onToggledOn();
              }
            },
          ),
        ],
      ),
    );
  }
}

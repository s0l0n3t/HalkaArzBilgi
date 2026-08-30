import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/notification_settings_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/notification_permission_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

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

    // Uyarı metnini snackbar açılmadan önce bir kez hesapla.
    // Böylece şalter açıldığında reactive rebuild sırasında metin değişmez.
    final settings = ref.read(notificationSettingsProvider);
    final String warningText;
    if (!settings.masterEnabled && !settings.tavanEnabled) {
      warningText = 'Bildirimler kapalı olduğu için hisse bildirimi almayacaksınız. Aktif etmek ister misiniz ?';
    } else if (!settings.masterEnabled) {
      warningText = 'Anlık bildirimler kapalı olduğu için hisse bildirimi almayacaksınız. Aktif etmek ister misiniz ?';
    } else {
      warningText = 'Tavan bildirimleri kapalı olduğu için hisse bildirimi almayacaksınız. Aktif etmek ister misiniz ?';
    }

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
            warningText: warningText,
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

    // After closing, check if both masterEnabled and tavanEnabled are activated
    final currentSettings = ref.read(notificationSettingsProvider);
    if (!currentSettings.masterEnabled || !currentSettings.tavanEnabled) {
      // Notifications were not enabled — revert the stock to inactive
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

          // If masterEnabled or tavanEnabled is false, show the 15-second warning SnackBar
          final updatedSettings = ref.read(notificationSettingsProvider);
          if ((!updatedSettings.masterEnabled || !updatedSettings.tavanEnabled) && mounted) {
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

/// The content widget for the Tavan & Master warning SnackBar.
/// Rendered as a dark card with inline CupertinoSwitch.
class _TavanWarningSnackBarContent extends ConsumerWidget {
  final WidgetRef ref;
  final String warningText;
  final VoidCallback onToggledOn;

  const _TavanWarningSnackBarContent({
    required this.ref,
    required this.warningText,
    required this.onToggledOn,
  });

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final settings = watchRef.watch(notificationSettingsProvider);
    final notifier = watchRef.read(notificationSettingsProvider.notifier);

    final isBothEnabled = settings.masterEnabled && settings.tavanEnabled;

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
              warningText,
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
            value: isBothEnabled,
            activeTrackColor: const Color(0xFF00A34C),
            onChanged: (val) async {
              if (val) {
                if (!settings.masterEnabled) {
                  // Cihaz bildirim iznini kontrol et
                  final status = await Permission.notification.status;

                  if (status.isGranted) {
                    await notifier.setMasterEnabled(true);
                    if (!settings.tavanEnabled) {
                      await notifier.setTavanEnabled(true);
                    }
                    onToggledOn();
                  } else if (status.isDenied) {
                    final result = await Permission.notification.request();
                    if (result.isGranted) {
                      await notifier.setMasterEnabled(true);
                      if (!settings.tavanEnabled) {
                        await notifier.setTavanEnabled(true);
                      }
                      onToggledOn();
                    } else {
                      // İzin verilmedi — snackbar'ı kapat ve ayarlara yönlendirme diyaloğunu aç
                      onToggledOn();
                      if (context.mounted) {
                        NotificationPermissionBottomSheet.show(context);
                      }
                    }
                  } else {
                    // Kalıcı olarak reddedilmiş/kısıtlanmış — ayarlara yönlendirme diyaloğu aç
                    onToggledOn();
                    if (context.mounted) {
                      NotificationPermissionBottomSheet.show(context);
                    }
                  }
                } else {
                  if (!settings.tavanEnabled) {
                    await notifier.setTavanEnabled(true);
                  }
                  onToggledOn();
                }
              } else {
                if (settings.tavanEnabled) {
                  await notifier.setTavanEnabled(false);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

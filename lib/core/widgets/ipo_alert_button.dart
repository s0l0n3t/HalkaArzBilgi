import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/watchlist_provider.dart';

/// Shared alert (bell) button used in AllIposListItem and IpoHeaderSection.
///
/// - Hidden for guest / unauthenticated users.
/// - Shows [alert_inactive.svg] (exact static vector from alarm-animation.svg) when inactive.
/// - On tap to activate: plays the exact 2.84s bell ringing animation from [alarm-animation.svg]
///   (swinging around pivot 10.667px, 13.333px with cubic-bezier splines),
///   then smoothly transitions to the green [alert_active.svg] icon.
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
    // Exact duration from alarm-animation.svg: 2.839749s
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2840),
    );

    // Exact keyframe percentages, radian angles and bezier splines from alarm-animation.svg:
    // 0% -> 0 rad
    // 30.42% -> 0.564 rad (cubic-bezier(0.5, 0, 0.5, 1))
    // 56.69% -> -0.639 rad (cubic-bezier(0.405, 0, 0.259, 1))
    // 84.86% -> 0 rad (cubic-bezier(0.5, 0, 0.5, 1))
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
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 1514,
      ),
    ]).animate(_swingController);
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final notifier = ref.read(watchlistProvider.notifier);
    final isCurrentlyActive =
        ref.read(watchlistProvider).contains(widget.symbol);

    if (isCurrentlyActive) {
      // Deactivate — just toggle off
      notifier.toggleAlert(widget.symbol);
    } else {
      // Activate — run the alarm-animation.svg swing, then switch to active green icon
      if (!_swingController.isAnimating) {
        await _swingController.forward(from: 0.0);
        if (mounted) {
          notifier.toggleAlert(widget.symbol);
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

    final isActive = ref.watch(watchlistProvider).contains(widget.symbol);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: isActive
              ? SvgPicture.asset(
                  'assets/alert_active.svg',
                  key: const ValueKey('active'),
                  height: widget.size,
                  fit: BoxFit.contain,
                )
              : AnimatedBuilder(
                  key: const ValueKey('inactive'),
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
      ),
    );
  }
}




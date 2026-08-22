import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';

class AppBottomNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  bool _isScrolling = false;

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final solidColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final frostedColor = isDark
        ? AppColors.surface.withValues(alpha: 0.75)
        : AppColors.lightSurface.withValues(alpha: 0.75);
    final borderCol = isDark ? AppColors.border : AppColors.lightBorder;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final isAtTop = notification.metrics.pixels <= 10;
          final isAtBottom = notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 10;
          final isBehind = !isAtTop && !isAtBottom;

          if (isBehind != _isScrolling) {
            setState(() {
              _isScrolling = isBehind;
            });
          }
        }
        return false;
      },
      child: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _isScrolling ? 12 : 0,
              sigmaY: _isScrolling ? 12 : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isScrolling ? frostedColor : solidColor,
                border: Border(
                  top: BorderSide(
                    color: _isScrolling
                        ? borderCol.withValues(alpha: 0.5)
                        : borderCol,
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (index) => _onTap(context, index),
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 0,
                items: [
                  _buildNavItem('assets/icons/Vector 5.svg', 0),
                  _buildNavItem('assets/icons/Vector1.svg', 1),
                  _buildNavItem('assets/icons/Vector.svg', 2),
                  _buildNavItem('assets/icons/Union.svg', 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String assetPath, int index) {
    final isActive = widget.navigationShell.currentIndex == index;
    final color = isActive ? AppColors.primaryGreen : AppColors.border;

    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        width: 24,
        height: 24,
      ),
      label: '',
    );
  }
}


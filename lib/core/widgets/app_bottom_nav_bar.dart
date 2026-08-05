import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderCol = isDark ? AppColors.border : AppColors.lightBorder;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(top: BorderSide(color: borderCol, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          backgroundColor: backgroundColor,
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
    );
  }

  BottomNavigationBarItem _buildNavItem(String assetPath, int index) {
    final isActive = navigationShell.currentIndex == index;
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

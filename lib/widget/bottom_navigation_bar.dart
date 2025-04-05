import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/carbon.dart';

import '../theme/adaptive_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    final Color activeColor = AdaptiveColors.primaryGreen;
    final Color inactiveColor = AdaptiveColors.secondaryTextColor(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AdaptiveColors.cardColor(context),
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Iconify(Mdi.home_outline, size: iconSize, color: inactiveColor),
          activeIcon: Iconify(Mdi.home, size: iconSize, color: activeColor),
          label: 'home',
          tooltip: 'home',
        ),
        BottomNavigationBarItem(
          icon:
              Iconify(Ic.outline_groups, size: iconSize, color: inactiveColor),
          activeIcon:
              Iconify(Ic.baseline_groups, size: iconSize, color: activeColor),
          label: 'team',
          tooltip: 'team',
        ),
        BottomNavigationBarItem(
          icon: Iconify(Ph.chart_bar, size: iconSize, color: inactiveColor),
          activeIcon:
              Iconify(Ph.chart_bar_fill, size: iconSize, color: activeColor),
          label: 'reports',
          tooltip: 'reports',
        ),
        BottomNavigationBarItem(
          icon: Iconify(Carbon.notification,
              size: iconSize, color: inactiveColor),
          activeIcon: Iconify(Carbon.notification_filled,
              size: iconSize, color: activeColor),
          label: 'notifications',
          tooltip: 'notifications',
        ),
        BottomNavigationBarItem(
          icon: Iconify(Mdi.cog_outline, size: iconSize, color: inactiveColor),
          activeIcon: Iconify(Mdi.cog, size: iconSize, color: activeColor),
          label: 'settings',
          tooltip: 'settings',
        ),
      ],
    );
  }
}

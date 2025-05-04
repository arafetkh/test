import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ic.dart';

import '../theme/adaptive_colors.dart';

class CustomSideNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSideNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final iconSize = screenHeight * 0.05;

    return Container(
      width: screenWidth * 0.06,
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        border: Border(
          right: BorderSide(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dashboard (Home)
          _buildNavItem(context, 0, Mdi.home_outline, Mdi.home, iconSize),

          // Departments (Renamed from Employees/Team)
          _buildNavItem(
              context, 1, Ic.outline_groups, Ic.baseline_groups, iconSize),

          // Attendance
          _buildNavItem(context, 2, Mdi.calendar_clock_outline,
              Mdi.calendar_clock, iconSize),

          // Notifications
          _buildNavItem(context, 3, Ic.outline_groups,
              Ic.baseline_groups, iconSize),

          // Holidays
          _buildNavItem(context, 4, Mdi.calendar_star_outline,
              Mdi.calendar_star, iconSize),
          // Settings
          _buildNavItem(context, 5, Mdi.cog_outline, Mdi.cog, iconSize),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String iconData,
      String activeIconData, double iconSize)
  {
    final isSelected = selectedIndex == index;
    final screenHeight = MediaQuery.of(context).size.height;
    final color = isSelected
        ? AdaptiveColors.primaryGreen
        : AdaptiveColors.secondaryTextColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  left: BorderSide(
                  color: AdaptiveColors.primaryGreen,
                  width: MediaQuery.of(context).size.width * 0.003,
                ))
              : null,
        ),
        child: IconButton(
          icon: Iconify(
            isSelected ? activeIconData : iconData,
            size: iconSize,
            color: color,
          ),
          onPressed: () => onItemTapped(index),
        ),
      ),
    );
  }
}

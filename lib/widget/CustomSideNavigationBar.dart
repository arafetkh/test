import 'package:flutter/material.dart';

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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: screenWidth * 0.003,
              spreadRadius: screenWidth * 0.001,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavItem(context, 0, Icons.home_outlined, iconSize),
            _buildNavItem(context, 1, Icons.calendar_today_outlined, iconSize),
            _buildNavItem(context, 2, Icons.add_box_outlined, iconSize),
            _buildNavItem(context, 3, Icons.message_outlined, iconSize),
            _buildNavItem(context, 4, Icons.settings, iconSize),
          ],
        ),
      );
    }

    Widget _buildNavItem(BuildContext context, int index, IconData icon, double iconSize) {
      final isSelected = selectedIndex == index;
      final screenHeight = MediaQuery.of(context).size.height;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border(left: BorderSide(
                    color: const Color(0xFF2E7D32),
                    width: MediaQuery.of(context).size.width * 0.003,
                  ))
                : null,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: iconSize,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
            ),
            onPressed: () => onItemTapped(index),
          ),
        ),
      );
    }
  }
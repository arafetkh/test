import 'package:flutter/material.dart';
import 'package:in_out/dashboard.dart';
import 'package:in_out/EmployeeTableScreen.dart';
import 'package:in_out/SettingsScreen.dart';

class NavigationService {
  static void navigateToScreen(BuildContext context, int index) {
    final Widget screen;

    switch (index) {
      case 0:
        screen = const DashboardScreen();
        break;
      case 1:
        screen = const EmployeeTableScreen();
        break;
      case 2:
      // Placeholder - replace with actual Add screen when available
        screen = const Scaffold(
          body: Center(child: Text('Add Screen - Coming Soon')),
        );
        break;
      case 3:
      // Placeholder - replace with actual Messages screen when available
        screen = const Scaffold(
          body: Center(child: Text('Messages Screen - Coming Soon')),
        );
        break;
      case 4:
        screen = const SettingsScreen();
        break;
      default:
        screen = const DashboardScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}
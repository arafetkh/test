import 'package:flutter/material.dart';
import 'package:in_out/dashboard.dart';
import 'package:in_out/EmployeeTableScreen.dart';
import 'package:in_out/AttendanceScreen.dart';
import 'package:in_out/NotificationsScreen.dart';
import 'package:in_out/SettingsScreen.dart';
import 'package:in_out/holidayscreen.dart';

class NavigationService {
  static void navigateToScreen(BuildContext context, int index) {
    final Widget screen;

    switch (index) {
      case 0:
      // Dashboard
        screen = const DashboardScreen();
        break;
      case 1:
      // Employees
        screen = const EmployeeTableScreen();
        break;
      case 2:
      // Attendance
        screen = const AttendanceScreen();
        break;
      case 3:
      // Notifications
        screen = const NotificationsScreen();
        break;
      case 4:
      // Settings
        screen = const SettingsScreen();
        break;
      case 5:
      // Holidays - New screen
        screen = const HolidaysScreen();
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
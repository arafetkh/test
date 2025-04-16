import 'package:flutter/material.dart';
import 'package:in_out/dashboard.dart';
import 'package:in_out/EmployeeTableScreen.dart';
import 'package:in_out/AttendanceScreen.dart';
import 'package:in_out/SettingsScreen.dart';
import '../DepartmentsScreen.dart';
import '../HolidayScreen.dart';

class NavigationService {
  static void navigateToScreen(BuildContext context, int index) {
    final Widget screen;

    switch (index) {
      // Dashboard
      case 0:
        screen = const DashboardScreen();
        break;
      // Employees
      case 1:
        screen = const EmployeeTableScreen();
        break;
      // Attendance
      case 2:
        screen = const AttendanceScreen();
        break;
      // Departments
      case 3:
        screen = const DepartmentsScreen();
        break;
      // Holidays
      case 4:
        screen = const HolidaysScreen();
        break;
      // Settings
      case 5:
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

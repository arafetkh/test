import 'package:flutter/material.dart';
import 'package:in_out/screens/dashboard.dart';
import 'package:in_out/screens/employees/employee_table_screen.dart';
import 'package:in_out/screens/attendance/attendance_screen.dart';
import '../auth/role_helper.dart';
import '../screens/holiday/holiday_screen.dart';
import '../screens/departments/departments_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/vacation/manager/vacation_management_screen.dart';
import '../screens/vacation/vacation_screen.dart';

class NavigationService {
  static Future<void> navigateToScreen(BuildContext context, int index) async {
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
    // Vacation
      case 2:
        final isManager = await RoleHelper.isUserManager();
        if (isManager) {
          screen = const VacationManagementScreen();
        } else {
          screen = const VacationScreen();
        }
        break;
      // Attendance
      case 3:
        screen = const AttendanceScreen();
        break;
      // Departments
      case 4:
        screen = const DepartmentsScreen();
        break;
      // Holidays
      case 5:
        screen = const HolidaysScreen();
        break;
      // Settings
      case 6:
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

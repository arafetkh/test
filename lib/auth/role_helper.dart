import 'auth_service.dart';

class RoleHelper {
  static const List<String> managerRoleKeywords = [
    'MANAGER',
    'ADMIN',
    'CHIEF',
    'DIRECTOR',
    'HEAD',
    'LEAD',
    'SUPERVISOR',
    'COORDINATOR',
  ];

  // Check if user has manager privileges
  static Future<bool> isUserManager() async {
    final userDetails = await AuthService.getUserDetails();
    final role = userDetails['role']?.toUpperCase() ?? '';

    // Check if role contains any manager keywords
    return managerRoleKeywords.any((keyword) => role.contains(keyword));
  }

  // Get user role for display
  static Future<String> getUserRole() async {
    final userDetails = await AuthService.getUserDetails();
    return userDetails['role'] ?? '';
  }

  // Check specific permissions
  static Future<bool> canApproveVacations() async {
    return isUserManager();
  }

  static Future<bool> canViewAllVacations() async {
    return isUserManager();
  }

  static Future<bool> canManageEmployees() async {
    final userDetails = await AuthService.getUserDetails();
    final role = userDetails['role']?.toUpperCase() ?? '';

    // HR and higher roles can manage employees
    return role.contains('HR') ||
        role.contains('ADMIN') ||
        role.contains('DIRECTOR') ||
        role.contains('CHIEF');
  }
}
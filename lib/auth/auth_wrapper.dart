// lib/auth/auth_wrapper.dart (update)
import 'package:flutter/material.dart';
import 'package:in_out/Login_screens/login_page.dart';
import 'package:in_out/dashboard.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      // Initialize user settings
      final userId = await AuthService.getCurrentUserId();
      if (userId != null) {
        final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
        await userSettingsProvider.setCurrentUser(userId);
      }
    }

    setState(() {
      _isAuthenticated = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginPage();
    }
  }
}
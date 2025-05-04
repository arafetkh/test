import 'package:flutter/material.dart';
import 'package:in_out/auth/auth_service.dart';
import 'package:in_out/screens/login/login_page.dart';
import 'package:in_out/screens/dashboard.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

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
    // Check if auto-login is possible
    final canAutoLogin = await AuthService.shouldAutoLogin();

    if (canAutoLogin) {
      try {
        // Attempt auto login
        final result = await AuthService.autoLogin(context);

        if (result["success"]) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        // Auto login failed
        print("Auto login failed: $e");
      }
    }

    // Check if user is logged in through normal means
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
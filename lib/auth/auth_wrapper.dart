// lib/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:in_out/Login_screens/login_page.dart';
import 'package:in_out/dashboard.dart';
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
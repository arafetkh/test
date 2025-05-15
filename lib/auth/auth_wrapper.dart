import 'package:flutter/material.dart';
import 'package:in_out/auth/auth_service.dart';
import 'package:in_out/screens/login/login_page.dart';
import 'package:in_out/screens/dashboard.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:in_out/provider/profile_provider.dart';
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
    // First check if user has a valid token already
    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      // Initialize profile provider
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.loadProfile();

      // Initialize user settings
      final userId = await AuthService.getCurrentUserId();
      if (userId != null) {
        final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
        await userSettingsProvider.setCurrentUser(userId);

        // If we have a profile, sync the language setting
        if (profileProvider.userProfile != null) {
          final locale = profileProvider.userProfile!.locale;
          if (userSettingsProvider.currentSettings.language != locale) {
            await userSettingsProvider.changeLanguage(locale);
          }
        }
      }

      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    // If not logged in, check if auto-login with saved session is possible
    final canAutoLogin = await AuthService.shouldAutoLogin();

    if (canAutoLogin) {
      try {
        // Try to restore the session
        final result = await AuthService.autoLogin(context);

        if (result["success"]) {
          // Initialize profile provider
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
          await profileProvider.loadProfile();

          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        } else {
          // Session restore failed - may need to go through normal login
          print("Session restore failed: ${result["message"]}");
        }
      } catch (e) {
        // Auto login failed
        print("Auto login failed: $e");
      }
    }

    // If we get here, user needs to log in normally
    setState(() {
      _isAuthenticated = false;
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
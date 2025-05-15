// lib/utils/app_initializer.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/global.dart';
import '../auth/auth_service.dart';
import 'package:provider/provider.dart';
import '../provider/user_settings_provider.dart';

/// Helper class to handle app initialization and hot reload recovery
class AppInitializer {
  static bool _initialized = false;

  /// Initialize the app state
  /// Call this in the main.dart file before running the app
  static Future<void> initialize() async {
    _initialized = true;

    // Pré-charger le token seulement si Remember Me est activé
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;

    if (rememberMe) {
      // Pré-charger le token pour qu'il soit disponible immédiatement
      await Global.getAuthToken();
    }
  }

  /// Restore session after hot reload
  /// Call this in the build method of your root widget
  static Future<void> handleHotReload(BuildContext context) async {
    // Skip if we've already done this
    if (_initialized) return;
    _initialized = true;

    // Vérifier d'abord si Remember Me était activé
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;

    if (!rememberMe) {
      // Si Remember Me n'est pas activé, ne rien faire après un hot reload
      return;
    }

    // Check if we have a token and restore session if needed
    final token = await Global.getAuthToken();
    if (token != null) {
      print("Restoring session after hot reload (Remember Me enabled)");

      // Get user ID
      final userId = await AuthService.getCurrentUserId();
      if (userId != null && context.mounted) {
        // Restore user settings
        final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
        await userSettingsProvider.setCurrentUser(userId);
      }
    }
  }
}
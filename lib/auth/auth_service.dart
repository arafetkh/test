import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/user_settings_provider.dart';
import 'global.dart';

class AuthService {
  // Token storage key
  static const String TOKEN_KEY = "auth_token";
  static const String USER_ID_KEY = "user_id";

  // Login method
  static Future<Map<String, dynamic>> login(String identifier, String password, BuildContext context) async {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication-management/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password
        }),
      );

      if (response.statusCode == 200) {
        // Extract token from Authorization header
        final authHeader = response.headers['authorization'];
        String? token;
        String userId = '';

        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          token = authHeader.substring(7); // Remove 'Bearer ' prefix

          // Extract user ID from response or token
          try {
            final responseData = jsonDecode(response.body);
            userId = responseData["id"]?.toString() ?? identifier;
          } catch (e) {
            // Fallback to using identifier as userId if parsing fails
            userId = identifier;
          }

          // Store token and userId
          await _saveToken(token);
          await _saveUserId(userId);
          Global.authToken = token;

          // Initialize user settings
          final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
          await userSettingsProvider.setCurrentUser(userId);

          return {"success": true, "token": token, "userId": userId};
        } else {
          return {"success": false, "message": "No token received"};
        }
      } else {
        // Parse error message if available
        String errorMessage = "Authentication failed";
        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData["message"] ?? errorMessage;
        } catch (e) {
          // If response body isn't valid JSON
        }

        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  // Logout method
  static Future<void> logout(BuildContext context) async {
    // Clear stored token and user ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);

    // Clear user settings
    final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
    userSettingsProvider.clearCurrentUser();

    // Clear global variables
    Global.authToken = null;
  }

  // Private methods for token storage
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Save user ID
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ID_KEY, userId);
  }
}
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  static const String REMEMBER_ME_KEY = "remember_me";
  static const String FIRST_NAME_KEY = "first_name";
  static const String LAST_NAME_KEY = "last_name";
  static const String USER_ROLE_KEY = "user_role";

  static const _secureStorage = FlutterSecureStorage();
  // Login method
  static Future<Map<String, dynamic>> login(
      String identifier,
      String password,
      BuildContext context,
      {bool rememberMe = false}
      ) async {
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
        final responseData = jsonDecode(response.body);
        final authHeader = response.headers['authorization'];

        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          final userId = responseData["id"]?.toString() ?? identifier;

          // Store additional user details
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(FIRST_NAME_KEY, responseData["firstName"] ?? "");
          await prefs.setString(LAST_NAME_KEY, responseData["lastName"] ?? "");
          await prefs.setString(USER_ROLE_KEY, responseData["role"] ?? "");

          // Existing save token and user ID logic
          await _saveToken(token);
          await _saveUserId(userId);
          Global.authToken = token;

          // Handle Remember Me functionality
          await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

          if (rememberMe) {
            await _secureStorage.write(key: 'login_username', value: identifier);
            await _secureStorage.write(key: 'login_password', value: password);
          } else {
            await _secureStorage.delete(key: 'login_username');
            await _secureStorage.delete(key: 'login_password');
          }

          // Rest of the existing login logic
          final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
          await userSettingsProvider.setCurrentUser(userId);

          return {
            "success": true,
            "token": token,
            "userId": userId,
            "firstName": responseData["firstName"],
            "lastName": responseData["lastName"],
            "role": responseData["role"]
          };
        } else {
          return {"success": false, "message": "No token received"};
        }
      } else {
        // Error handling remains the same
        String errorMessage = "Authentication failed";
        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData["message"] ?? errorMessage;
        } catch (e) {
          errorMessage = "Failed to parse error message";
        }

        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Method to get stored user details
  static Future<Map<String, String>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(FIRST_NAME_KEY) ?? '',
      'lastName': prefs.getString(LAST_NAME_KEY) ?? '',
      'role': prefs.getString(USER_ROLE_KEY) ?? '',
    };
  }

  // Check if user should be automatically logged in
  static Future<bool> shouldAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(REMEMBER_ME_KEY) ?? false;

    if (rememberMe) {
      // Check if credentials exist
      final username = await _secureStorage.read(key: 'login_username');
      final password = await _secureStorage.read(key: 'login_password');

      return username != null && password != null;
    }
    return false;
  }


  // Auto login method
  static Future<Map<String, dynamic>> autoLogin(BuildContext context) async {
    final username = await _secureStorage.read(key: 'login_username');
    final password = await _secureStorage.read(key: 'login_password');

    if (username != null && password != null) {
      return login(username, password, context, rememberMe: true);
    }

    return {"success": false, "message": "No stored credentials"};
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
    final prefs = await SharedPreferences.getInstance();

    // Clear user details
    await prefs.remove(FIRST_NAME_KEY);
    await prefs.remove(LAST_NAME_KEY);
    await prefs.remove(USER_ROLE_KEY);

    // Existing logout logic remains the same
    await prefs.remove(REMEMBER_ME_KEY);
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);

    await _secureStorage.delete(key: 'login_username');
    await _secureStorage.delete(key: 'login_password');

    final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
    userSettingsProvider.clearCurrentUser();

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

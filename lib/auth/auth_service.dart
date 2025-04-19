// lib/auth/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';

class AuthService {
  // Token storage key
  static const String TOKEN_KEY = "auth_token";

  // Login method
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
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

        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          token = authHeader.substring(7); // Remove 'Bearer ' prefix

          // Store token
          await _saveToken(token);
          Global.authToken = token;

          return {"success": true, "token": token};
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

  // Logout method
  static Future<void> logout() async {
    // Clear stored token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);

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
}
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

  // First authentication step - Request OTP
  static Future<Map<String, dynamic>> requestOTP(String identifier, String password) async {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": identifier
        },
        body: jsonEncode({"password": password}),
      );

      // Check for OTP generation response (412 Precondition Failed with OTP length)
      if (response.statusCode == 412) {
        try {
          final responseData = jsonDecode(response.body);
          final xRequestId = response.headers['x-request-id'];

          if (xRequestId != null && responseData.containsKey('length')) {
            return {
              "success": true,
              "otpRequired": true,
              "otpLength": responseData["length"],
              "requestId": xRequestId,
              "identifier": identifier,
              "password": password
            };
          } else {
            return {"success": false, "message": "Invalid OTP response format"};
          }
        } catch (e) {
          return {"success": false, "message": "Failed to parse OTP response: $e"};
        }
      } else if (response.statusCode == 200) {
        // Handle direct login (no OTP required) - should not happen with new system
        // but keep for backward compatibility
        return handleSuccessfulLogin(response, identifier, null);
      } else {
        // Handle error response
        String errorMessage = "Authentication failed";
        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;

            // Check for specific error messages
            if (responseData.containsKey("error") &&
                responseData["error"] == "invalid_credentials") {
              errorMessage = "Invalid username or password";
            }
          }
        } catch (e) {
          errorMessage = "Failed to parse error message";
        }

        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Second authentication step - Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(
      String identifier,
      String requestId,
      String otpCode,
      String password,
      BuildContext context,
      {bool rememberMe = false}) async {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": identifier,
          "X-Request-ID": requestId,
          "X-Policy-Data": otpCode
        },
        body: jsonEncode({"password": password}),
      );

      if (response.statusCode == 200) {
        return handleSuccessfulLogin(response, identifier, context, rememberMe: rememberMe);
      } else {
        // Handle error response
        String errorMessage = "OTP verification failed";
        String? errorCode;

        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);

            if (responseData.containsKey("error")) {
              errorCode = responseData["error"];

              if (errorCode == "invalid_credentials") {
                errorMessage = "Invalid username or password";
              }
            }

            // Get error message from response if available
            if (responseData.containsKey("message")) {
              errorMessage = responseData["message"];
            }
          }
        } catch (e) {
          errorMessage = "Failed to parse error message";
        }

        return {
          "success": false,
          "message": errorMessage,
          "errorCode": errorCode
        };
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Handle successful login response
  static Future<Map<String, dynamic>> handleSuccessfulLogin(
      http.Response response,
      String identifier,
      BuildContext? context,
      {bool rememberMe = false}) async
  {
    try {
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

        // Save user ID (toujours persistent pour identifier l'utilisateur)
        await _saveUserId(userId);

        // Save token with remember me flag
        await Global.setAuthToken(token, rememberMe: rememberMe);

        // No need to call _saveToken separately as Global.setAuthToken handles it
        // when rememberMe is true

        // Save credentials if Remember Me is checked
        if (rememberMe) {
          // Store username and session information
          await _secureStorage.write(key: 'login_username', value: identifier);
          await _secureStorage.write(key: 'session_token', value: token);

          // Set a session expiration time (e.g., 30 days from now)
          final expirationTime = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch.toString();
          await _secureStorage.write(key: 'session_expiry', value: expirationTime);
        } else {
          // Clean up any stored credentials and session info if not remembered
          await _secureStorage.delete(key: 'login_username');
          await _secureStorage.delete(key: 'session_token');
          await _secureStorage.delete(key: 'session_expiry');
        }

        // Update user settings if context is provided
        if (context != null) {
          final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
          await userSettingsProvider.setCurrentUser(userId);
        }

        return {
          "success": true,
          "token": token,
          "userId": userId,
          "firstName": responseData["firstName"],
          "lastName": responseData["lastName"],
          "role": responseData["role"],
          "sessionSaved": rememberMe
        };
      } else {
        return {"success": false, "message": "No token received"};
      }
    } catch (e) {
      return {"success": false, "message": "Error processing login response: $e"};
    }
  }

  // Legacy login method (forwards to new flow)
  static Future<Map<String, dynamic>> login(
      String identifier,
      String password,
      BuildContext context,
      {bool rememberMe = false}) async
  {
    return requestOTP(identifier, password);
  }

  // Method to get stored user details
  static Future<Map<String, String>> getUserDetails() async
  {
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
      // Check if session token exists
      final sessionToken = await _secureStorage.read(key: 'session_token');
      final expiryString = await _secureStorage.read(key: 'session_expiry');

      if (sessionToken != null && expiryString != null) {
        // Check if session is still valid
        final expiry = int.tryParse(expiryString);
        final now = DateTime.now().millisecondsSinceEpoch;

        if (expiry != null && now < expiry) {
          // Session is valid, auto-login possible
          return true;
        }
      }
    }
    return false;
  }

  // Auto login method with session token
  static Future<Map<String, dynamic>> autoLogin(BuildContext context) async {
    // Check if session is valid
    if (await shouldAutoLogin()) {
      try {
        final sessionToken = await _secureStorage.read(key: 'session_token');
        final username = await _secureStorage.read(key: 'login_username');

        if (sessionToken != null && username != null) {
          // Restore session token with remember me flag set to true
          await Global.setAuthToken(sessionToken, rememberMe: true);

          // Check if token is valid by making a user details request
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString(USER_ID_KEY);

          if (userId != null) {
            // Update user settings
            final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
            await userSettingsProvider.setCurrentUser(userId);

            return {
              "success": true,
              "message": "Session restored",
              "userId": userId
            };
          }
        }
      } catch (e) {
        print("Session restore error: $e");
      }
    }

    // If we get here, auto-login failed
    return {"success": false, "message": "Session expired or invalid"};
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await Global.getAuthToken();
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
    await _secureStorage.delete(key: 'session_token');
    await _secureStorage.delete(key: 'session_expiry');

    // Clear user settings
    final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
    userSettingsProvider.clearCurrentUser();

    // Reset global auth token
    await Global.clearAuthToken();
  }


  // // Private methods for token storage
  // static Future<void> _saveToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(TOKEN_KEY, token);
  // }
  //
  // static Future<String?> _getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(TOKEN_KEY);
  // }

  // Save user ID
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ID_KEY, userId);
  }

}
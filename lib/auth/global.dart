// lib/auth/global.dart - Secure version

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Global {
  // Backend URL
  static const String baseUrl = "http://148.113.42.38:8081";

  // Storage keys
  static const String TOKEN_KEY = "auth_token";
  static const String REMEMBER_ME_KEY = "remember_me";

  // In-memory token cache
  static String? _authToken;

  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Get auth token with enhanced security
  static Future<String?> getAuthToken() async {
    // Check memory cache first for performance
    if (_authToken != null) {
      return _authToken;
    }

    // Check if remember me is enabled
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(REMEMBER_ME_KEY) ?? false;

    if (rememberMe) {
      try {
        // Get token from secure storage
        _authToken = await _secureStorage.read(key: TOKEN_KEY);
      } catch (e) {
        print("Error reading token from secure storage: $e");
      }
    }

    return _authToken;
  }

  // Set auth token with enhanced security
  static Future<void> setAuthToken(String? token, {bool rememberMe = false}) async {
    _authToken = token;  // Always set in memory
    final prefs = await SharedPreferences.getInstance();

    // Save remember me setting in regular SharedPreferences (not sensitive)
    await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

    if (token != null && token.isNotEmpty) {
      if (rememberMe) {
        try {
          // Store token in secure storage
          await _secureStorage.write(key: TOKEN_KEY, value: token);
        } catch (e) {
          print("Error saving token to secure storage: $e");
        }
      } else {
        // Clear from storage but keep in memory
        try {
          await _secureStorage.delete(key: TOKEN_KEY);
        } catch (e) {
          print("Error removing token from secure storage: $e");
        }
      }
    } else {
      // Clear token if null
      try {
        await _secureStorage.delete(key: TOKEN_KEY);
      } catch (e) {
        print("Error clearing token from secure storage: $e");
      }
    }
  }

  // Check if token exists and is valid
  static Future<bool> isTokenValid() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Clear auth token
  static Future<void> clearAuthToken() async {
    _authToken = null;
    try {
      await _secureStorage.delete(key: TOKEN_KEY);
    } catch (e) {
      print("Error clearing token from secure storage: $e");
    }
  }

  // Get request headers with token
  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json"
    };

    final token = await getAuthToken();
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // Headers for OTP request
  static Map<String, String> otpRequestHeaders(String identifier) {
    return {
      "Content-Type": "application/json",
      "X-Public-Identifier": identifier,
    };
  }

  // Headers for OTP verification
  static Map<String, String> otpVerificationHeaders(
      String identifier,
      String requestId,
      String otpCode
      ) {
    return {
      "Content-Type": "application/json",
      "X-Public-Identifier": identifier,
      "X-Request-ID": requestId,
      "X-Policy-Data": otpCode,
    };
  }

  // Current request ID for OTP verification
  static String? currentRequestId;
} 
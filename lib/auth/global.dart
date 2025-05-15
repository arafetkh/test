// lib/auth/global.dart
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  // Your actual backend URL
  static const String baseUrl = "http://148.113.42.38:8081";

  // Token storage keys
  static const String TOKEN_KEY = "auth_token";
  static const String REMEMBER_ME_KEY = "remember_me";

  // Auth token storage in memory
  static String? _authToken;

  // Getter that loads token from storage only if remember me was enabled
  static Future<String?> getAuthToken() async {
    if (_authToken != null) {
      return _authToken;
    }

    // Check if remember me was enabled
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(REMEMBER_ME_KEY) ?? false;

    // Only load token from storage if remember me was enabled
    if (rememberMe) {
      _authToken = prefs.getString(TOKEN_KEY);
    }

    return _authToken;
  }

  // Setter that updates both memory and optionally storage
  static Future<void> setAuthToken(String? token, {bool rememberMe = false}) async {
    _authToken = token;

    final prefs = await SharedPreferences.getInstance();

    // Save remember me preference
    await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

    // Only persist token if remember me is enabled
    if (rememberMe) {
      if (token != null) {
        await prefs.setString(TOKEN_KEY, token);
      } else {
        await prefs.remove(TOKEN_KEY);
      }
    } else {
      // Clear stored token if remember me is disabled
      await prefs.remove(TOKEN_KEY);
    }
  }

  // Clear auth token both from memory and storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(REMEMBER_ME_KEY);
  }

  // Get headers with auto-loading token
  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json"
    };

    final token = await getAuthToken();
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // Headers for OTP request
  static Map<String, String> otpRequestHeaders(String identifier) {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Public-Identifier": identifier,
    };

    return headers;
  }

  // Headers for OTP verification
  static Map<String, String> otpVerificationHeaders(
      String identifier,
      String requestId,
      String otpCode
      ) {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Public-Identifier": identifier,
      "X-Request-ID": requestId,
      "X-Policy-Data": otpCode,
    };

    return headers;
  }

  // Current request ID for OTP verification
  static String? currentRequestId;
}
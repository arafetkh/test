// lib/auth/global.dart

class Global {
  // Your actual backend URL
  static const String baseUrl = "http://148.113.42.38:8081";

  // Auth token storage
  static String? authToken;

  // Default headers for API requests
  static Map<String, String> get headers {
    Map<String, String> headers = {
      "Content-Type": "application/json"
    };

    // Add authorization token if available
    if (authToken != null) {
      headers["Authorization"] = "Bearer $authToken";
    }

    return headers;
  }
}
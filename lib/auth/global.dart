class Global {
  // Your actual backend URL
  static const String baseUrl = "http://148.113.42.38:8081";

  // Auth token storage
  static String? authToken;

  // Current request ID for OTP verification
  static String? currentRequestId;

  // Default headers for API requests
  static Map<String, String> get headers {
    Map<String, String> headers = {
      "Content-Type": "application/json"
    };
    if (authToken != null) {
      headers["Authorization"] = "Bearer $authToken";
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
}
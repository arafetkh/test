import 'dart:convert';
import 'package:http/http.dart' as http;
import 'global.dart';

class LoginAuth {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse("${Global.baseUrl}/auth/login");

    try {
      final response = await http.post(
        url,
        headers: Global.headers,
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "token": responseData["token"]};
      } else {
        return {"success": false, "message": responseData["message"] ?? "Error"};
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server"};
    }
  }
}

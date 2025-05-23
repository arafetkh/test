// lib/services/vacation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/vacation_model.dart';
import '../models/vacation_balance_model.dart';

class VacationService {
  static final VacationService _instance = VacationService._internal();
  factory VacationService() => _instance;
  VacationService._internal();

  // Employee APIs

  // Get vacation balance for current user
  Future<Map<String, dynamic>> getMyBalance() async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/vocations/balance"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "balance": VacationBalance.fromJson(data),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load balance: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Get my vacation requests
  Future<Map<String, dynamic>> getMyRequests() async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/vocations"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final requests = data.map((item) => VacationRequest.fromJson(item)).toList();

        return {
          "success": true,
          "requests": requests,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load requests: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Create new vacation request
  Future<Map<String, dynamic>> createRequest(VacationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse("${Global.baseUrl}/secure/vocations"),
        headers: await Global.getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Vacation request created successfully",
        };
      } else {
        String errorMessage = "Failed to create request";
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}

        return {
          "success": false,
          "message": errorMessage,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Cancel vacation request
  Future<Map<String, dynamic>> cancelRequest(int requestId) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/vocations?id=$requestId"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Request cancelled successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to cancel request: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Manager APIs

  // Get employee vacation balance
  Future<Map<String, dynamic>> getEmployeeBalance(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/user-vocation/balance?userId=$userId"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "balance": VacationBalance.fromJson(data),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load employee balance: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Get all employee vacation requests (for managers)
  Future<Map<String, dynamic>> getEmployeeRequests() async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/user-vocation/list"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final requests = data.map((item) => VacationRequest.fromJson(item)).toList();

        return {
          "success": true,
          "requests": requests,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load employee requests: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Approve or reject vacation request
  Future<Map<String, dynamic>> manageRequest(int requestId, String status) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/user-vocation?id=$requestId"),
        headers: await Global.getHeaders(),
        body: jsonEncode({
          "id": requestId.toString(),
          "status": status,
        }),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Request $status successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update request: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/employee_model.dart';

class EmployeeService {
  // Get all employees with pagination
  static Future<Map<String, dynamic>> getEmployees({int page = 0, int size = 10}) async {
    final Uri url = Uri.parse(
        "${Global.baseUrl}/secure/users-management?page=$page&size=$size");

    try {
      final response = await http.get(
        url,
        headers: Global.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> content = responseData['content'] ?? [];
        final List<Employee> employees =
        content.map<Employee>((item) => Employee.fromJson(item)).toList();


        return {
          "success": true,
          "employees": employees,
          "totalElements": responseData['totalElements'] ?? 0,
          "totalPages": responseData['totalPages'] ?? 0,
          "currentPage": responseData['pageable']?['pageNumber'] ?? 0,
          "size": responseData['pageable']?['pageSize'] ?? size,
          "first": responseData['first'] ?? false,
          "last": responseData['last'] ?? false,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load employees: ${response.statusCode}",
          "employees": <Employee>[],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "employees": <Employee>[],
      };
    }
  }

  // Search employees with pagination
  static Future<Map<String, dynamic>> searchEmployees(String query, {int page = 0, int size = 10}) async {
    final Uri url = Uri.parse(
        "${Global.baseUrl}/secure/users-management/search?query=$query&page=$page&size=$size");

    try {
      final response = await http.get(
        url,
        headers: Global.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> content = responseData['content'] ?? [];

        final List<Employee> employees =
        content.map<Employee>((item) => Employee.fromJson(item)).toList();

        return {
          "success": true,
          "employees": employees,
          "totalElements": responseData['totalElements'] ?? 0,
          "totalPages": responseData['totalPages'] ?? 0,
          "currentPage": responseData['pageable']?['pageNumber'] ?? 0,
          "size": responseData['pageable']?['pageSize'] ?? size,
          "first": responseData['first'] ?? false,
          "last": responseData['last'] ?? false,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to search employees: ${response.statusCode}",
          "employees": <Employee>[],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "employees": <Employee>[],
      };
    }
  }

  // Create a new employee
  static Future<Map<String, dynamic>> createEmployee(Employee employee) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/users-management");

    try {
      // Create payload with updated fields
      final Map<String, dynamic> employeeData = {
        'email': employee.email,
        'personalEmail': employee.personalEmail,
        'phoneNumber': employee.phoneNumber,
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'password': employee.password,
        'gender': employee.gender,
        'maritalStatus': employee.maritalStatus, // Corrected field name
        'birthDate': employee.birthDate,
        'recruitmentDate': employee.recruitmentDate,
        'role': employee.role,
        'type': employee.type,
        'companyId': employee.companyId,
        'designation': employee.designation,
        'address': employee.address,
        'attributes': {},
        'active': true // Default to active
      };

      // If username is provided, include it (though backend should generate one)
      if (employee.username.isNotEmpty) {
        employeeData['username'] = employee.username;
      }

      print("Sending modified employee data: ${jsonEncode(employeeData)}");

      final response = await http.post(
        url,
        headers: Global.headers,
        body: jsonEncode(employeeData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final responseData = jsonDecode(response.body);
      print("Using auth token: ${Global.authToken ?? 'No token found'}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "employee": Employee.fromJson(responseData),
          "message": "Employee created successfully"
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Failed to create employee"
        };
      }
    } catch (e) {
      print("Error creating employee: $e");
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Get employee by ID
  static Future<Map<String, dynamic>> getEmployeeById(int employeeId) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/users-management/$employeeId");

    try {
      final response = await http.get(
        url,
        headers: Global.headers,
      );

      // Print for debugging
      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("Parsed response data: $responseData");

        try {
          // More safe approach - don't immediately create an Employee object
          return {
            "success": true,
            "employee": responseData,
            "rawData": responseData
          };
        } catch (e) {
          print("Error parsing employee data: $e");
          return {
            "success": false,
            "message": "Error parsing employee data: $e"
          };
        }
      } else {
        // Handle error responses with status codes
        try {
          final responseData = jsonDecode(response.body);
          return {
            "success": false,
            "message": responseData["message"] ?? "Failed to get employee details. Error code: ${response.statusCode}"
          };
        } catch (e) {
          return {
            "success": false,
            "message": "Failed to parse error response. Status code: ${response.statusCode}"
          };
        }
      }
    } catch (e) {
      // Handle network or parsing errors
      print("Network error: $e");
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  // Update an employee
  static Future<Map<String, dynamic>> updateEmployee(Employee employee) async {
    final Uri url =
    Uri.parse("${Global.baseUrl}/secure/users-management/${employee.id}");

    try {
      // Create payload with updated fields for update operation
      // Note: username is removed from update payload as per requirements
      final Map<String, dynamic> updateData = {
        'email': employee.email,
        'personalEmail': employee.personalEmail,
        'phoneNumber': employee.phoneNumber,
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'gender': employee.gender,
        'maritalStatus': employee.maritalStatus,
        'birthDate': employee.birthDate,
        'recruitmentDate': employee.recruitmentDate,
        'role': employee.role,
        'type': employee.type,
        'companyId': employee.companyId,
        'designation': employee.designation,
        'address': employee.address, // Added address field
        'active': employee.active
      };

      final response = await http.put(
        url,
        headers: Global.headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "employee": Employee.fromJson(jsonDecode(response.body)),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update employee: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Delete an employee
  static Future<Map<String, dynamic>> deleteEmployee(int id) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/users-management/$id");

    try {
      final response = await http.delete(
        url,
        headers: Global.headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          "success": true,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to delete employee: ${response.statusCode}",
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
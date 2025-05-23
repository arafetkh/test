import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:in_out/ai/recognition_result.dart';

class RemotePointageService {
  // Singleton instance
  static final RemotePointageService _instance = RemotePointageService._internal();
  factory RemotePointageService() => _instance;
  RemotePointageService._internal();

  // Base URL for the face recognition APIï
  final String baseUrl = 'http://localhost:3000';

  /// Collect face data for training
  /// [userId] - User ID
  /// [userName] - User name
  /// [imageBytes] - List of image byte arrays
  Future<String> collectFaceData(int userId, String userName, List<Uint8List> imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/collect/'));

      // Add user fields
      request.fields['user_id'] = userId.toString();
      request.fields['user_name'] = userName;

      // Add image files
      for (int i = 0; i < imageBytes.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes[i],
            filename: 'face_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResult = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonResult['message'];
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to collect face data');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Train the face recognition model
  Future<String> trainModel() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/train/'));
      final jsonResult = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonResult['message'];
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to train model');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Recognize a face from image data
  /// [imageBytes] - Image data as bytes
  Future<RecognitionResult> recognizeFace(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/recognize/'));

      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'face.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResult = json.decode(responseBody);

      if (response.statusCode == 200) {
        return RecognitionResult.fromJson(jsonResult);
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to recognize face');
      }
    } catch (e) {
      return RecognitionResult.error('Error: $e');
    }
  }

  /// Delete a user from the face recognition system
  /// [userId] - User ID to delete
  Future<String> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/?user_id=$userId'),
      );
      final jsonResult = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonResult['message'];
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to delete user');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Register a new user for face recognition
  /// [userId] - User ID
  /// [userName] - User name
  /// [imageBytes] - List of image byte arrays
  Future<String> registerUser(int userId, String userName, List<Uint8List> imageBytes) async {
    try {
      // Collect face data
      print('Collecting face data for user $userId: $userName with ${imageBytes.length} images');
      String collectResult = await collectFaceData(userId, userName, imageBytes);
      if (!collectResult.contains('success')) {
        return collectResult;
      }

      // Train the model with the new data
      print('Training model with new face data');
      String trainResult = await trainModel();
      return trainResult;
    } catch (e) {
      print('Error in registerUser: $e');
      return 'Error registering user: $e';
    }
  }

  /// Record attendance using face recognition
  /// [imageBytes] - Image data as bytes
  /// [isCheckIn] - Whether this is a check-in (true) or check-out (false)
  Future<Map<String, dynamic>> recordAttendance(Uint8List imageBytes, bool isCheckIn) async {
    try {
      // First, recognize the face
      RecognitionResult result = await recognizeFace(imageBytes);

      // If face is recognized
      if (result.recognized && result.userId != null) {
        // Here you would normally send a request to your backend API to record the attendance
        // For this demo, we'll just return a success response with the user details

        return {
          'success': true,
          'userId': result.userId,
          'userName': result.userName,
          'timestamp': DateTime.now().toIso8601String(),
          'type': isCheckIn ? 'check_in' : 'check_out',
          'message': '${isCheckIn ? 'Check-in' : 'Check-out'} successful for ${result.userName}',
        };
      } else {
        // Face not recognized
        return {
          'success': false,
          'message': result.message,
        };
      }
    } catch (e) {
      // Error processing request
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
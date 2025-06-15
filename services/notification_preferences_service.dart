// lib/services/notification_preferences_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/global.dart';

class NotificationPreferences {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool inAppNotifications;
  final Map<String, bool> categoryPreferences; // e.g., 'vacation', 'attendance', 'system'
  final String? pushToken;

  NotificationPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.inAppNotifications = true,
    this.categoryPreferences = const {},
    this.pushToken,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      inAppNotifications: json['inAppNotifications'] ?? true,
      categoryPreferences: Map<String, bool>.from(json['categoryPreferences'] ?? {}),
      pushToken: json['pushToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'inAppNotifications': inAppNotifications,
      'categoryPreferences': categoryPreferences,
      'pushToken': pushToken,
    };
  }

  NotificationPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? inAppNotifications,
    Map<String, bool>? categoryPreferences,
    String? pushToken,
  }) {
    return NotificationPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
      pushToken: pushToken ?? this.pushToken,
    );
  }
}

class NotificationPreferencesService {
  static final NotificationPreferencesService _instance =
  NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  static const String _prefsKey = 'notification_preferences';
  NotificationPreferences? _cachedPreferences;

  // Get notification preferences
  Future<NotificationPreferences> getPreferences() async {
    if (_cachedPreferences != null) {
      return _cachedPreferences!;
    }

    try {
      // Try to get from server first
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/notification/preferences"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _cachedPreferences = NotificationPreferences.fromJson(data);

        // Cache locally
        await _saveToLocal(_cachedPreferences!);
        return _cachedPreferences!;
      }
    } catch (e) {
      print('Error fetching preferences from server: $e');
    }

    // Fallback to local storage
    return await _getFromLocal();
  }

  // Update notification preferences
  Future<Map<String, dynamic>> updatePreferences(NotificationPreferences preferences) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/notification/preferences"),
        headers: await Global.getHeaders(),
        body: jsonEncode(preferences.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _cachedPreferences = preferences;
        await _saveToLocal(preferences);

        return {
          "success": true,
          "message": "Notification preferences updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update preferences: ${response.statusCode}",
        };
      }
    } catch (e) {
      print('Error updating preferences: $e');

      // Save locally even if server update fails
      _cachedPreferences = preferences;
      await _saveToLocal(preferences);

      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Update email notifications preference
  Future<Map<String, dynamic>> updateEmailNotifications(bool enabled) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(emailNotifications: enabled);
    return updatePreferences(updatedPrefs);
  }

  // Update push notifications preference
  Future<Map<String, dynamic>> updatePushNotifications(bool enabled) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(pushNotifications: enabled);
    return updatePreferences(updatedPrefs);
  }

  // Update in-app notifications preference
  Future<Map<String, dynamic>> updateInAppNotifications(bool enabled) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(inAppNotifications: enabled);
    return updatePreferences(updatedPrefs);
  }

  // Update category preference
  Future<Map<String, dynamic>> updateCategoryPreference(String category, bool enabled) async {
    final currentPrefs = await getPreferences();
    final updatedCategories = Map<String, bool>.from(currentPrefs.categoryPreferences);
    updatedCategories[category] = enabled;

    final updatedPrefs = currentPrefs.copyWith(categoryPreferences: updatedCategories);
    return updatePreferences(updatedPrefs);
  }

  // Register push notification token
  Future<Map<String, dynamic>> registerPushToken(String token) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/notification/token"),
        headers: await Global.getHeaders(),
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update cached preferences with new token
        if (_cachedPreferences != null) {
          _cachedPreferences = _cachedPreferences!.copyWith(pushToken: token);
          await _saveToLocal(_cachedPreferences!);
        }

        return {
          "success": true,
          "message": "Push notification token registered successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to register push token: ${response.statusCode}",
        };
      }
    } catch (e) {
      print('Error registering push token: $e');
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Get from local storage
  Future<NotificationPreferences> _getFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString != null) {
        final Map<String, dynamic> data = json.decode(jsonString);
        _cachedPreferences = NotificationPreferences.fromJson(data);
        return _cachedPreferences!;
      }
    } catch (e) {
      print('Error loading preferences from local storage: $e');
    }

    // Return default preferences
    _cachedPreferences = NotificationPreferences();
    return _cachedPreferences!;
  }

  // Save to local storage
  Future<void> _saveToLocal(NotificationPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(preferences.toJson());
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      print('Error saving preferences to local storage: $e');
    }
  }

  // Clear cache
  void clearCache() {
    _cachedPreferences = null;
  }

  // Check if a specific notification type is enabled
  Future<bool> isNotificationTypeEnabled(String type) async {
    final prefs = await getPreferences();

    switch (type.toLowerCase()) {
      case 'email':
        return prefs.emailNotifications;
      case 'push':
        return prefs.pushNotifications;
      case 'in_app':
        return prefs.inAppNotifications;
      default:
        return prefs.categoryPreferences[type] ?? true;
    }
  }

  // Get available notification categories
  List<String> getAvailableCategories() {
    return [
      'vacation',
      'attendance',
      'employees',
      'system',
      'holidays',
      'departments',
    ];
  }

  // Get category display name
  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'vacation':
        return 'Vacation Requests';
      case 'attendance':
        return 'Attendance';
      case 'employees':
        return 'Employee Management';
      case 'system':
        return 'System Updates';
      case 'holidays':
        return 'Holidays';
      case 'departments':
        return 'Departments';
      default:
        return category.toUpperCase();
    }
  }
}
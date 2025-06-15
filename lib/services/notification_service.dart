// lib/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Cache for notifications
  List<NotificationModel> _notifications = [];
  bool _hasLoaded = false;
  int _unreadCount = 0;

  // Listeners for real-time updates
  final List<Function()> _listeners = [];
  final List<Function(int)> _unreadCountListeners = [];

  // Getters
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get hasLoaded => _hasLoaded;

  // Add listeners
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void addUnreadCountListener(Function(int) listener) {
    _unreadCountListeners.add(listener);
  }

  void removeUnreadCountListener(Function(int) listener) {
    _unreadCountListeners.remove(listener);
  }

  // Notify listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void _notifyUnreadCountListeners() {
    for (var listener in _unreadCountListeners) {
      listener(_unreadCount);
    }
  }

  // Get notifications with pagination and filtering
  Future<Map<String, dynamic>> getNotifications({
    int page = 0,
    int size = 20,
    String? type,
    bool? seen,
    bool forceRefresh = false,
  }) async {
    if (_hasLoaded && !forceRefresh && _notifications.isNotEmpty) {
      // Return cached data if available
      var filteredNotifications = _notifications;

      if (type != null) {
        filteredNotifications = filteredNotifications.where((n) => n.type == type).toList();
      }

      if (seen != null) {
        filteredNotifications = filteredNotifications.where((n) => n.seen == seen).toList();
      }

      final startIndex = page * size;
      final endIndex = (startIndex + size).clamp(0, filteredNotifications.length);
      final pageData = filteredNotifications.sublist(
        startIndex.clamp(0, filteredNotifications.length),
        endIndex,
      );

      return {
        "success": true,
        "notifications": pageData,
        "totalElements": filteredNotifications.length,
        "totalPages": (filteredNotifications.length / size).ceil(),
        "currentPage": page,
        "size": size,
        "isFirst": page == 0,
        "isLast": endIndex >= filteredNotifications.length,
        "fromCache": true,
      };
    }

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (seen != null) queryParams['seen'] = seen.toString();

      final uri = Uri.parse("${Global.baseUrl}/secure/notifications")
          .replace(queryParameters: queryParams);

      print('Fetching notifications from: $uri');

      final response = await http.get(
        uri,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> content = responseData['content'] ?? [];

        print('Received ${content.length} notifications from API');

        final notifications = content
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Update cache only if this is the first page and no filters
        if (page == 0 && type == null && seen == null) {
          _notifications = notifications;
          _hasLoaded = true;
          _updateUnreadCount();
          _notifyListeners();
          _notifyUnreadCountListeners();
        }

        return {
          "success": true,
          "notifications": notifications,
          "totalElements": responseData['totalElements'] ?? 0,
          "totalPages": responseData['totalPages'] ?? 0,
          "currentPage": responseData['pageable']?['pageNumber'] ?? page,
          "size": responseData['pageable']?['pageSize'] ?? size,
          "isFirst": responseData['first'] ?? (page == 0),
          "isLast": responseData['last'] ?? false,
          "fromCache": false,
        };
      } else {
        print('Failed to load notifications: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          "success": false,
          "message": "Failed to load notifications: ${response.statusCode}",
          "notifications": <NotificationModel>[],
        };
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "notifications": <NotificationModel>[],
      };
    }
  }

  // Toggle notification seen status
  Future<Map<String, dynamic>> toggleNotificationStatus(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/notifications/toggle/$notificationId"),
        headers: await Global.getHeaders(),
      );

      print('Toggle notification status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local cache
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index >= 0) {
          _notifications[index] = _notifications[index].copyWith(
            seen: !_notifications[index].seen,
          );
          _updateUnreadCount();
          _notifyListeners();
          _notifyUnreadCountListeners();
        }

        return {
          "success": true,
          "message": "Notification status updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update notification status: ${response.statusCode}",
        };
      }
    } catch (e) {
      print('Error toggling notification status: $e');
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/notifications/all"),
        headers: await Global.getHeaders(),
      );

      print('Mark all as read response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local cache
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].seen) {
            _notifications[i] = _notifications[i].copyWith(seen: true);
          }
        }
        _updateUnreadCount();
        _notifyListeners();
        _notifyUnreadCountListeners();

        return {
          "success": true,
          "message": "All notifications marked as read",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to mark all notifications as read: ${response.statusCode}",
        };
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Register push notification token
  Future<Map<String, dynamic>> registerPushToken(String token) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/notification/token"),
        headers: await Global.getHeaders(),
        body: jsonEncode({"token": token}),
      );

      print('Register push token response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    if (!_hasLoaded) {
      final result = await getNotifications(size: 1);
      if (result["success"] == true) {
        // The unread count should be included in the response or calculated
        // For now, we'll use the cached count
        return _unreadCount;
      }
    }
    return _unreadCount;
  }

  // Update unread count from cached notifications
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.seen).length;
  }

  // Clear cache (useful for logout)
  void clearCache() {
    _notifications.clear();
    _hasLoaded = false;
    _unreadCount = 0;
    _notifyListeners();
    _notifyUnreadCountListeners();
  }

  // Refresh notifications from server
  Future<Map<String, dynamic>> refresh() async {
    return getNotifications(forceRefresh: true);
  }

  // Add a new notification to cache (useful for real-time updates)
  void addNotificationToCache(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.seen) {
      _unreadCount++;
    }
    _notifyListeners();
    _notifyUnreadCountListeners();
  }

  // Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    final result = await getNotifications(type: type);
    if (result["success"] == true) {
      return result["notifications"] as List<NotificationModel>;
    }
    return [];
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final result = await getNotifications(seen: false);
    if (result["success"] == true) {
      return result["notifications"] as List<NotificationModel>;
    }
    return [];
  }

  // Dispose method to clean up listeners
  void dispose() {
    _listeners.clear();
    _unreadCountListeners.clear();
  }
}
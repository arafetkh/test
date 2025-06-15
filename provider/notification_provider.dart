
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String _error = '';
  int _unreadCount = 0;

  // Pagination state
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  bool _hasMoreData = true;

  // Filter state
  String? _selectedType;
  bool? _selectedSeenStatus;

  // Getters
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String get error => _error;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  bool get hasMoreData => _hasMoreData;
  String? get selectedType => _selectedType;
  bool? get selectedSeenStatus => _selectedSeenStatus;

  NotificationProvider() {
    // Listen to service updates
    _service.addListener(_onServiceUpdate);
    _service.addUnreadCountListener(_onUnreadCountUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _service.removeUnreadCountListener(_onUnreadCountUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    _notifications = _service.notifications;
    _hasLoaded = _service.hasLoaded;
    notifyListeners();
  }

  void _onUnreadCountUpdate(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  // Initialize notifications
  Future<void> initialize() async {
    if (_hasLoaded) return;
    await loadNotifications();
  }

  // Load notifications (first page)
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _error = '';

    try {
      final result = await _service.getNotifications(
        page: 0,
        size: 20,
        type: _selectedType,
        seen: _selectedSeenStatus,
        forceRefresh: forceRefresh,
      );

      if (result["success"] == true) {
        _notifications = List<NotificationModel>.from(result["notifications"]);
        _currentPage = result["currentPage"] ?? 0;
        _totalPages = result["totalPages"] ?? 0;
        _totalElements = result["totalElements"] ?? 0;
        _hasMoreData = !result["isLast"];
        _hasLoaded = true;
        _unreadCount = _service.unreadCount;
        _error = '';
      } else {
        _error = result["message"] ?? "Failed to load notifications";
      }
    } catch (e) {
      _error = "Error loading notifications: $e";
    } finally {
      _setLoading(false);
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (_isLoading || !_hasMoreData) return;

    _setLoading(true);

    try {
      final result = await _service.getNotifications(
        page: _currentPage + 1,
        size: 20,
        type: _selectedType,
        seen: _selectedSeenStatus,
      );

      if (result["success"] == true) {
        final newNotifications = List<NotificationModel>.from(result["notifications"]);
        _notifications.addAll(newNotifications);
        _currentPage = result["currentPage"] ?? _currentPage + 1;
        _totalPages = result["totalPages"] ?? _totalPages;
        _totalElements = result["totalElements"] ?? _totalElements;
        _hasMoreData = !result["isLast"];
        _error = '';
      } else {
        _error = result["message"] ?? "Failed to load more notifications";
      }
    } catch (e) {
      _error = "Error loading more notifications: $e";
    } finally {
      _setLoading(false);
    }
  }

  // Toggle notification seen status
  Future<bool> toggleNotificationStatus(String notificationId) async {
    try {
      final result = await _service.toggleNotificationStatus(notificationId);

      if (result["success"] == true) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index >= 0) {
          _notifications[index] = _notifications[index].copyWith(
            seen: !_notifications[index].seen,
          );
          _updateUnreadCount();
          notifyListeners();
        }
        return true;
      } else {
        _error = result["message"] ?? "Failed to update notification";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error updating notification: $e";
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final result = await _service.markAllAsRead();

      if (result["success"] == true) {
        // Update local state
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].seen) {
            _notifications[i] = _notifications[i].copyWith(seen: true);
          }
        }
        _updateUnreadCount();
        notifyListeners();
        return true;
      } else {
        _error = result["message"] ?? "Failed to mark all as read";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error marking all as read: $e";
      notifyListeners();
      return false;
    }
  }

  // Register push notification token
  Future<bool> registerPushToken(String token) async {
    try {
      final result = await _service.registerPushToken(token);

      if (result["success"] == true) {
        return true;
      } else {
        _error = result["message"] ?? "Failed to register push token";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error registering push token: $e";
      notifyListeners();
      return false;
    }
  }

  // Filter notifications by type
  Future<void> filterByType(String? type) async {
    if (_selectedType == type) return;

    _selectedType = type;
    _resetPagination();
    await loadNotifications(forceRefresh: true);
  }

  // Filter notifications by seen status
  Future<void> filterBySeen(bool? seen) async {
    if (_selectedSeenStatus == seen) return;

    _selectedSeenStatus = seen;
    _resetPagination();
    await loadNotifications(forceRefresh: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    if (_selectedType == null && _selectedSeenStatus == null) return;

    _selectedType = null;
    _selectedSeenStatus = null;
    _resetPagination();
    await loadNotifications(forceRefresh: true);
  }

  // Refresh notifications
  Future<void> refresh() async {
    _resetPagination();
    await loadNotifications(forceRefresh: true);
  }

  // Add new notification (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.seen) {
      _unreadCount++;
    }
    _totalElements++;
    notifyListeners();
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.seen).length;
  }

  // Reset pagination state
  void _resetPagination() {
    _currentPage = 0;
    _totalPages = 0;
    _totalElements = 0;
    _hasMoreData = true;
    _notifications.clear();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Clear all data (useful for logout)
  void clear() {
    _notifications.clear();
    _hasLoaded = false;
    _unreadCount = 0;
    _error = '';
    _resetPagination();
    _service.clearCache();
    notifyListeners();
  }

  // Get notification by ID
  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((n) => !n.seen).toList();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }
}
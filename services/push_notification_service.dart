
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import '../services/notification_preferences_service.dart';
import '../services/notification_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationPreferencesService _preferencesService = NotificationPreferencesService();
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  String? _fcmToken;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  // Initialize push notifications
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('User denied permissions');
        return false;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        // Register token with backend
        await _preferencesService.registerPushToken(_fcmToken!);
      }

      // Set up message handlers
      _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        _fcmToken = token;
        print('FCM Token refreshed: $token');
        await _preferencesService.registerPushToken(token);
      });

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing push notifications: $e');
      return false;
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Set up message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification when app was terminated
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    // Check if in-app notifications are enabled
    final preferences = await _preferencesService.getPreferences();
    if (!preferences.inAppNotifications) return;

    // Check category preferences
    final category = message.data['category'];
    if (category != null && preferences.categoryPreferences.containsKey(category)) {
      if (!preferences.categoryPreferences[category]!) return;
    }

    // Create notification model from message
    final notification = _createNotificationFromMessage(message);

    // Add to local notification service
    _notificationService.addNotificationToCache(notification);

    // Show local notification
    await _showLocalNotification(message);
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.messageId}');

    // Background messages are handled by the system
    // We can perform lightweight operations here
  }

  // Handle when notification opened app
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Notification opened app: ${message.messageId}');

    // Create notification model
    final notification = _createNotificationFromMessage(message);

    // Navigate to appropriate screen based on actionUrl
    if (notification.actionUrl != null) {
      // Implement navigation logic
      await _handleNotificationNavigation(notification.actionUrl!);
    }
  }

  // Handle local notification tapped
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    print('Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        final actionUrl = data['actionUrl'];

        if (actionUrl != null) {
          await _handleNotificationNavigation(actionUrl);
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Default notification channel',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create payload for navigation
      final payload = json.encode({
        'messageId': message.messageId,
        'actionUrl': message.data['actionUrl'],
        'category': message.data['category'],
      });

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? '',
        details,
        payload: payload,
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Create notification model from FCM message
  NotificationModel _createNotificationFromMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? 'Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      timestamp: DateTime.now(),
      recipientUserId: message.data['userId'] ?? '',
      seen: false,
      type: message.data['type'] ?? 'info',
      actionUrl: message.data['actionUrl'],
      metadata: Map<String, dynamic>.from(message.data),
    );
  }

  // Handle navigation from notification
  Future<void> _handleNotificationNavigation(String actionUrl) async {
    // Implement navigation logic based on actionUrl
    // This would typically use your app's routing system
    print('Navigate to: $actionUrl');

    // Example implementation:
    // if (actionUrl.startsWith('/vacation/')) {
    //   final id = actionUrl.split('/').last;
    //   NavigationService.navigateToVacationDetail(id);
    // } else if (actionUrl.startsWith('/employee/')) {
    //   final id = actionUrl.split('/').last;
    //   NavigationService.navigateToEmployeeDetail(id);
    // }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  // Subscribe to role-based topics
  Future<void> subscribeToRoleTopics(String role) async {
    final topics = _getRoleTopics(role);
    for (final topic in topics) {
      await subscribeToTopic(topic);
    }
  }

  // Unsubscribe from role-based topics
  Future<void> unsubscribeFromRoleTopics(String role) async {
    final topics = _getRoleTopics(role);
    for (final topic in topics) {
      await unsubscribeFromTopic(topic);
    }
  }

  // Get topics for a specific role
  List<String> _getRoleTopics(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return ['admin', 'system', 'all_employees'];
      case 'MANAGER':
        return ['manager', 'employees', 'vacation_requests'];
      case 'HR':
        return ['hr', 'employees', 'vacation_requests', 'holidays'];
      case 'USER':
      default:
        return ['employees', 'general'];
    }
  }

  // Clear notification badge
  Future<void> clearBadge() async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false,
        sound: true,
      );
    } catch (e) {
      print('Error clearing badge: $e');
    }
  }

  // Get notification permissions status
  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Dispose
  void dispose() {
    _isInitialized = false;
    _fcmToken = null;
  }
}
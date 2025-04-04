import 'package:flutter/material.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/widget/NotificationItem.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/UserProfileHeader.dart';
import 'package:provider/provider.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/widget/translate_text.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
// Import the notification components
import 'package:in_out/widget/NotificationItem.dart'; // Adjust path as needed

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();

  factory NotificationsService() => _instance;

  NotificationsService._internal();

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);


  int get unreadCount => _notifications.where((n) => !n.isRead).length;


  Future<void> initialize() async {

    _addSampleNotifications();
  }

  void addNotification(NotificationModel notification) {
    _notifications.add(notification);

    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final notification = _notifications[index];
      final updatedNotification = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        avatarUrl: notification.avatarUrl,
        avatarInitials: notification.avatarInitials,
        avatarColor: notification.avatarColor,
        icon: notification.icon,
        iconBackgroundColor: notification.iconBackgroundColor,
        iconColor: notification.iconColor,
        isRead: true,
      );

      _notifications[index] = updatedNotification;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      _notifications[i] = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        avatarUrl: notification.avatarUrl,
        avatarInitials: notification.avatarInitials,
        avatarColor: notification.avatarColor,
        icon: notification.icon,
        iconBackgroundColor: notification.iconBackgroundColor,
        iconColor: notification.iconColor,
        isRead: true,
      );
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }


  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }


  final List<Function()> _listeners = [];

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void _addSampleNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Leave Request',
        message: '@Robert Fox has applied for leave',
        timestamp: DateTime.now(),
        avatarInitials: 'RF',
        avatarColor: Colors.blue.shade100,
      ),
      NotificationModel(
        id: '2',
        title: 'Check In Issue',
        message: '@Alexa shared a message regarding check in issue',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        avatarInitials: 'A',
        avatarColor: Colors.orange.shade100,
      ),
      NotificationModel(
        id: '3',
        title: 'Applied job for "Sales Manager" Position',
        message: '@Shane Watson has applied for job',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.person_outline,
        iconBackgroundColor: Colors.green.shade100,
        iconColor: Colors.green,
      ),
      NotificationModel(
        id: '4',
        title: 'Robert Fox has share his feedback',
        message: '"It was an amazing experience with your organization"',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        avatarInitials: 'RF',
        avatarColor: Colors.purple.shade100,
      ),
      NotificationModel(
        id: '5',
        title: 'Password Update successfully',
        message: 'Your password has been updated successfully',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.lock_outline,
        iconBackgroundColor: Colors.green.shade100,
        iconColor: Colors.green,
      ),
    ]);
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 0;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();
  final NotificationsService _notificationsService = NotificationsService();
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _notificationsService.addListener(_updateNotifications);
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationsService.initialize();
    _updateNotifications();
  }

  void _updateNotifications() {
    setState(() {
      _notifications = _notificationsService.notifications;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _notificationsService.removeListener(_updateNotifications);
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark notification as read when tapped
    if (!notification.isRead) {
      _notificationsService.markAsRead(notification.id);
    }

    // Handle different notification types
    // You could navigate to different screens based on the notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification tapped: ${notification.title}')),
    );
  }

  void _handleMarkAllAsRead() {
    _notificationsService.markAllAsRead();
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.06;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.04,
        horizontal: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        boxShadow: _isHeaderVisible
            ? []
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundColor: const Color(0xFFFFD6EC),
            child: Text(
              "RA",
              style: TextStyle(
                color: const Color(0xFFD355A8),
                fontWeight: FontWeight.bold,
                fontSize: avatarSize * 0.7,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Robert Allen",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                TranslateText(
                  "juniorFullStackDeveloper",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F5E5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF2E7D32),
                  size: screenWidth * 0.05,
                ),
              ),
              if (_notificationsService.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.01),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _notificationsService.unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslateText(
                "notifications",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TranslateText(
                "allNotifications",
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: screenWidth * 0.15,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: screenWidth * 0.04),
          TranslateText(
            "noNotifications",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TranslateText(
            "allCaughtUp",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) {
        NavigationService.navigateToScreen(context, index);
      },
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),

            // Content
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildPageHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final notification = _notifications[index];
                        return NotificationItem(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                          onMarkAsRead: !notification.isRead
                              ? () => _notificationsService.markAsRead(notification.id)
                              : null,
                        );
                      },
                      childCount: _notifications.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
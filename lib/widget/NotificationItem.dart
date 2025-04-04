import 'package:flutter/material.dart';

/// Model class for notification data
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? avatarUrl;
  final String? avatarInitials;
  final Color? avatarColor;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.avatarUrl,
    this.avatarInitials,
    this.avatarColor,
    this.icon,
    this.iconBackgroundColor,
    this.iconColor,
    this.isRead = false,
  });

  /// Create a notification from database map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      avatarUrl: map['avatarUrl'],
      avatarInitials: map['avatarInitials'],
      avatarColor: map['avatarColor'] != null
          ? Color(map['avatarColor'])
          : null,
      icon: map['icon'] != null
          ? IconData(map['icon'], fontFamily: 'MaterialIcons')
          : null,
      iconBackgroundColor: map['iconBackgroundColor'] != null
          ? Color(map['iconBackgroundColor'])
          : null,
      iconColor: map['iconColor'] != null
          ? Color(map['iconColor'])
          : null,
      isRead: map['isRead'] ?? false,
    );
  }

  /// Convert notification to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'avatarUrl': avatarUrl,
      'avatarInitials': avatarInitials,
      'avatarColor': avatarColor?.value,
      'icon': icon?.codePoint,
      'iconBackgroundColor': iconBackgroundColor?.value,
      'iconColor': iconColor?.value,
      'isRead': isRead,
    };
  }
}

/// Reusable notification item widget
class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationItem({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  }) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : Colors.blue.shade100,
              width: 1
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar or Icon
            _buildAvatar(screenWidth),
            SizedBox(width: screenWidth * 0.03),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!notification.isRead && onMarkAsRead != null) ...[
                  SizedBox(height: screenWidth * 0.02),
                  GestureDetector(
                    onTap: onMarkAsRead,
                    child: Container(
                      width: screenWidth * 0.02,
                      height: screenWidth * 0.02,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(double screenWidth) {
    // If avatar initials are provided, use them
    if (notification.avatarInitials != null && notification.avatarInitials!.isNotEmpty) {
      return CircleAvatar(
        radius: screenWidth * 0.06,
        backgroundColor: notification.avatarColor ?? Colors.grey.shade200,
        backgroundImage: notification.avatarUrl != null
            ? NetworkImage(notification.avatarUrl!)
            : null,
        child: notification.avatarUrl == null
            ? Text(
          notification.avatarInitials!,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        )
            : null,
      );
    }
    // If icon is provided, use it
    else if (notification.icon != null) {
      return CircleAvatar(
        radius: screenWidth * 0.06,
        backgroundColor: notification.iconBackgroundColor ?? Colors.grey.shade200,
        child: Icon(
          notification.icon!,
          color: notification.iconColor ?? Colors.grey.shade700,
          size: screenWidth * 0.06,
        ),
      );
    }
    // Default avatar
    else {
      return CircleAvatar(
        radius: screenWidth * 0.06,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.notifications_outlined,
          color: Colors.grey.shade700,
          size: screenWidth * 0.06,
        ),
      );
    }
  }
}
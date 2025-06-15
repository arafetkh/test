import 'package:flutter/material.dart';
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String recipientUserId;
  final bool seen;
  final String? avatarUrl;
  final String? avatarInitials;
  final Color? avatarColor;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final String? type; // info, warning, success, error
  final Map<String, dynamic>? metadata; // Additional data for the notification
  final String? actionUrl; // URL to navigate when notification is tapped

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.recipientUserId,
    this.seen = false,
    this.avatarUrl,
    this.avatarInitials,
    this.avatarColor,
    this.icon,
    this.iconBackgroundColor,
    this.iconColor,
    this.type,
    this.metadata,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['subject'] ?? '',
      body: json['body'] ?? json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      recipientUserId: json['recipientUserId']?.toString() ?? '',
      seen: json['seen'] ?? false,
      avatarUrl: json['avatarUrl'],
      avatarInitials: json['avatarInitials'],
      avatarColor: json['avatarColor'] != null
          ? Color(json['avatarColor'])
          : null,
      icon: json['icon'] != null
          ? IconData(json['icon'], fontFamily: 'MaterialIcons')
          : null,
      iconBackgroundColor: json['iconBackgroundColor'] != null
          ? Color(json['iconBackgroundColor'])
          : null,
      iconColor: json['iconColor'] != null
          ? Color(json['iconColor'])
          : null,
      type: json['type'],
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      actionUrl: json['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'recipientUserId': recipientUserId,
      'seen': seen,
      'avatarUrl': avatarUrl,
      'avatarInitials': avatarInitials,
      'avatarColor': avatarColor?.value,
      'icon': icon?.codePoint,
      'iconBackgroundColor': iconBackgroundColor?.value,
      'iconColor': iconColor?.value,
      'type': type,
      'metadata': metadata,
      'actionUrl': actionUrl,
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? recipientUserId,
    bool? seen,
    String? avatarUrl,
    String? avatarInitials,
    Color? avatarColor,
    IconData? icon,
    Color? iconBackgroundColor,
    Color? iconColor,
    String? type,
    Map<String, dynamic>? metadata,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      seen: seen ?? this.seen,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      icon: icon ?? this.icon,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // Helper method to determine if notification is urgent
  bool get isUrgent => type == 'error' || type == 'warning';

  // Helper method to get formatted time
  String get formattedTime {
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
}
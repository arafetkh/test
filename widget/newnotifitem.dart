// lib/widget/enhanced_notification_item.dart
import 'package:flutter/material.dart';
import '../theme/adaptive_colors.dart';
import '../models/notification_model.dart';

class EnhancedNotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onToggleRead;
  final VoidCallback? onLongPress;
  final bool showActions;
  final bool condensed;

  const EnhancedNotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onToggleRead,
    this.onLongPress,
    this.showActions = true,
    this.condensed = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = AdaptiveColors.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: condensed ? screenWidth * 0.02 : screenWidth * 0.04,
          vertical: condensed ? screenWidth * 0.01 : screenWidth * 0.02,
        ),
        padding: EdgeInsets.all(condensed ? screenWidth * 0.03 : screenWidth * 0.04),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context, isDark),
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          border: Border.all(
            color: _getBorderColor(isDark),
            width: notification.isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AdaptiveColors.shadowColor(context),
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
            _buildAvatar(screenWidth, context),
            SizedBox(width: screenWidth * 0.03),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with type indicator
                  Row(
                    children: [
                      if (notification.type != null) ...[
                        _buildTypeIndicator(context, screenWidth),
                        SizedBox(width: screenWidth * 0.02),
                      ],
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: condensed ? screenWidth * 0.032 : screenWidth * 0.035,
                            fontWeight: notification.seen ? FontWeight.normal : FontWeight.bold,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          maxLines: condensed ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (!condensed) SizedBox(height: screenWidth * 0.01),

                  // Body text
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: condensed ? screenWidth * 0.028 : screenWidth * 0.03,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    maxLines: condensed ? 1 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (!condensed && notification.metadata != null && notification.metadata!.isNotEmpty) ...[
                    SizedBox(height: screenWidth * 0.01),
                    _buildMetadata(context, screenWidth),
                  ],
                ],
              ),
            ),

            // Time and actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time
                Text(
                  notification.formattedTime,
                  style: TextStyle(
                    fontSize: condensed ? screenWidth * 0.025 : screenWidth * 0.028,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),

                if (showActions) ...[
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Unread indicator
                      if (!notification.seen)
                        Container(
                          width: screenWidth * 0.025,
                          height: screenWidth * 0.025,
                          decoration: BoxDecoration(
                            color: _getTypeColor(),
                            shape: BoxShape.circle,
                          ),
                        ),

                      if (!notification.seen && onToggleRead != null)
                        SizedBox(width: screenWidth * 0.02),

                      // Toggle read button
                      if (onToggleRead != null)
                        GestureDetector(
                          onTap: onToggleRead,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.01),
                            child: Icon(
                              notification.seen ? Icons.mark_email_unread : Icons.mark_email_read,
                              size: condensed ? screenWidth * 0.04 : screenWidth * 0.045,
                              color: AdaptiveColors.secondaryTextColor(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(double screenWidth, BuildContext context) {
    final avatarSize = screenWidth * (condensed ? 0.05 : 0.06);

    // Use avatar initials if provided
    if (notification.avatarInitials != null && notification.avatarInitials!.isNotEmpty) {
      return CircleAvatar(
        radius: avatarSize,
        backgroundColor: notification.avatarColor ?? _getTypeColor().withOpacity(0.2),
        backgroundImage: notification.avatarUrl != null
            ? NetworkImage(notification.avatarUrl!)
            : null,
        child: notification.avatarUrl == null
            ? Text(
          notification.avatarInitials!,
          style: TextStyle(
            color: AdaptiveColors.isDarkMode(context) ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * (condensed ? 0.03 : 0.035),
          ),
        )
            : null,
      );
    }
    // Use icon if provided
    else if (notification.icon != null) {
      return CircleAvatar(
        radius: avatarSize,
        backgroundColor: notification.iconBackgroundColor ?? _getTypeColor().withOpacity(0.2),
        child: Icon(
          notification.icon!,
          color: notification.iconColor ?? _getTypeColor(),
          size: screenWidth * (condensed ? 0.05 : 0.06),
        ),
      );
    }
    // Default avatar based on type
    else {
      return CircleAvatar(
        radius: avatarSize,
        backgroundColor: _getTypeColor().withOpacity(0.2),
        child: Icon(
          _getDefaultIcon(),
          color: _getTypeColor(),
          size: screenWidth * (condensed ? 0.05 : 0.06),
        ),
      );
    }
  }

  Widget _buildTypeIndicator(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
        vertical: screenWidth * 0.005,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.01),
        border: Border.all(
          color: _getTypeColor().withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        _getTypeLabel(),
        style: TextStyle(
          fontSize: screenWidth * 0.025,
          fontWeight: FontWeight.w500,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, double screenWidth) {
    final metadata = notification.metadata!;
    return Wrap(
      spacing: screenWidth * 0.02,
      runSpacing: screenWidth * 0.01,
      children: metadata.entries.map((entry) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenWidth * 0.005,
          ),
          decoration: BoxDecoration(
            color: AdaptiveColors.secondaryTextColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    if (!notification.seen) {
      if (notification.isUrgent) {
        return isDark
            ? Colors.red.shade900.withOpacity(0.1)
            : Colors.red.shade50;
      } else {
        return isDark
            ? Colors.blue.shade900.withOpacity(0.1)
            : Colors.blue.shade50;
      }
    }
    return AdaptiveColors.cardColor(context);
  }

  Color _getBorderColor(bool isDark) {
    if (!notification.seen) {
      return _getTypeColor().withOpacity(0.3);
    }
    return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getDefaultIcon() {
    switch (notification.type) {
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_outlined;
      case 'success':
        return Icons.check_circle_outline;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  String _getTypeLabel() {
    switch (notification.type) {
      case 'error':
        return 'Error';
      case 'warning':
        return 'Warning';
      case 'success':
        return 'Success';
      case 'info':
        return 'Info';
      default:
        return notification.type?.toUpperCase() ?? 'NOTIFICATION';
    }
  }
}
import 'package:flutter/material.dart';
  import 'package:in_out/widget/translate_text.dart';
  import 'package:in_out/NotificationsScreen.dart';
  import '../theme/adaptive_colors.dart';

  class UserProfileHeader extends StatelessWidget {
    final bool isHeaderVisible;
    final VoidCallback? onNotificationTap;
    final int? unreadNotificationsCount;

    const UserProfileHeader({
      super.key,
      required this.isHeaderVisible,
      this.onNotificationTap,
      this.unreadNotificationsCount,
    });

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final avatarSize = screenWidth * 0.06;

      return Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          boxShadow: isHeaderVisible
              ? []
              : [
                  BoxShadow(
                    color: AdaptiveColors.shadowColor(context),
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
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TranslateText(
                    "juniorFullStackDeveloper",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onNotificationTap ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F5E5),
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AdaptiveColors.primaryGreen,
                      size: screenWidth * 0.05,
                    ),
                  ),
                  if (unreadNotificationsCount != null && unreadNotificationsCount! > 0)
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
                          unreadNotificationsCount.toString(),
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
            ),
          ],
        ),
      );
    }
  }
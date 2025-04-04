import 'package:flutter/material.dart';
import 'package:in_out/NotificationsScreen.dart';
import 'package:in_out/widget/translate_text.dart';

class LandscapeUserProfileHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final int? unreadNotificationsCount;

  const LandscapeUserProfileHeader({
    super.key,
    this.onNotificationTap,
    this.unreadNotificationsCount,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    final containerHeight = screenHeight * 0.12;
    final avatarRadius = screenHeight * 0.035;
    final horizontalPadding = screenWidth * 0.02;

    return Container(
      height: containerHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFFFFD6EC),
            child: Text(
              "RA",
              style: TextStyle(
                color: const Color(0xFFD355A8),
                fontWeight: FontWeight.bold,
                fontSize: avatarRadius * 0.7,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Robert Allen",
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              TranslateText(
                "juniorFullStackDeveloper",
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Spacer(),
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
                  padding: EdgeInsets.all(screenHeight * 0.015),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F5E5),
                    borderRadius: BorderRadius.circular(screenHeight * 0.025),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: const Color(0xFF2E7D32),
                    size: screenHeight * 0.035, // Slightly larger icon
                  ),
                ),
                if (unreadNotificationsCount != null && unreadNotificationsCount! > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.005),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadNotificationsCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.014,
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
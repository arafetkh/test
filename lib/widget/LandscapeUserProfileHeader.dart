import 'package:flutter/material.dart';
import 'package:in_out/NotificationsScreen.dart';
import 'package:in_out/widget/translate_text.dart';
import '../theme/adaptive_colors.dart';
import '../localization/app_localizations.dart';

class LandscapeUserProfileHeader extends StatelessWidget {
  final bool isHeaderVisible;
  final VoidCallback? onNotificationTap;
  final int? unreadNotificationsCount;

  const LandscapeUserProfileHeader({
    super.key,
    required this.isHeaderVisible,
    this.onNotificationTap,
    this.unreadNotificationsCount,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final avatarSize = screenHeight * 0.035;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final localizations = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isHeaderVisible ? null : 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          boxShadow: isHeaderVisible
              ? []
              : [
                  BoxShadow(
                    color: AdaptiveColors.shadowColor(context),
                    spreadRadius: screenWidth * 0.001,
                    blurRadius: screenWidth * 0.003,
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
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.getString("robertAllen"),
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TranslateText(
                    "juniorFullStackDeveloper",
                    style: TextStyle(
                      fontSize: screenHeight * 0.021,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onNotificationTap ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.008),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E4620)
                      : const Color(0xFFE5F5E5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AdaptiveColors.primaryGreen,
                      size: screenHeight * 0.032,
                    ),
                    if (unreadNotificationsCount != null &&
                        unreadNotificationsCount! > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.005),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadNotificationsCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.01,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
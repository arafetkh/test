import 'package:flutter/material.dart';

class AdaptiveColors {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Couleurs fixes
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color presentColor = Color(0xFF388E3C);
  static const Color absentColor = Color(0xFFF44336);
  static const Color onTimeColor = Color(0xFF4CAF50);
  static const Color lateColor = Color(0xFFF44336);

  // Couleurs spécifiques au dark mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkBorderColor = Color(0xFF333333);
  static const Color darkSidebarActive = Color(0xFF1EAE78); // Couleur de surlignage du menu actif (sidebar)

  // Couleurs pour le mode clair
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightCardColor = Colors.white;
  static const Color lightBorderColor = Color(0xFFE0E0E0);

  // Interface adaptative
  static Color cardColor(BuildContext context) {
    return isDarkMode(context) ? darkCardColor : lightCardColor;
  }

  static Color backgroundColor(BuildContext context) {
    return isDarkMode(context) ? darkBackground : lightBackground;
  }

  static Color primaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black87;
  }

  static Color secondaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  static Color tertiaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade400;
  }

  static Color borderColor(BuildContext context) {
    return isDarkMode(context) ? darkBorderColor : lightBorderColor;
  }

  static Color shadowColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.1);
  }

  static Color chartGridColor(BuildContext context) {
    return isDarkMode(context) ? darkBorderColor : lightBorderColor;
  }


  static Color iconBackgroundColor(BuildContext context) {
    return primaryGreen;
  }

  static Color dropdownBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFF262626) : Colors.white;
  }

  static Color statusColor(bool isOnTime) {
    return isOnTime ? onTimeColor : lateColor;
  }

  static Color positiveIndicatorColor(BuildContext context) {
    return Color(0xFF4CAF50); // Flèche verte positive (+12% sur la capture)
  }

  static Color negativeIndicatorColor(BuildContext context) {
    return Color(0xFFF44336); // Flèche rouge négative (-6% sur la capture)
  }

  static Color sidebarActiveColor() {
    return darkSidebarActive;
  }

  // Décoration pour le graphique d'assiduité avec bordure bleue
  static BoxDecoration chartBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardColor(context),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // Décoration standard pour cartes
  static BoxDecoration cardBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardColor(context),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: shadowColor(context),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // Décoration pour les indicateurs de tendance avec flèches
  static Widget buildTrendIndicator(bool isPositive, String percentage, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPositive
            ? positiveIndicatorColor(context).withOpacity(0.1)
            : negativeIndicatorColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositive ? positiveIndicatorColor(context) : negativeIndicatorColor(context),
          ),
          const SizedBox(width: 2),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPositive ? positiveIndicatorColor(context) : negativeIndicatorColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
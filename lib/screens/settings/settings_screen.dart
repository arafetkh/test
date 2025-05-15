import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/provider/profile_provider.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/user_profile_header.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'package:in_out/widget/translate_text.dart';
import 'package:provider/provider.dart';
import 'package:in_out/auth/auth_service.dart';
import 'package:in_out/screens/Login/login_page.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../ai/face_registration_screen.dart';
import '../notifications/notifications_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 5;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  bool _mobilePushEnabled = true;
  bool _desktopPushEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize from profile provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      // If profile not loaded yet and not currently loading, trigger a load
      if (profileProvider.userProfile == null && !profileProvider.isLoading) {
        profileProvider.loadProfile();
      }
    });
  }

  Future<void> _updateTwoFactorAuthentication(bool enabled) async {
    // Use ProfileProvider to update the backend
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final success =
        await profileProvider.updateTwoFactorAuthentication(enabled);

    if (!success) {
      // Show error message if update failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: ${profileProvider.error}")),
      );
    }
  }

  Future<void> _updateLanguage(String languageCode) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final userSettingsProvider =
        Provider.of<UserSettingsProvider>(context, listen: false);

    // First update the UI (UserSettingsProvider) for immediate feedback
    userSettingsProvider.changeLanguage(languageCode);

    // Then update the backend
    final success = await profileProvider.updateLanguage(languageCode);

    if (!success) {
      // Show error message but don't revert the UI (to avoid jarring language switch)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Failed to update language: ${profileProvider.error}")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  void _changeTheme(String themeMode, BuildContext context) {
    final userSettingsProvider =
        Provider.of<UserSettingsProvider>(context, listen: false);
    userSettingsProvider.changeThemeMode(themeMode);

    if (themeMode == 'light') {
      AdaptiveTheme.of(context).setLight();
    } else if (themeMode == 'dark') {
      AdaptiveTheme.of(context).setDark();
    } else if (themeMode == 'system') {
      AdaptiveTheme.of(context).setSystem();
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  void _showColorPicker(BuildContext context, bool isPrimary) {
    final userSettingsProvider =
        Provider.of<UserSettingsProvider>(context, listen: false);
    final settings = userSettingsProvider.currentSettings;
    Color pickerColor =
        isPrimary ? settings.primaryColor : settings.secondaryColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isPrimary
                ? AppLocalizations.of(context).getString('selectPrimaryColor')
                : AppLocalizations.of(context)
                    .getString('selectSecondaryColor'),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).getString('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).getString('apply')),
              onPressed: () {
                // Apply changes to both providers
                if (isPrimary) {
                  userSettingsProvider.changePrimaryColor(pickerColor);
                } else {
                  userSettingsProvider.changeSecondaryColor(pickerColor);
                }

                // Rebuild the entire app to apply color changes
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Logout Confirmation'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Close the dialog
                      Navigator.of(context).pop();

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      // Perform logout
                      await AuthService.logout(context);

                      // Close loading indicator
                      Navigator.of(context).pop();

                      // Navigate to login page
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsHeader(String titleKey, String subtitleKey) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslateText(
          titleKey,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: AdaptiveColors.primaryTextColor(context),
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        TranslateText(
          subtitleKey,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
      ],
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslateText(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                TranslateText(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildColorPreview(Color color, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.1,
        height: screenWidth * 0.1,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: AdaptiveColors.borderColor(context),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownWidget(
      String value, List<String> options, Function(String?) onChanged) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AdaptiveColors.borderColor(context)),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        color: AdaptiveColors.dropdownBackgroundColor(context),
      ),
      child: DropdownButton<String>(
        value: value,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: screenWidth * 0.045,
          color: AdaptiveColors.secondaryTextColor(context),
        ),
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
          color: AdaptiveColors.primaryTextColor(context),
        ),
        dropdownColor: AdaptiveColors.dropdownBackgroundColor(context),
        underline: Container(height: 0),
        isDense: true,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: TranslateText(
              value,
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: AdaptiveColors.primaryGreen,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AdaptiveColors.isDarkMode(context)
          ? Colors.grey.shade700
          : Colors.grey.shade300,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final userSettingsProvider = Provider.of<UserSettingsProvider>(context);
    final settings = userSettingsProvider.currentSettings;
    final profileProvider = Provider.of<ProfileProvider>(context);

    final Map<String, String> languageDisplayNames = {
      'en': 'english',
      'fr': 'french',
    };

    final Map<String, String> displayToLanguageCode = {
      'english': 'en',
      'french': 'fr',
    };

    // Get current theme mode
    String currentThemeMode = settings.themeMode;

    // Get current language from profile, fallback to settings
    String currentLanguage =
        profileProvider.userProfile?.locale ?? settings.language;
    String currentLanguageDisplay =
        languageDisplayNames[currentLanguage] ?? 'english';

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),

            // Content
            Expanded(
              child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                // Loading state
                if (profileProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (profileProvider.error.isNotEmpty &&
                    profileProvider.userProfile == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profileProvider.error,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () => profileProvider.loadProfile(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Success state - show settings
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(padding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // User Profile Card
                          Container(
                            margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: AdaptiveColors.cardColor(context),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04),
                              boxShadow: [
                                BoxShadow(
                                  color: AdaptiveColors.shadowColor(context),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: screenWidth * 0.08,
                                  backgroundColor: const Color(0xFFFFD6EC),
                                  child: Text(
                                    "${profileProvider.userProfile!.firstName[0]}${profileProvider.userProfile!.lastName[0]}",
                                    style: TextStyle(
                                      color: const Color(0xFFD355A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.02),
                                Text(
                                  "${profileProvider.userProfile!.firstName} ${profileProvider.userProfile!.lastName}",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                Text(
                                  profileProvider.userProfile!.email,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: AdaptiveColors.secondaryTextColor(
                                        context),
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                Text(
                                  profileProvider.userProfile!.role
                                      .toLowerCase()
                                      .replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: AdaptiveColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Settings Header
                          _buildSettingsHeader(
                            "settings",
                            "allSystemSettings",
                          ),

                          // Appearance Setting
                          _buildSettingItem(
                            title: "appearance",
                            subtitle: "customizeTheme",
                            trailing: _buildDropdownWidget(
                              currentThemeMode,
                              ['light', 'dark', 'system'],
                              (newValue) {
                                if (newValue != null) {
                                  _changeTheme(newValue, context);
                                }
                              },
                            ),
                          ),

                          // Primary Color Setting
                          _buildSettingItem(
                            title: "primaryColor",
                            subtitle: "choosePrimaryColor",
                            trailing: _buildColorPreview(
                              settings.primaryColor,
                              () => _showColorPicker(context, true),
                            ),
                          ),

                          // Secondary Color Setting
                          _buildSettingItem(
                            title: "secondaryColor",
                            subtitle: "chooseSecondaryColor",
                            trailing: _buildColorPreview(
                              settings.secondaryColor,
                              () => _showColorPicker(context, false),
                            ),
                          ),

                          // Language Setting
                          _buildSettingItem(
                            title: "language",
                            subtitle: "selectLanguage",
                            trailing: _buildDropdownWidget(
                              currentLanguageDisplay,
                              languageDisplayNames.values.toList(),
                              (newValue) {
                                if (newValue != null) {
                                  // Convert display name to language code
                                  final languageCode =
                                      displayToLanguageCode[newValue];
                                  if (languageCode != null) {
                                    // Change app language via profile service
                                    _updateLanguage(languageCode);
                                  }
                                }
                              },
                            ),
                          ),

                          // Two-factor Authentication
                          _buildSettingItem(
                            title: "twoFactorAuth",
                            subtitle: "twoFactorDescription",
                            trailing: Consumer<ProfileProvider>(
                              builder: (context, profileProvider, child) {
                                return _buildSwitch(
                                  profileProvider
                                          .userProfile?.secondFactorEnabled ??
                                      false,
                                  (value) =>
                                      _updateTwoFactorAuthentication(value),
                                );
                              },
                            ),
                          ),

                          // Mobile Push Notifications
                          _buildSettingItem(
                            title: "mobilePushNotifications",
                            subtitle: "receivePushNotification",
                            trailing: _buildSwitch(
                              _mobilePushEnabled,
                              (value) {
                                setState(() {
                                  _mobilePushEnabled = value;
                                });
                                // Note: This would be connected to a real API in a production app
                              },
                            ),
                          ),

                          // Desktop Notification
                          _buildSettingItem(
                            title: "desktopNotification",
                            subtitle: "desktopPushDescription",
                            trailing: _buildSwitch(
                              _desktopPushEnabled,
                              (value) {
                                setState(() {
                                  _desktopPushEnabled = value;
                                });
                              },
                            ),
                          ),

                          // Email Notifications
                          _buildSettingItem(
                            title: "emailNotifications",
                            subtitle: "receiveEmailNotification",
                            trailing: _buildSwitch(
                              _emailNotificationsEnabled,
                              (value) {
                                setState(() {
                                  _emailNotificationsEnabled = value;
                                });
                              },
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FaceRegistrationScreen(),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: AdaptiveColors.cardColor(context),
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
                                children: [
                                  Icon(
                                    Icons.face,
                                    size: screenWidth * 0.06,
                                    color: AdaptiveColors.primaryGreen,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Remote Attendance",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.w500,
                                            color: AdaptiveColors.primaryTextColor(context),
                                          ),
                                        ),
                                        SizedBox(height: screenWidth * 0.01),
                                        Text(
                                          "Check in/out remotely using Face ID",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: AdaptiveColors.secondaryTextColor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: screenWidth * 0.04,
                                    color: AdaptiveColors.secondaryTextColor(context),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Logout Button
                          _buildLogoutButton(context),
                        ]),
                      ),
                    ),
                  ],
                );
              }),
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

import 'package:flutter/material.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/UserProfileHeader.dart';
import 'package:provider/provider.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/widget/translate_text.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';

import 'NotificationsScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 4;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  // Settings switches
  bool _twoFactorEnabled = true;
  bool _mobilePushEnabled = true;
  bool _desktopPushEnabled = true;
  bool _emailNotificationsEnabled = true;

  // Theme dropdown - use translation keys
  String _selectedTheme = 'light';
  List<String> themeOptions = ['light', 'dark', 'system'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
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
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String titleKey, String subtitleKey) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use TranslateText for title and subtitle
        TranslateText(
          titleKey,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        TranslateText(
          subtitleKey,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Colors.grey.shade600,
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
  })
  {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use TranslateText for title and subtitle
                TranslateText(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                TranslateText(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
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

  Widget _buildDropdownWidget(String value, List<String> options, Function(String?) onChanged) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: DropdownButton<String>(
        value: value,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: screenWidth * 0.045,
        ),
        iconEnabledColor: Colors.grey.shade700,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        underline: Container(height: 0),
        isDense: true,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: TranslateText(value), // Use TranslateText here
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
      activeTrackColor: const Color(0xFF2E7D32),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    // Get the language provider
    final languageProvider = Provider.of<LanguageProvider>(context);

    final Map<String, String> languageDisplayNames = {
      'en': 'english',
      'fr': 'french',
    };

    final Map<String, String> displayToLanguageCode = {
      'english': 'en',
      'french': 'fr',
    };
    // Get current language for dropdown
    String currentLanguageDisplay = languageDisplayNames[languageProvider.currentLanguage] ?? 'english';

    return ResponsiveNavigationScaffold(
      selectedIndex: 4,
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
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(padding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
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
                            _selectedTheme,
                            themeOptions,
                                (newValue) {
                              setState(() {
                                _selectedTheme = newValue!;
                              });
                            },
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
                                final languageCode = displayToLanguageCode[newValue];
                                if (languageCode != null) {
                                  // Change app language
                                  languageProvider.changeLanguage(languageCode);
                                }
                              }
                            },
                          ),
                        ),

                        // Two-factor Authentication
                        _buildSettingItem(
                          title: "twoFactorAuth",
                          subtitle: "twoFactorDescription",
                          trailing: _buildSwitch(
                            _twoFactorEnabled,
                                (value) {
                              setState(() {
                                _twoFactorEnabled = value;
                              });
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
                      ]),
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
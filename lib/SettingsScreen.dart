import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:in_out/services/NavigationService.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/ResponsiveNavigationScaffold.dart';
import 'package:in_out/widget/UserProfileHeader.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/widget/translate_text.dart';

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

  bool _twoFactorEnabled = true;
  bool _mobilePushEnabled = true;
  bool _desktopPushEnabled = true;
  bool _emailNotificationsEnabled = true;

  String _selectedTheme = 'light';
  List<String> themeOptions = ['light', 'dark', 'system'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initialize theme dropdown based on actual theme mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeThemeSelection();
    });
  }

  void _initializeThemeSelection() {
    final adaptiveTheme = AdaptiveTheme.of(context);
    if (adaptiveTheme.mode == AdaptiveThemeMode.dark) {
      setState(() {
        _selectedTheme = 'dark';
      });
    } else if (adaptiveTheme.mode == AdaptiveThemeMode.light) {
      setState(() {
        _selectedTheme = 'light';
      });
    } else {
      setState(() {
        _selectedTheme = 'system';
      });
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

  void _changeTheme(String themeMode) {
    setState(() {
      _selectedTheme = themeMode;
    });

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

  Widget _buildDropdownWidget(String value, List<String> options, Function(String?) onChanged) {
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
                              if (newValue != null) {
                                _changeTheme(newValue);
                              }
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
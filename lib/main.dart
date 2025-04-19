// lib/main.dart (update)
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'auth/auth_wrapper.dart';
import 'localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final userId = await AuthService.getCurrentUserId();

  final userSettingsProvider = UserSettingsProvider();
  await userSettingsProvider.initialize(userId);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider.value(value: userSettingsProvider),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, UserSettingsProvider>(
      builder: (context, languageProvider, userSettingsProvider, child) {
        // Get user settings
        final settings = userSettingsProvider.currentSettings;

        // Create theme data with user's primary color
        final lightTheme = ThemeData(
          brightness: Brightness.light,
          primarySwatch: _createMaterialColor(settings.primaryColor),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        );

        final darkTheme = ThemeData(
          brightness: Brightness.dark,
          primarySwatch: _createMaterialColor(settings.primaryColor),
          cardColor: const Color(0xFF1E1E1E),
          scaffoldBackgroundColor: const Color(0xFF121212),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2C2C2C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        );

        // Determine theme mode from user settings
        AdaptiveThemeMode initialThemeMode;
        switch (settings.themeMode) {
          case 'dark':
            initialThemeMode = AdaptiveThemeMode.dark;
            break;
          case 'light':
            initialThemeMode = AdaptiveThemeMode.light;
            break;
          default:
            initialThemeMode = savedThemeMode ?? AdaptiveThemeMode.system;
        }

        return AdaptiveTheme(
          light: lightTheme,
          dark: darkTheme,
          initial: initialThemeMode,
          builder: (theme, darkTheme) => MaterialApp(
            title: 'In Out',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
            ],
            locale: Locale(settings.language),
            home: const AuthWrapper(),
          ),
        );
      },
    );
  }

  // Helper method to convert a Color to MaterialColor
  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
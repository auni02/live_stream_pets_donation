import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth/login_page.dart';
import 'widgets/bottom_nav.dart';
import 'theme/theme_controller.dart';
import 'localization/language_controller.dart';
import 'services/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🌙 LOAD SAVED DARK MODE
  final isDark = await UserPreferences.loadDarkMode();
  ThemeController.setTheme(isDark ? ThemeMode.dark : ThemeMode.light);

  // 🌐 LOAD SAVED LANGUAGE
  final savedLang = await UserPreferences.loadLanguage();
  if (savedLang != null) {
    LanguageController.setLanguage(savedLang);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageController.locale,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              locale: locale,

              // 🌤 LIGHT THEME
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFE6DDC8),
                cardColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.black,
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black),
                  bodyMedium: TextStyle(color: Colors.black),
                ),
              ),

              // 🌙 DARK CHOCOLATE THEME 🍫
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF2B1E15),
                cardColor: const Color(0xFF3A2A1D),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.black,
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black),
                  bodyMedium: TextStyle(color: Colors.black),
                ),
                switchTheme: SwitchThemeData(
                  thumbColor: MaterialStateProperty.all(
                    const Color(0xFF8D6E63),
                  ),
                  trackColor: MaterialStateProperty.all(
                    const Color(0xFF5D4037),
                  ),
                ),
              ),

              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const LoginPage();
                  }

                  return const BottomNav();
                },
              ),
            );
          },
        );
      },
    );
  }
}

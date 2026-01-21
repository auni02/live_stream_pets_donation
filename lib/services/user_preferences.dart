import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _langKey = 'language';
  static const String _darkModeKey = 'dark_mode';

  // 🌐 LANGUAGE
  static Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  static Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey);
  }

  // 🌙 DARK MODE
  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
}

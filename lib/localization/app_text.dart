class AppText {
  static const Map<String, Map<String, String>> values = {
    'en': {
      'settings': 'Settings',
      'dark_mode': 'Dark mode',
      'language': 'Language',
      'profile': 'Profile',
      'logout': 'Log Out',
      'edit_profile': 'Edit Profile',
    },
    'ms': {
      'settings': 'Tetapan',
      'dark_mode': 'Mod Gelap',
      'language': 'Bahasa',
      'profile': 'Profil',
      'logout': 'Log Keluar',
      'edit_profile': 'Edit Profil',
    },
  };

  static String text(String key, String lang) {
    return values[lang]?[key] ?? key;
  }
}

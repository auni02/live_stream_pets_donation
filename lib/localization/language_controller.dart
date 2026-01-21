import 'package:flutter/material.dart';

class LanguageController {
  static final ValueNotifier<Locale> locale =
      ValueNotifier(const Locale('en'));

  static void setLanguage(String code) {
    locale.value = Locale(code);
  }
}

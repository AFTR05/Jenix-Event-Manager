import 'package:flutter/material.dart';

class LanguagesApp {
  static List<Locale> availableLanguages = [
    const Locale('es'),
    const Locale('en')
  ];

  static Map<String, String> nameLanguages = {
    'es': "Español",
    'en': "English",
  };
}

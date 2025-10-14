import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeApp extends _$ThemeApp {
  @override
  ThemeMode build() => ThemeMode.system;

  void setTheme(ThemeMode mode) => state = mode;

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

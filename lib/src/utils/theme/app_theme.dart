import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class AppTheme {
  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: "OpenSansHebrewCondensed",
    
    primaryColor: JenixColorsApp.primaryRed,
    scaffoldBackgroundColor: JenixColorsApp.backgroundWhite,
    canvasColor: Colors.transparent,
    
    colorScheme: const ColorScheme.light(
      primary: JenixColorsApp.primaryRed,
      secondary: JenixColorsApp.primaryBlue,
      error: JenixColorsApp.errorColor,
      surface: JenixColorsApp.backgroundWhite,
      onPrimary: Colors.white,
      onSurface: JenixColorsApp.darkColorText,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: JenixColorsApp.primaryRed,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: "OpenSansHebrewCondensed",
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JenixColorsApp.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: JenixColorsApp.primaryRed,
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JenixColorsApp.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: JenixColorsApp.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: JenixColorsApp.primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: JenixColorsApp.errorColor),
      ),
    ),
    
    // Checkbox & Radio
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? JenixColorsApp.primaryRed
            : Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(JenixColorsApp.primaryRed),
    ),
    
    // Bottom Sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: JenixColorsApp.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  // ============================================================================
  // DARK THEME
  // ============================================================================
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: "OpenSansHebrewCondensed",
    
    primaryColor: JenixColorsApp.primaryRed,
    scaffoldBackgroundColor: JenixColorsApp.darkBackground,
    canvasColor: Colors.transparent,
    
    colorScheme: const ColorScheme.dark(
      primary: JenixColorsApp.primaryRed,
      secondary: JenixColorsApp.primaryBlue,
      error: JenixColorsApp.errorColor,
      surface: JenixColorsApp.darkGray,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: JenixColorsApp.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: "OpenSansHebrewCondensed",
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JenixColorsApp.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: JenixColorsApp.primaryRedLight,
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JenixColorsApp.darkGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: JenixColorsApp.grayColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: JenixColorsApp.primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: JenixColorsApp.errorColor),
      ),
    ),
    
    // Checkbox & Radio
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? JenixColorsApp.primaryRed
            : Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(JenixColorsApp.primaryRed),
    ),
    
    // Bottom Sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: JenixColorsApp.darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
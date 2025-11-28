import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class AppTheme {
  // ============================================================================
  // LIGHT THEME - ALEXANDER VON HUMBOLDT
  // ============================================================================
  
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: "OpenSansHebrewCondensed",
    
    primaryColor: JenixColorsApp.primaryBlue,              // Azul Humboldt
    scaffoldBackgroundColor: JenixColorsApp.backgroundWhite,
    canvasColor: Colors.transparent,
    
    colorScheme: const ColorScheme.light(
      primary: JenixColorsApp.primaryBlue,                 // Azul Humboldt
      secondary: JenixColorsApp.primaryRed,                // Rojo Humboldt
      tertiary: JenixColorsApp.primaryBlueLight,
      error: JenixColorsApp.errorColor,
      surface: JenixColorsApp.backgroundWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: JenixColorsApp.darkColorText,
      onError: Colors.white,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: JenixColorsApp.primaryBlue,         // Azul Humboldt
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: "OpenSansHebrewCondensed",
        letterSpacing: 0.3,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JenixColorsApp.buttonPrimary,     // Azul Humboldt
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),         // Menos redondeado
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: "OpenSansHebrewCondensed",
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: JenixColorsApp.primaryBlue,
        side: const BorderSide(
          color: JenixColorsApp.primaryBlue,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: JenixColorsApp.primaryBlue,       // Azul Humboldt
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: JenixColorsApp.buttonPrimary,       // Azul Humboldt
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JenixColorsApp.inputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),           // Consistente con botones
        borderSide: const BorderSide(
          color: JenixColorsApp.inputBorder,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.inputBorder,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.inputBorderFocus,          // Azul Humboldt
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.inputBorderError,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.inputBorderError,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(
        color: JenixColorsApp.subtitleColor,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        color: JenixColorsApp.placeholderColor,
        fontSize: 14,
      ),
    ),
    
    // Checkbox & Radio
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.primaryBlue;                // Azul Humboldt
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
        color: JenixColorsApp.inputBorder,
        width: 2,
      ),
    ),
    
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.primaryBlue;                // Azul Humboldt
        }
        return JenixColorsApp.inputBorder;
      }),
    ),
    
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return JenixColorsApp.lightGray;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.primaryBlue;                // Azul Humboldt
        }
        return JenixColorsApp.lightGrayBorder;
      }),
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: JenixColorsApp.dividerColor,
      thickness: 1,
      space: 1,
    ),
    
    // Bottom Sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: JenixColorsApp.backgroundWhite,
      modalBackgroundColor: JenixColorsApp.backgroundWhite,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Snackbar
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: JenixColorsApp.darkBackground,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: "OpenSansHebrewCondensed",
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    
    // Progress Indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: JenixColorsApp.primaryBlue,                    // Azul Humboldt
      circularTrackColor: JenixColorsApp.lightGrayBorder,
    ),
  );

  // ============================================================================
  // DARK THEME - ALEXANDER VON HUMBOLDT
  // ============================================================================
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: "OpenSansHebrewCondensed",
    
    primaryColor: JenixColorsApp.primaryBlueLight,          // Azul claro para dark
    scaffoldBackgroundColor: JenixColorsApp.darkBackground,
    canvasColor: Colors.transparent,
    
    colorScheme: const ColorScheme.dark(
      primary: JenixColorsApp.primaryBlueLight,             // Azul claro
      secondary: JenixColorsApp.primaryRedLight,            // Rojo claro
      tertiary: JenixColorsApp.primaryBlue,
      error: JenixColorsApp.errorColor,
      surface: JenixColorsApp.darkGray,
      onPrimary: JenixColorsApp.darkBackground,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: JenixColorsApp.darkGray,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: "OpenSansHebrewCondensed",
        letterSpacing: 0.3,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JenixColorsApp.primaryBlueLight,   // Azul claro
        foregroundColor: JenixColorsApp.darkBackground,     // Texto oscuro
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: "OpenSansHebrewCondensed",
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: JenixColorsApp.primaryBlueLight,
        side: const BorderSide(
          color: JenixColorsApp.primaryBlueLight,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: JenixColorsApp.primaryBlueLight,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: JenixColorsApp.primaryBlueLight,
      foregroundColor: JenixColorsApp.darkBackground,
      elevation: 4,
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JenixColorsApp.darkGray,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.grayColor,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.grayColor,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.primaryBlueLight,           // Azul claro
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.errorColor,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: JenixColorsApp.errorColor,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(
        color: JenixColorsApp.lightGray,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        color: JenixColorsApp.grayColor,
        fontSize: 14,
      ),
    ),
    
    // Checkbox & Radio
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.primaryBlueLight;           // Azul claro
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(JenixColorsApp.darkBackground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
        color: JenixColorsApp.grayColor,
        width: 2,
      ),
    ),
    
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.primaryBlueLight;           // Azul claro
        }
        return JenixColorsApp.grayColor;
      }),
    ),
    
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.darkBackground;
        }
        return JenixColorsApp.grayColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return JenixColorsApp.primaryBlueLight;           // Azul claro
        }
        return JenixColorsApp.darkGray;
      }),
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: JenixColorsApp.grayColor,
      thickness: 1,
      space: 1,
    ),
    
    // Bottom Sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: JenixColorsApp.darkGray,
      modalBackgroundColor: JenixColorsApp.darkGray,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Snackbar
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: JenixColorsApp.darkGray,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: "OpenSansHebrewCondensed",
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    
    // Progress Indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: JenixColorsApp.primaryBlueLight,               // Azul claro
      circularTrackColor: JenixColorsApp.grayColor,
    ),
  );
}
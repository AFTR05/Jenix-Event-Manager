import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jenix_event_manager/environment_config.dart';

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class JenixColorsApp {
  // ============================================================================
  // BRAND COLORS (Dynamic from Environment)
  // ============================================================================

  /// Color principal de la aplicación (Rojo Jenix #e20503)
  static final jenixAppColor = HexColor.fromHex(EnvironmentConfig.hexColor);

  /// Color inverso de la aplicación
  static final jenixAppColorInverse = HexColor.fromHex(
    EnvironmentConfig.hexColorInverse,
  );

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================

  /// Rojo principal Jenix
  static const Color primaryRed = Color(0xFFE20503);

  /// Rojo oscuro (hover/pressed states)
  static const Color primaryRedDark = Color(0xFFC00402);

  /// Rojo claro (disabled/light variant)
  static const Color primaryRedLight = Color(0xFFFF6B69);

  /// Azul primario
  static const Color primaryBlue = Color(0xFF247BC3);

  /// Azul oscuro
  static const Color primaryBlueDark = Color(0xFF1A5A8E);

  // ============================================================================
  // GRADIENT COLORS (Login Screen)
  // ============================================================================

  /// Inicio del gradiente del login (Rojo intenso)
  static const Color loginBeginGradient = Color(0xFFE20503);

  /// Fin del gradiente del login (Rojo más suave)
  static const Color loginEndGradient = Color(0xFFFF4D4A);

  /// Gradiente alternativo inicio
  static const Color gradientRedStart = Color(0xFFE20503);

  /// Gradiente alternativo fin
  static const Color gradientRedEnd = Color(0xFFFF8C8A);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Texto principal oscuro
  static const Color darkColorText = Color(0xFF1E1E1E);

  /// Texto rojo (para resaltar)
  static const Color textDarkColor = Color(0xFFE20503);

  /// Texto subtítulo (gris medio)
  static const Color subtitleColor = Color(0xFF5F5F5F);

  /// Texto secundario (gris claro)
  static const Color secondaryTextColor = Color(0xFF8E8E8E);

  /// Texto en hover
  static const Color hoverColorText = Color(0xFF617589);

  /// Texto placeholder
  static const Color placeholderColor = Color(0xFFB0B0B0);

  // ============================================================================
  // GRAY SCALE
  // ============================================================================

  /// Gris muy oscuro (fondos oscuros)
  static const Color darkBackground = Color(0xFF1E1E1E);

  /// Gris oscuro
  static const Color darkGray = Color(0xFF242425);

  /// Gris medio
  static const Color grayColor = Color(0xFF696969);

  /// Gris claro
  static const Color lightGray = Color(0xFFA6A1A1);

  /// Gris muy claro (bordes, divisores)
  static const Color lightGrayBorder = Color(0xFFE0E0E0);

  /// Gris iconos
  static const Color greyColorIcon = Color(0xFF707070);

  /// Gris pizarra (slate gray)
  static const Color slateGray = Color(0xFF64748B);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Fondo blanco principal
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// Fondo gris muy claro
  static const Color backgroundLightGray = Color(0xFFF5F5F5);

  /// Fondo gris claro (cards)
  static const Color backgroundGrayCard = Color(0xFFFAFAFA);

  /// Fondo oscuro
  static const Color backgroundDark = Color(0xFF1E1E1E);

  // ============================================================================
  // INPUT & FORM COLORS
  // ============================================================================

  /// Borde de input (normal)
  static const Color inputBorder = Color(0xFFE0E0E0);

  /// Borde de input (focus)
  static const Color inputBorderFocus = Color(0xFFE20503);

  /// Borde de input (error)
  static const Color inputBorderError = Color(0xFFDC2626);

  /// Fondo de input
  static const Color inputBackground = Color(0xFFFAFAFA);

  /// Fondo de input (focus)
  static const Color inputBackgroundFocus = Color(0xFFFFFFFF);

  // ============================================================================
  // SEMANTIC COLORS (Success, Warning, Error, Info)
  // ============================================================================

  /// Éxito (verde)
  static const Color successColor = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  /// Advertencia (amarillo/naranja)
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Error (rojo)
  static const Color errorColor = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  /// Información (azul)
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ============================================================================
  // UI ELEMENT COLORS
  // ============================================================================

  /// Color de divisores
  static const Color dividerColor = Color(0xFFE5E7EB);

  /// Color de sombras
  static const Color shadowColor = Color(0x1A000000);

  /// Color de overlay (modal/dialog)
  static const Color overlayColor = Color(0x80000000);

  /// Color de shimmer (loading)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============================================================================
  // BUTTON COLORS
  // ============================================================================

  /// Botón primario (rojo)
  static const Color buttonPrimary = Color(0xFFE20503);
  static const Color buttonPrimaryHover = Color(0xFFC00402);
  static const Color buttonPrimaryPressed = Color(0xFFA00301);
  static const Color buttonPrimaryDisabled = Color(0xFFFFB3B2);

  /// Botón secundario (azul)
  static const Color buttonSecondary = Color(0xFF247BC3);
  static const Color buttonSecondaryHover = Color(0xFF1A5A8E);

  /// Botón outlined
  static const Color buttonOutlined = Color(0xFFE20503);
  static const Color buttonOutlinedHover = Color(0xFFFEE2E2);

  /// Botón texto
  static const Color buttonText = Color(0xFF247BC3);
  static const Color buttonTextHover = Color(0xFF1A5A8E);

  // ============================================================================
  // SOCIAL COLORS (si necesitas login social)
  // ============================================================================

  static const Color googleColor = Color(0xFF4285F4);
  static const Color facebookColor = Color(0xFF1877F2);
  static const Color appleColor = Color(0xFF000000);
  static const Color microsoftColor = Color(0xFF00A4EF);

  // ============================================================================
  // SPECIALIZED COLORS
  // ============================================================================

  /// Océano azul
  static const Color blueOcean = Color(0xFF247BC3);

  /// Morado (si lo usas en algún lugar)
  static const Color purpleColor = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleDark = Color(0xFF7C3AED);

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Obtener color con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Versión clara de un color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Versión oscura de un color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

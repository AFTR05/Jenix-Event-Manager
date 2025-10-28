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
  // BRAND COLORS - ALEXANDER VON HUMBOLDT
  // ============================================================================

  /// Color principal de la universidad (Azul Humboldt)
  static const Color primaryBlue = Color(0xFF003A70); // Azul oscuro del logo

  /// Color secundario (Rojo Humboldt)
  static const Color primaryRed = Color(0xFFD32F2F); // Rojo del logo

  /// Azul más claro (variante)
  static const Color primaryBlueLight = Color(0xFF1565C0);

  /// Azul oscuro (hover/pressed states)
  static const Color primaryBlueDark = Color(0xFF002447);

  /// Rojo oscuro (hover/pressed states)
  static const Color primaryRedDark = Color(0xFFB71C1C);

  /// Rojo claro (disabled/light variant)
  static const Color primaryRedLight = Color(0xFFEF5350);

  // Dynamic colors from Environment (mantén compatibilidad)
  static final jenixAppColor = HexColor.fromHex(
    EnvironmentConfig.hexColor.isNotEmpty
        ? EnvironmentConfig.hexColor
        : '003A70', // Azul Humboldt por defecto
  );

  static final jenixAppColorInverse = HexColor.fromHex(
    EnvironmentConfig.hexColorInverse.isNotEmpty
        ? EnvironmentConfig.hexColorInverse
        : 'D32F2F', // Rojo Humboldt por defecto
  );

  // ============================================================================
  // GRADIENT COLORS (Login Screen)
  // ============================================================================

  /// Inicio del gradiente del login (Azul Humboldt)
  static const Color loginBeginGradient = Color(0xFF003A70);

  /// Fin del gradiente del login (Azul más claro)
  static const Color loginEndGradient = Color(0xFF1565C0);

  /// Gradiente alternativo inicio (Rojo)
  static const Color gradientRedStart = Color(0xFFD32F2F);

  /// Gradiente alternativo fin (Rojo claro)
  static const Color gradientRedEnd = Color(0xFFEF5350);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Texto principal oscuro (Azul Humboldt)
  static const Color darkColorText = Color(0xFF003A70);

  /// Texto destacado (Rojo Humboldt)
  static const Color textDarkColor = Color(0xFFD32F2F);

  /// Texto subtítulo (gris medio)
  static const Color subtitleColor = Color(0xFF5F6368);

  /// Texto secundario (gris claro)
  static const Color secondaryTextColor = Color(0xFF80868B);

  /// Texto en hover (Azul medio)
  static const Color hoverColorText = Color(0xFF1565C0);

  /// Texto placeholder
  static const Color placeholderColor = Color(0xFF9AA0A6);

  // ============================================================================
  // GRAY SCALE
  // ============================================================================

  /// Gris muy oscuro (fondos oscuros)
  static const Color darkBackground = Color(0xFF202124);

  /// Gris oscuro
  static const Color darkGray = Color(0xFF3C4043);

  /// Gris medio
  static const Color grayColor = Color(0xFF5F6368);

  /// Gris claro
  static const Color lightGray = Color(0xFF9AA0A6);

  /// Gris muy claro (bordes, divisores)
  static const Color lightGrayBorder = Color(0xFFDADCE0);

  /// Gris iconos
  static const Color greyColorIcon = Color(0xFF5F6368);

  /// Gris pizarra (slate gray)
  static const Color slateGray = Color(0xFF80868B);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Fondo blanco principal
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// Fondo gris muy claro
  static const Color backgroundLightGray = Color(0xFFF8F9FA);

  /// Fondo gris claro (cards)
  static const Color backgroundGrayCard = Color(0xFFF1F3F4);

  /// Fondo oscuro
  static const Color backgroundDark = Color(0xFF202124);

  // ============================================================================
  // INPUT & FORM COLORS
  // ============================================================================

  /// Borde de input (normal)
  static const Color inputBorder = Color(0xFFDADCE0);

  /// Borde de input (focus) - Azul Humboldt
  static const Color inputBorderFocus = Color(0xFF003A70);

  /// Borde de input (error) - Rojo Humboldt
  static const Color inputBorderError = Color(0xFFD32F2F);

  /// Fondo de input
  static const Color inputBackground = Color(0xFFF8F9FA);

  /// Fondo de input (focus)
  static const Color inputBackgroundFocus = Color(0xFFFFFFFF);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Éxito (verde)
  static const Color successColor = Color(0xFF0F9D58);
  static const Color successLight = Color(0xFFE6F4EA);
  static const Color successDark = Color(0xFF0B8043);

  /// Advertencia (amarillo/naranja)
  static const Color warningColor = Color(0xFFF9AB00);
  static const Color warningLight = Color(0xFFFEF7E0);
  static const Color warningDark = Color(0xFFE37400);

  /// Error (rojo Humboldt)
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFCE8E6);
  static const Color errorDark = Color(0xFFB71C1C);

  /// Información (azul Humboldt)
  static const Color infoColor = Color(0xFF003A70);
  static const Color infoLight = Color(0xFFE8F0FE);
  static const Color infoDark = Color(0xFF002447);

  // ============================================================================
  // UI ELEMENT COLORS
  // ============================================================================

  /// Color de divisores
  static const Color dividerColor = Color(0xFFDADCE0);

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

  /// Botón primario (Azul Humboldt)
  static const Color buttonPrimary = Color(0xFF003A70);
  static const Color buttonPrimaryHover = Color(0xFF002447);
  static const Color buttonPrimaryPressed = Color(0xFF001830);
  static const Color buttonPrimaryDisabled = Color(0xFFB3C7D6);

  /// Botón secundario (Rojo Humboldt)
  static const Color buttonSecondary = Color(0xFFD32F2F);
  static const Color buttonSecondaryHover = Color(0xFFB71C1C);
  static const Color buttonSecondaryPressed = Color(0xFF9A0007);
  static const Color buttonSecondaryDisabled = Color(0xFFE57373);

  /// Botón outlined (Azul)
  static const Color buttonOutlined = Color(0xFF003A70);
  static const Color buttonOutlinedHover = Color(0xFFE8F0FE);

  /// Botón texto (Azul)
  static const Color buttonText = Color(0xFF003A70);
  static const Color buttonTextHover = Color(0xFF002447);

  // ============================================================================
  // SOCIAL COLORS
  // ============================================================================

  static const Color googleColor = Color(0xFF4285F4);
  static const Color facebookColor = Color(0xFF1877F2);
  static const Color appleColor = Color(0xFF000000);
  static const Color microsoftColor = Color(0xFF00A4EF);

  // ============================================================================
  // SPECIALIZED COLORS
  // ============================================================================

  /// Océano azul (Azul Humboldt)
  static const Color blueOcean = Color(0xFF003A70);

  /// Morado (si lo necesitas)
  static const Color purpleColor = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleDark = Color(0xFF7C3AED);

  static const Color primaryColor = Color(0xFF103e69);
  static const Color accentColor = Color(0xFFbe1723);
  static const Color backgroundColor = Color(0xFF0d1b2a);
  static const Color surfaceColor = Color(0xFF1b263b);

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

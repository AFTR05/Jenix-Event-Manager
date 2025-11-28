import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/widgets/profile_header.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/widgets/profile_menu.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/widgets/theme_switch_button.dart';

/// ProfileScreen - Alexander von Humboldt Event Manager
/// [ProfileScreen] representa la pantalla principal de perfil de usuario.
///
/// Muestra el encabezado del perfil, el menú de opciones y el switch de tema,
/// adaptando su color y estilo según el tema oscuro/claro.
class ProfileScreen extends StatelessWidget {
  /// Constructor de ProfileScreen.
  const ProfileScreen({super.key});

  /// Calcula el tamaño responsivo de fuente
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.85;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    // Detecta si el modo oscuro está activo.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define el color de fondo de la pantalla según el modo.
    final backgroundColor = isDark 
        ? JenixColorsApp.darkBackground 
        : JenixColorsApp.backgroundLightGray;
    
    // Define el color para el título según el modo.
    final titleColor = isDark 
        ? JenixColorsApp.primaryBlueLight 
        : JenixColorsApp.primaryBlue;
    
    // Define el color para los textos según el modo.
    final textColor = isDark 
        ? JenixColorsApp.backgroundWhite 
        : JenixColorsApp.darkColorText;
    
    // Define el color para los iconos según el modo.
    final iconColor = isDark 
        ? JenixColorsApp.primaryBlueLight 
        : JenixColorsApp.primaryBlue;

    // Tamaño responsivo del título del AppBar
    final titleFontSize = _getResponsiveFontSize(context, 20);

    // Estructura principal de la pantalla: Scaffold con AppBar y cuerpo.
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        // Título de la pantalla de perfil.
        title: Text(
          LocaleKeys.profileTitle.tr(),
          style: TextStyle(
            fontFamily: 'OpenSansHebrew',
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: titleFontSize,
            letterSpacing: -0.5,
          ),
        ),
      ),
      // Contenido del cuerpo: encabezado, menú y switch de tema.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado del perfil: foto, nombre, email, role.
            ProfileHeader(
              textColor: textColor,
            ),
            
            const SizedBox(height: 8),
            
            // Switch para cambiar el tema de la aplicación
            const ThemeSwitchButton(),
            
            const SizedBox(height: 8),
            
            // Menú de opciones de perfil.
            ProfileMenu(
              textColor: textColor,
              iconColor: iconColor,
            ),
            
            // Espacio adicional al final
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
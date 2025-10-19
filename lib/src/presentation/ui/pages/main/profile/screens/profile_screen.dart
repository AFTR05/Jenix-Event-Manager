import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
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
          'Mi Perfil',
          style: TextStyle(
            fontFamily: 'OpenSansHebrew',
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
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
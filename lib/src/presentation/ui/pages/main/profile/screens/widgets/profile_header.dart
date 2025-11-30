
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/role_enum.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

/// ProfileHeader - Alexander von Humboldt Event Manager
/// Header del perfil con avatar y nombre del usuario
class ProfileHeader extends ConsumerWidget {
  final Color? textColor;

  const ProfileHeader({super.key, this.textColor});

  /// Calcula el tamaño responsivo de fuente
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.85;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  /// Calcula el radio responsivo del avatar
  double _getResponsiveAvatarRadius(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 40;
    if (screenWidth < 600) return 56;
    if (screenWidth < 900) return 64;
    return 72;
  }

  /// Calcula el tamaño responsivo del icono del avatar
  double _getResponsiveIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 40;
    if (screenWidth < 600) return 56;
    if (screenWidth < 900) return 64;
    return 72;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Obtener el usuario actual del loginProvider
    final user = ref.watch(loginProviderProvider);
    final userName = user?.name ?? 'Guest User';
    final userEmail = user?.email ?? '';

    // Color de texto (usa el proporcionado o el del tema)
    final effectiveTextColor = textColor ?? 
        (isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText);

    // Tamaños responsivos
    final avatarRadius = _getResponsiveAvatarRadius(context);
    final iconSize = _getResponsiveIconSize(context);
    final nameFontSize = _getResponsiveFontSize(context, 22);
    final emailFontSize = _getResponsiveFontSize(context, 14);
    final roleFontSize = _getResponsiveFontSize(context, 11);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Avatar con colores Jenix
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        JenixColorsApp.primaryBlueLight,
                        JenixColorsApp.primaryBlue,
                      ]
                    : [
                        JenixColorsApp.primaryBlue,
                        JenixColorsApp.primaryBlueDark,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark 
                      ? JenixColorsApp.primaryBlueLight 
                      : JenixColorsApp.primaryBlue).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: avatarRadius + 4,
              backgroundColor: Colors.transparent,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isDark 
                    ? JenixColorsApp.darkBackground 
                    : JenixColorsApp.backgroundWhite,
                child: Icon(
                  Icons.person,
                  color: isDark 
                      ? JenixColorsApp.primaryBlueLight 
                      : JenixColorsApp.primaryBlue,
                  size: iconSize,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nombre del usuario
          Text(
            userName,
            style: TextStyle(
              fontFamily: 'OpenSansHebrew',
              fontWeight: FontWeight.w700,
              fontSize: nameFontSize,
              color: effectiveTextColor,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // Email del usuario
          if (userEmail.isNotEmpty)
            Text(
              userEmail,
              style: TextStyle(
                fontFamily: 'OpenSansHebrew',
                fontWeight: FontWeight.w400,
                fontSize: emailFontSize,
                color: effectiveTextColor.withOpacity(0.7),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 8),
          
          // Role badge (si existe)
          if (user?.role != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark 
                    ? JenixColorsApp.primaryBlueLight 
                    : JenixColorsApp.primaryBlue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark 
                      ? JenixColorsApp.primaryBlueLight 
                      : JenixColorsApp.primaryBlue,
                  width: 1,
                ),
              ),
              child: Text(
                user!.role.displayName,
                style: TextStyle(
                  fontFamily: 'OpenSansHebrew',
                  fontWeight: FontWeight.w600,
                  fontSize: roleFontSize,
                  color: isDark 
                      ? JenixColorsApp.primaryBlueLight 
                      : JenixColorsApp.primaryBlue,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
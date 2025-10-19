import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// LogoutConfirmationDialog - Alexander von Humboldt Event Manager
/// Modal bottom sheet para confirmar el cierre de sesión del usuario
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? JenixColorsApp.darkBackground : JenixColorsApp.backgroundWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: JenixColorsApp.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual del modal
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark 
                  ? JenixColorsApp.lightGray 
                  : JenixColorsApp.lightGrayBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Icono de advertencia
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: JenixColorsApp.errorColor.withOpacity(0.12),
            ),
            child: Icon(
              PhosphorIconsBold.signOut,
              size: 36,
              color: JenixColorsApp.errorColor,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Título
          Text(
            '¿Cerrar Sesión?',
            style: TextStyle(
              fontFamily: 'OpenSansHebrew',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark 
                  ? JenixColorsApp.backgroundWhite 
                  : JenixColorsApp.darkColorText,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Descripción
          Text(
            'Estás a punto de cerrar tu sesión en Alexander von Humboldt Event Manager. Tendrás que iniciar sesión nuevamente para acceder.',
            style: TextStyle(
              fontFamily: 'OpenSansHebrew',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: isDark 
                  ? JenixColorsApp.lightGray 
                  : JenixColorsApp.subtitleColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Botones
          Row(
            children: [
              // Botón Cancelar
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDark 
                          ? JenixColorsApp.primaryBlueLight 
                          : JenixColorsApp.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: isDark 
                        ? JenixColorsApp.primaryBlueLight 
                        : JenixColorsApp.primaryBlue,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontFamily: 'OpenSansHebrew',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Botón Cerrar Sesión
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: JenixColorsApp.errorColor,
                    foregroundColor: JenixColorsApp.backgroundWhite,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontFamily: 'OpenSansHebrew',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Espacio adicional para SafeArea en bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

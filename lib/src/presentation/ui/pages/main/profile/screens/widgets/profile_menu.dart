import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/dialogs/logout_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/presentation/controllers/auth/authentication_controller.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

/// Modelo que representa un elemento individual del menú de perfil.
///
/// Contiene etiqueta, icono (u asset), ruta para navegación y bandera para logout.
class ProfileMenuItem {
  /// Texto que describe el ítem del menú.
  final String label;

  /// Icono de tipo [IconData] para mostrar en el menú (opcional).
  final IconData? icon;

  /// Ruta al asset de imagen o SVG para el icono (opcional).
  final String? iconAsset;

  /// Nombre de la ruta para navegación al pulsar el ítem (opcional).
  final String? route;

  /// Indicador si el ítem es para cerrar sesión.
  final bool isLogout;

  /// Constructor de ProfileMenuItem con parámetros opcionales.
  const ProfileMenuItem({
    required this.label,
    this.icon,
    this.iconAsset,
    this.route,
    this.isLogout = false,
  });
}

/// Widget con diseño para mostrar un ítem del menú de perfil.
///
/// Incluye icono o asset, texto y manejo de pulsación.
class ProfileMenuTile extends ConsumerWidget {
  /// Elemento que contiene datos para mostrar.
  final ProfileMenuItem item;

  /// Color del texto mostrado.
  final Color textColor;

  /// Color del icono mostrado.
  final Color iconColor;

  /// Constructor con elementos requeridos.
  const ProfileMenuTile({
    super.key,
    required this.item,
    required this.textColor,
    required this.iconColor,
  });

  /// Muestra un modal para confirmar el cierre de sesión.
  ///
  /// Si se confirma, ejecuta logout y navega a la pantalla de login eliminando el historial.
  Future<void> _showLogoutBottomSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor:
          (isDark
                  ? JenixColorsApp.primaryBlueLight
                  : JenixColorsApp.primaryBlue)
              .withOpacity(0.8),
      builder: (_) => const LogoutConfirmationDialog(),
    );

    if (confirmed == true && context.mounted) {
      // Ejecutar logout usando el AuthenticationController
      final authController = ref.read(authenticationControllerProvider);
      final logOutResult = await authController.logOut();

      if (context.mounted) {
        if (logOutResult.isRight && logOutResult.right) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesApp.login,
            (route) => false,
          );
        } else if (logOutResult.isLeft) {
          // Mostrar error si el logout falló
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al cerrar sesión. Intenta nuevamente.',
                style: const TextStyle(
                  fontFamily: 'OpenSansHebrew',
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: JenixColorsApp.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.backgroundWhite,
        border: Border.all(
          color: isDark
              ? JenixColorsApp.primaryBlueLight.withOpacity(0.1)
              : JenixColorsApp.primaryBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: JenixColorsApp.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (item.isLogout) {
              _showLogoutBottomSheet(context, ref);
            } else if (item.route != null) {
              Navigator.pushNamed(context, item.route!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: item.isLogout
                        ? LinearGradient(
                            colors: [
                              JenixColorsApp.errorColor.withOpacity(0.15),
                              JenixColorsApp.errorColor.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              iconColor.withOpacity(0.15),
                              iconColor.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  ),
                  child: Center(
                    // Muestra icono según asset SVG o imagen, o icono normal.
                    child: item.iconAsset != null
                        ? (item.iconAsset!.endsWith('.svg')
                              ? SvgPicture.asset(
                                  item.iconAsset!,
                                  width: 22,
                                  height: 22,
                                  colorFilter: ColorFilter.mode(
                                    item.isLogout
                                        ? JenixColorsApp.errorColor
                                        : iconColor,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Image.asset(
                                  item.iconAsset!,
                                  width: 22,
                                  height: 22,
                                  color: item.isLogout
                                      ? JenixColorsApp.errorColor
                                      : iconColor,
                                ))
                        : Icon(
                            item.icon,
                            color: item.isLogout
                                ? JenixColorsApp.errorColor
                                : iconColor,
                            size: 22,
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Texto
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'OpenSansHebrew',
                      fontSize: 16,
                      color: item.isLogout
                          ? JenixColorsApp.errorColor
                          : textColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                // Icono de flecha (si no es logout)
                if (!item.isLogout)
                  Icon(
                    PhosphorIconsBold.caretRight,
                    color:
                        (isDark
                                ? JenixColorsApp.primaryBlueLight
                                : JenixColorsApp.primaryBlue)
                            .withOpacity(0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que construye la lista de ítems del menú de perfil.
///
/// Los colores de texto e icono se reciben como parámetros para temas.
class ProfileMenu extends StatelessWidget {
  /// Color del texto en elementos de menú.
  final Color textColor;

  /// Color del icono en elementos de menú.
  final Color iconColor;

  /// Constructor con parámetros obligatorios.
  const ProfileMenu({
    super.key,
    required this.textColor,
    required this.iconColor,
  });

  /// Lista estática de ítems que componen el menú.
  List<ProfileMenuItem> get menuItems => [
    ProfileMenuItem(
      label: 'Editar Perfil',
      iconAsset: 'assets/images/icons/user_edit_icon.svg',
      route: RoutesApp.editProfile,
    ),
    ProfileMenuItem(
      label: 'Mis Eventos',
      iconAsset: 'assets/images/icons/calendar_icon.svg',
      route: RoutesApp.myEvents,
    ),
    ProfileMenuItem(
      label: 'Notificaciones',
      iconAsset: 'assets/images/icons/message_heart_icon.svg',
      route: RoutesApp.notifications,
    ),
    ProfileMenuItem(
      label: 'Compartir App',
      iconAsset: 'assets/images/icons/share_icon.svg',
      route: RoutesApp.share,
    ),
    ProfileMenuItem(
      label: 'Ayuda y Soporte',
      iconAsset: 'assets/images/icons/chat_icon.svg',
      route: RoutesApp.help,
    ),
    const ProfileMenuItem(
      label: 'Cerrar Sesión',
      iconAsset: 'assets/images/icons/logout_icon.svg',
      isLogout: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ProfileMenuTile(
          item: item,
          textColor: textColor,
          iconColor: iconColor,
        );
      },
    );
  }
}

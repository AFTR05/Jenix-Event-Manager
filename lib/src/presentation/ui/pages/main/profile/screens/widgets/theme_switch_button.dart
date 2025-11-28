import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/src/inject/states_providers/app_states/theme_provider.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ThemeSwitchButton - Alexander von Humboldt Event Manager
/// Botón para cambiar el tema de la aplicación entre modo oscuro y claro.
///
/// Utiliza Riverpod para acceder y modificar el estado actual del tema.
class ThemeSwitchButton extends ConsumerWidget {
  /// Constructor del widget.
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Detecta si el tema actual es oscuro.
    final isDarkmode = Theme.of(context).brightness == Brightness.dark;

    // Color de la tarjeta según el modo.
    final cardColor = isDarkmode 
        ? JenixColorsApp.darkGray.withOpacity(0.3)
        : JenixColorsApp.backgroundWhite;
    
    // Color del texto del título según el modo.
    final textColor = isDarkmode 
        ? JenixColorsApp.backgroundWhite 
        : JenixColorsApp.darkColorText;

    // Color del icono según el modo
    final iconColor = isDarkmode 
        ? JenixColorsApp.primaryBlueLight 
        : JenixColorsApp.primaryBlue;

    // Icono que representa el tema actual (oscuro o claro).
    final themeIcon = isDarkmode 
        ? PhosphorIconsBold.moon 
        : PhosphorIconsBold.sun;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkmode 
                ? JenixColorsApp.primaryBlueLight.withOpacity(0.1)
                : JenixColorsApp.primaryBlue.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: JenixColorsApp.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.12),
            ),
            child: Icon(
              themeIcon, 
              color: iconColor, 
              size: 22,
            ),
          ),
          title: Text(
            isDarkmode ? LocaleKeys.themeDarkLabel.tr() : LocaleKeys.themeLightLabel.tr(),
            style: TextStyle(
              fontFamily: 'OpenSansHebrew',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          trailing: Switch(
            value: isDarkmode,
            activeColor: JenixColorsApp.backgroundWhite,
            activeTrackColor: isDarkmode 
                ? JenixColorsApp.primaryBlueLight 
                : JenixColorsApp.primaryBlue,
            inactiveThumbColor: JenixColorsApp.backgroundWhite,
            inactiveTrackColor: JenixColorsApp.lightGray,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return isDarkmode 
                    ? JenixColorsApp.primaryBlueLight 
                    : JenixColorsApp.primaryBlue;
              }
              return JenixColorsApp.lightGrayBorder;
            }),
            // Cambia el tema al alternar el switch usando Riverpod.
            onChanged: (value) {
              ref
                  .read(themeAppProvider.notifier)
                  .setTheme(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}
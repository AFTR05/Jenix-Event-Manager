import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class CustomButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isLoading;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;
  final bool isOutlined;
  final Color? backgroundColor;  // Nuevo: color personalizable
  final Color? foregroundColor;  // Nuevo: color de texto personalizable

  const CustomButtonWidget({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;

        // Adaptive dimensions
        final buttonHeight = height ??
            (isMobile
                ? 48.0
                : isTablet
                    ? 52.0
                    : 56.0);

        final textSize = fontSize ??
            (isMobile
                ? 14.0
                : isTablet
                    ? 15.0
                    : 16.0);

        final buttonWidth = width ?? double.infinity;

        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: isOutlined 
              ? _buildOutlinedButton(textSize) 
              : _buildFilledButton(textSize),
        );
      },
    );
  }

  Widget _buildFilledButton(double textSize) {
    // Color por defecto: Azul Humboldt (buttonPrimary)
    final bgColor = backgroundColor ?? JenixColorsApp.buttonPrimary;
    final fgColor = foregroundColor ?? JenixColorsApp.backgroundWhite;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
        disabledForegroundColor: fgColor.withValues(alpha: 0.7),
        elevation: 0,
        shadowColor: JenixColorsApp.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Menos redondeado para look profesional
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ).copyWith(
        // Efecto hover para web/desktop
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return JenixColorsApp.backgroundWhite.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return JenixColorsApp.backgroundWhite.withValues(alpha: 0.2);
            }
            return null;
          },
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: textSize + 4),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'OpenSansHebrew',
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSansHebrew',
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
    );
  }

  Widget _buildOutlinedButton(double textSize) {
    // Color por defecto: Azul Humboldt para outlined
    final borderColor = backgroundColor ?? JenixColorsApp.buttonPrimary;
    final textColor = foregroundColor ?? JenixColorsApp.buttonPrimary;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(
          color: borderColor,
          width: 2,
        ),
        disabledForegroundColor: textColor.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ).copyWith(
        // Efecto hover para outlined button
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return borderColor.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.pressed)) {
              return borderColor.withValues(alpha: 0.12);
            }
            return Colors.transparent;
          },
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                color: borderColor.withValues(alpha: 0.3),
                width: 2,
              );
            }
            return BorderSide(
              color: borderColor,
              width: 2,
            );
          },
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: textSize + 4),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'OpenSansHebrew',
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSansHebrew',
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
    );
  }
}
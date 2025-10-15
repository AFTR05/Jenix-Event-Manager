import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

/// Widget reutilizable para elementos de formulario con label y contenedor
/// 
/// **Autor:** AFTR05
/// **Última modificación:** 2025-10-15 20:06:31 UTC
/// **Versión:** 2.0.0
class CustomFormElement extends StatelessWidget {
  final Widget widget;
  final String labelTitle;
  final double? spacing;
  final bool isRequired;
  final Color? labelColor;
  final double? labelFontSize;
  final String? errorText;

  const CustomFormElement({
    super.key,
    required this.widget,
    required this.labelTitle,
    this.spacing,
    this.isRequired = false,
    this.labelColor,
    this.labelFontSize,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;

        final defaultLabelSize = isMobile ? 14.0 : 16.0;
        final finalLabelSize = labelFontSize ?? defaultLabelSize;
        final finalSpacing = spacing ?? (isMobile ? 6.0 : 8.0);

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = labelColor ??
            (isDark
                ? JenixColorsApp.backgroundWhite
                : JenixColorsApp.darkColorText);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            _buildLabel(textColor, finalLabelSize),

            SizedBox(height: finalSpacing),

            // Form widget container with focus
            _buildFormContainer(isDark),

            // Error message
            if (errorText != null) ...[
              const SizedBox(height: 8),
              _buildErrorText(finalLabelSize),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLabel(Color textColor, double fontSize) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: textColor,
          fontFamily: "OpenSansHebrew",
        ),
        children: [
          TextSpan(text: labelTitle),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: JenixColorsApp.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormContainer(bool isDark) {
    final hasError = errorText != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark
            ? JenixColorsApp.darkGray
            : JenixColorsApp.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? JenixColorsApp.inputBorderError
              : (isDark
                  ? JenixColorsApp.grayColor
                  : JenixColorsApp.inputBorder),
          width: 1.5,
        ),
      ),
      child: widget,
    );
  }

  Widget _buildErrorText(double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: fontSize + 2,
            color: JenixColorsApp.errorColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText!,
              style: TextStyle(
                color: JenixColorsApp.errorColor,
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w500,
                fontFamily: 'OpenSansHebrew',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
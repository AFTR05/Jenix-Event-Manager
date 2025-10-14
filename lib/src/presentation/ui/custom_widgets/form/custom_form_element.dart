import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

/// Widget reutilizable para elementos de formulario con label y contenedor
/// 
/// Características:
/// - Label con estilo configurable
/// - Contenedor con fondo sutil
/// - Soporte para tema claro/oscuro
/// - Responsive
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomFormElement(
///   labelTitle: "Email",
///   widget: TextFormField(...),
/// )
/// ```
class CustomFormElement extends StatelessWidget {
  /// Widget del formulario (TextFormField, DropdownButton, etc.)
  final Widget widget;
  
  /// Título/label que se muestra arriba del campo
  final String labelTitle;
  
  /// Espaciado entre el label y el widget (por defecto 8px)
  final double? spacing;
  
  /// Si debe mostrar un asterisco de campo requerido
  final bool isRequired;
  
  /// Color personalizado para el label (opcional)
  final Color? labelColor;
  
  /// Tamaño de fuente del label (opcional)
  final double? labelFontSize;

  const CustomFormElement({
    super.key,
    required this.widget,
    required this.labelTitle,
    this.spacing,
    this.isRequired = false,
    this.labelColor,
    this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;
        
        // Responsive sizing
        final defaultLabelSize = isMobile ? 14.0 : 16.0;
        final finalLabelSize = labelFontSize ?? defaultLabelSize;
        final finalSpacing = spacing ?? (isMobile ? 6.0 : 8.0);

        // Theme detection
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = labelColor ?? 
            (isDark ? Colors.white : JenixColorsApp.darkColorText);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            _buildLabel(textColor, finalLabelSize),
            
            SizedBox(height: finalSpacing),
            
            // Form widget container
            _buildFormContainer(),
          ],
        );
      },
    );
  }

  /// Construye el label con estilo
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

  /// Construye el contenedor del widget de formulario
  Widget _buildFormContainer() {
    return Container(
      decoration: BoxDecoration(
        color: JenixColorsApp.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: JenixColorsApp.inputBorder,
          width: 1,
        ),
      ),
      child: widget,
    );
  }
}
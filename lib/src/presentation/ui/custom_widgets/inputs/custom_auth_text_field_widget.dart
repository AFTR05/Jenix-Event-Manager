import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

/// Campo de texto personalizado para formularios de autenticación
/// 
/// Características:
/// - Soporte para validación
/// - Modo password con toggle visibility
/// - Bordes redondeados configurables
/// - Prefijos y sufijos personalizables
/// - Formateo de entrada (InputFormatter)
/// - Responsive
/// - Soporte para tema claro/oscuro
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomAuthTextFieldWidget(
///   hintText: "Enter your email",
///   controller: _emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
/// )
/// ```
class CustomAuthTextFieldWidget extends StatefulWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;
  
  /// Texto de ayuda (placeholder)
  final String hintText;
  
  /// Tipo de teclado
  final TextInputType? keyboardType;
  
  /// Si es un campo de contraseña (muestra/oculta texto)
  final bool isPasswordField;
  
  /// Widget personalizado para el prefijo
  final Widget? prefix;
  
  /// Widget personalizado para el sufijo
  final Widget? suffix;
  
  /// Función de validación
  final String? Function(String?)? validator;
  
  /// Formateador de entrada (ej: máscaras)
  final TextInputFormatter? pattern;
  
  /// Borde personalizado del contenedor
  final BoxBorder? boxBorder;
  
  /// Si tiene borde redondeado arriba (deprecated, usar borderRadius)
  @Deprecated('Use borderRadius instead')
  final bool isTop;
  
  /// Si tiene borde redondeado abajo (deprecated, usar borderRadius)
  @Deprecated('Use borderRadius instead')
  final bool isBottom;
  
  /// Radio de borde personalizado (reemplaza isTop/isBottom)
  final BorderRadius? borderRadius;
  
  /// Color del borde
  final Color? borderColor;
  
  /// Color del texto
  final Color? textColor;
  
  /// Acción del teclado (done, next, etc.)
  final TextInputAction? textInputAction;
  
  /// Callback cuando se presiona enter/done
  final Function(String)? onFieldSubmitted;
  
  /// Si el campo está habilitado
  final bool enabled;
  
  /// Texto de error a mostrar
  final String? errorText;
  
  /// Auto focus
  final bool autofocus;

  const CustomAuthTextFieldWidget({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.isPasswordField = false,
    this.prefix,
    this.suffix,
    this.validator,
    this.pattern,
    this.boxBorder,
    @Deprecated('Use borderRadius instead') this.isTop = false,
    @Deprecated('Use borderRadius instead') this.isBottom = false,
    this.borderRadius,
    this.borderColor,
    this.textColor,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.errorText,
    this.autofocus = false,
  });

  @override
  State<CustomAuthTextFieldWidget> createState() =>
      _CustomAuthTextFieldWidgetState();
}

class _CustomAuthTextFieldWidgetState extends State<CustomAuthTextFieldWidget> {
  bool _obscurePassword = true;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;

        // Responsive sizing
        final fontSize = isMobile ? 14.0 : 16.0;
        final horizontalPadding = isMobile ? 16.0 : 20.0;
        final verticalPadding = isMobile ? 12.0 : 16.0;

        // Theme detection
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              isDark,
              fontSize,
              horizontalPadding,
              verticalPadding,
            ),
            if (widget.errorText != null) ...[
              const SizedBox(height: 6),
              _buildErrorText(fontSize),
            ],
          ],
        );
      },
    );
  }

  /// Construye el campo de texto principal
  Widget _buildTextField(
    bool isDark,
    double fontSize,
    double horizontalPadding,
    double verticalPadding,
  ) {
    final borderColor = _getBorderColor(isDark);
    final borderRadius = _getBorderRadius();

    return Container(
      decoration: BoxDecoration(
        color: _isFocused
            ? JenixColorsApp.inputBackgroundFocus
            : JenixColorsApp.inputBackground,
        borderRadius: borderRadius,
        border: widget.boxBorder ??
            Border.all(
              color: _isFocused
                  ? JenixColorsApp.inputBorderFocus
                  : (widget.errorText != null
                      ? JenixColorsApp.inputBorderError
                      : borderColor),
              width: _isFocused ? 2 : 1,
            ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: JenixColorsApp.primaryRed.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPasswordField ? _obscurePassword : false,
        inputFormatters: widget.pattern != null ? [widget.pattern!] : null,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onFieldSubmitted,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: widget.textColor ??
              (isDark ? Colors.white : JenixColorsApp.darkColorText),
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: JenixColorsApp.placeholderColor,
            fontSize: fontSize,
          ),
          prefixIcon: _buildPrefixIcon(),
          suffixIcon: _buildSuffixIcon(),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
        ),
      ),
    );
  }

  /// Construye el icono de prefijo
  Widget? _buildPrefixIcon() {
    if (widget.isPasswordField) {
      return IconButton(
        icon: Icon(
          _obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined,
          size: 20,
          color: JenixColorsApp.greyColorIcon,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      );
    }
    return widget.prefix;
  }

  /// Construye el icono de sufijo
  Widget? _buildSuffixIcon() {
    return widget.suffix;
  }

  /// Construye el mensaje de error
  Widget _buildErrorText(double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: fontSize,
            color: JenixColorsApp.errorColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: JenixColorsApp.errorColor,
                fontSize: fontSize - 2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color del borde según el tema
  Color _getBorderColor(bool isDark) {
    if (widget.borderColor != null) return widget.borderColor!;
    return isDark ? Colors.white : JenixColorsApp.inputBorder;
  }

  /// Obtiene el radio de borde
  BorderRadius _getBorderRadius() {
    // Priorizar borderRadius personalizado
    if (widget.borderRadius != null) return widget.borderRadius!;

    // Fallback a los parámetros deprecated
    if (widget.isTop) {
      return const BorderRadius.only(topRight: Radius.circular(30));
    }
    if (widget.isBottom) {
      return const BorderRadius.only(bottomRight: Radius.circular(30));
    }

    // Por defecto: bordes redondeados suaves
    return BorderRadius.circular(8);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

/// Campo de texto personalizado para formularios de autenticación
/// 
/// **Autor:** AFTR05
/// **Última modificación:** 2025-10-15 19:57:43 UTC
/// **Versión:** 1.0.0
class CustomAuthTextFieldWidget extends StatefulWidget {
  // ============================================================================
  // REQUIRED PARAMETERS
  // ============================================================================
  
  final TextEditingController controller;
  final String hintText;
  
  // ============================================================================
  // OPTIONAL PARAMETERS - INPUT CONFIGURATION
  // ============================================================================
  
  final TextInputType? keyboardType;
  final bool isPasswordField;
  final TextInputAction? textInputAction;
  final TextInputFormatter? pattern;
  final bool enabled;
  final bool autofocus;
  
  // ============================================================================
  // OPTIONAL PARAMETERS - VALIDATION
  // ============================================================================
  
  final String? Function(String?)? validator;
  final String? errorText;
  
  // ============================================================================
  // OPTIONAL PARAMETERS - STYLING
  // ============================================================================
  
  final Widget? prefix;
  final Widget? suffix;
  final BorderRadius? borderRadius;
  final BoxBorder? boxBorder;
  final Color? borderColor;
  final Color? textColor;
  
  // ============================================================================
  // NEW PARAMETERS (para compatibilidad)
  // ============================================================================
  
  /// Título del campo (ej: "Email", "Password")
  final String? labelTitle;
  
  /// Si el campo es requerido (para mostrar asterisco)
  final bool isRequired;
  
  /// Callback para cambios en el texto
  final Function(String)? onChanged;
  
  /// Tipo de campo (password usa este en lugar de isPasswordField)
  final bool isPassword;
  
  // ============================================================================
  // DEPRECATED PARAMETERS
  // ============================================================================
  
  @Deprecated('Use borderRadius instead')
  final bool isTop;
  
  @Deprecated('Use borderRadius instead')
  final bool isBottom;
  
  // ============================================================================
  // CALLBACKS
  // ============================================================================
  
  final Function(String)? onFieldSubmitted;

  const CustomAuthTextFieldWidget({
    super.key,
    // Required
    required this.hintText,
    required this.controller,
    // Input configuration
    this.keyboardType,
    this.isPasswordField = false,
    this.isPassword = false,  // Alias para isPasswordField
    this.textInputAction,
    this.pattern,
    this.enabled = true,
    this.autofocus = false,
    // Validation
    this.validator,
    this.errorText,
    // Styling
    this.prefix,
    this.suffix,
    this.borderRadius,
    this.boxBorder,
    this.borderColor,
    this.textColor,
    // New
    this.labelTitle,
    this.isRequired = false,
    this.onChanged,
    // Deprecated
    this.isTop = false,
    this.isBottom = false,
    // Callbacks
    this.onFieldSubmitted,
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

  // Determina si es un campo de contraseña (usa ambos parámetros)
  bool get _isPasswordType => widget.isPasswordField || widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;

        final fontSize = isMobile ? 14.0 : 16.0;
        final horizontalPadding = isMobile ? 16.0 : 20.0;
        final verticalPadding = isMobile ? 12.0 : 16.0;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label opcional
            if (widget.labelTitle != null) ...[
              _buildLabel(fontSize, isDark),
              const SizedBox(height: 8),
            ],
            
            _buildTextField(
              isDark,
              fontSize,
              horizontalPadding,
              verticalPadding,
            ),
            
            if (widget.errorText != null) ...[
              const SizedBox(height: 8),
              _buildErrorText(fontSize),
            ],
          ],
        );
      },
    );
  }

  /// Construye el label del campo
  Widget _buildLabel(double fontSize, bool isDark) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: isDark
              ? JenixColorsApp.backgroundWhite
              : JenixColorsApp.darkColorText,
          fontFamily: 'OpenSansHebrew',
        ),
        children: [
          TextSpan(text: widget.labelTitle!),
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: isDark
                    ? JenixColorsApp.errorColor.withOpacity(0.8)
                    : JenixColorsApp.errorColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    bool isDark,
    double fontSize,
    double horizontalPadding,
    double verticalPadding,
  ) {
    final borderColor = _getBorderColor(isDark);
    final borderRadius = _getBorderRadius();
    final hasError = widget.errorText != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDark),
        borderRadius: borderRadius,
        border: widget.boxBorder ?? _getBorder(borderColor, hasError),
        boxShadow: _getFocusShadow(isDark),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: _isPasswordType && _obscurePassword,
        inputFormatters: widget.pattern != null ? [widget.pattern!] : null,
        textInputAction: widget.textInputAction ?? TextInputAction.done,
        onSubmitted: widget.onFieldSubmitted,
        onChanged: widget.onChanged,  // Agregado
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: _getTextColor(isDark),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          fontFamily: 'OpenSansHebrew',
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: isDark
                ? JenixColorsApp.lightGray
                : JenixColorsApp.placeholderColor,
            fontSize: fontSize,
            fontFamily: 'OpenSansHebrew',
          ),
          prefixIcon: widget.prefix,
          suffixIcon: _buildSuffixIcon(isDark),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
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

  Widget? _buildSuffixIcon(bool isDark) {
    if (_isPasswordType && widget.suffix == null) {
      return IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: isDark
              ? JenixColorsApp.lightGray
              : JenixColorsApp.greyColorIcon,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
      );
    }
    return widget.suffix;
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
              widget.errorText!,
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

  Color _getBackgroundColor(bool isDark) {
    if (!widget.enabled) {
      return isDark
          ? JenixColorsApp.darkGray.withOpacity(0.5)
          : JenixColorsApp.inputBackground.withOpacity(0.5);
    }

    if (_isFocused) {
      return isDark
          ? JenixColorsApp.darkGray
          : JenixColorsApp.inputBackgroundFocus;
    }

    return isDark ? JenixColorsApp.darkGray : JenixColorsApp.inputBackground;
  }

  Border _getBorder(Color borderColor, bool hasError) {
    Color finalBorderColor;
    double borderWidth;

    if (hasError) {
      finalBorderColor = JenixColorsApp.inputBorderError;
      borderWidth = 1.5;
    } else if (_isFocused) {
      finalBorderColor = JenixColorsApp.inputBorderFocus;
      borderWidth = 2;
    } else {
      finalBorderColor = borderColor;
      borderWidth = 1.5;
    }

    return Border.all(color: finalBorderColor, width: borderWidth);
  }

  List<BoxShadow>? _getFocusShadow(bool isDark) {
    if (!_isFocused || widget.errorText != null) return null;

    return [
      BoxShadow(
        color:
            (isDark
                    ? JenixColorsApp.primaryBlueLight
                    : JenixColorsApp.primaryBlue)
                .withOpacity(0.15),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  Color _getBorderColor(bool isDark) {
    if (widget.borderColor != null) return widget.borderColor!;

    return isDark ? JenixColorsApp.grayColor : JenixColorsApp.inputBorder;
  }

  Color _getTextColor(bool isDark) {
    if (widget.textColor != null) return widget.textColor!;

    return isDark
        ? JenixColorsApp.backgroundWhite
        : JenixColorsApp.darkColorText;
  }

  BorderRadius _getBorderRadius() {
    if (widget.borderRadius != null) {
      return widget.borderRadius!;
    }

    if (widget.isTop && !widget.isBottom) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    }

    if (widget.isBottom && !widget.isTop) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }

    return BorderRadius.circular(12);
  }
}
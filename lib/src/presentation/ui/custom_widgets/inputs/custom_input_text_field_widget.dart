import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/form/custom_form_element.dart';

/// Campo de texto personalizado con label integrado
/// 
/// Combina CustomFormElement con TextField para crear un input completo
/// 
/// Características:
/// - Label automático con campo requerido
/// - Modo password con toggle visibility
/// - Validación integrada
/// - Responsive
/// - Soporte para tema claro/oscuro
/// - Prefijos y sufijos personalizables
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomInputTextFieldWidget(
///   controller: _emailController,
///   labelTitle: "Email",
///   hintText: "Enter your email",
///   textInputType: TextInputType.emailAddress,
///   isRequired: true,
///   validator: FieldsValidators.emailValidator,
/// )
/// ```
class CustomInputTextFieldWidget extends StatefulWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;
  
  /// Título/label del campo
  final String labelTitle;
  
  /// Texto de ayuda (placeholder)
  final String hintText;
  
  /// Si es un campo de contraseña (muestra/oculta texto)
  final bool isPassword;
  
  /// Tipo de teclado
  final TextInputType textInputType;
  
  /// Si el campo es requerido (muestra asterisco)
  final bool isRequired;
  
  /// Función de validación
  final String? Function(String?)? validator;
  
  /// Texto de error a mostrar
  final String? errorText;
  
  /// Widget personalizado para el prefijo
  final Widget? prefix;
  
  /// Widget personalizado para el sufijo
  final Widget? suffix;
  
  /// Formateador de entrada (ej: máscaras)
  final List<TextInputFormatter>? inputFormatters;
  
  /// Acción del teclado (done, next, etc.)
  final TextInputAction? textInputAction;
  
  /// Callback cuando se presiona enter/done
  final Function(String)? onFieldSubmitted;
  
  /// Callback cuando cambia el texto
  final Function(String)? onChanged;
  
  /// Si el campo está habilitado
  final bool enabled;
  
  /// Auto focus
  final bool autofocus;
  
  /// Número máximo de líneas
  final int? maxLines;
  
  /// Número mínimo de líneas
  final int? minLines;
  
  /// Longitud máxima del texto
  final int? maxLength;
  
  /// Si debe mostrar el contador de caracteres
  final bool showCounter;

  const CustomInputTextFieldWidget({
    super.key,
    required this.controller,
    required this.labelTitle,
    required this.hintText,
    this.isPassword = false,
    this.textInputType = TextInputType.text,
    this.isRequired = false,
    this.validator,
    this.errorText,
    this.prefix,
    this.suffix,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
  });

  @override
  State<CustomInputTextFieldWidget> createState() =>
      _CustomInputTextFieldWidgetState();
}

class _CustomInputTextFieldWidgetState
    extends State<CustomInputTextFieldWidget> {
  late bool _obscure;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _focusNode.addListener(_onFocusChange);
    _currentError = widget.errorText;
  }

  @override
  void didUpdateWidget(covariant CustomInputTextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPassword != widget.isPassword) {
      _obscure = widget.isPassword;
    }
    if (oldWidget.errorText != widget.errorText) {
      _currentError = widget.errorText;
    }
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
      
      // Validar al perder el foco si hay validator
      if (!_isFocused && widget.validator != null) {
        _currentError = widget.validator!(widget.controller.text);
      }
    });
  }

  void _handleChanged(String value) {
    // Limpiar error al escribir
    if (_currentError != null) {
      setState(() {
        _currentError = null;
      });
    }
    
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;

        return CustomFormElement(
          labelTitle: widget.labelTitle,
          isRequired: widget.isRequired,
          widget: _buildTextField(isMobile),
        );
      },
    );
  }

  Widget _buildTextField(bool isMobile) {
    final fontSize = isMobile ? 14.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: _isFocused 
            ? JenixColorsApp.inputBackgroundFocus 
            : JenixColorsApp.inputBackground,
        border: Border.all(
          color: _currentError != null
              ? JenixColorsApp.inputBorderError
              : _isFocused
                  ? JenixColorsApp.inputBorderFocus
                  : JenixColorsApp.inputBorder,
          width: _isFocused ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.textInputType,
            obscureText: widget.isPassword ? _obscure : false,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onFieldSubmitted,
            onChanged: _handleChanged,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              fontFamily: "OpenSansHebrew",
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: widget.enabled 
                  ? JenixColorsApp.darkColorText 
                  : JenixColorsApp.subtitleColor,
            ),
            cursorColor: JenixColorsApp.primaryRed,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: JenixColorsApp.placeholderColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                fontFamily: "OpenSansHebrew",
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 14,
              ),
              prefixIcon: widget.prefix,
              prefixIconColor: _isFocused 
                  ? JenixColorsApp.primaryRed 
                  : JenixColorsApp.greyColorIcon,
              suffixIcon: _buildSuffixIcon(),
              suffixIconColor: _isFocused 
                  ? JenixColorsApp.primaryRed 
                  : JenixColorsApp.greyColorIcon,
              counterText: widget.showCounter ? null : '',
              errorText: null, // Manejamos el error fuera
            ),
          ),
          
          // Error message
          if (_currentError != null) _buildErrorText(fontSize),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // Prioridad: suffix custom > password toggle
    if (widget.suffix != null) {
      return widget.suffix;
    }
    
    if (widget.isPassword) {
      return IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
      );
    }
    
    return null;
  }

  Widget _buildErrorText(double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: JenixColorsApp.errorColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _currentError!,
              style: TextStyle(
                color: JenixColorsApp.errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: "OpenSansHebrew",
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _documentNumberController;
  bool _submitting = false;

  /// Calcula el tamaño responsivo de fuente
  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  /// Calcula el padding responsivo
  double _getResponsivePadding(double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return basePadding * 0.9;
    if (screenWidth < 600) return basePadding;
    if (screenWidth < 900) return basePadding * 1.15;
    return basePadding * 1.3;
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(loginProviderProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _documentNumberController = TextEditingController(text: user?.documentNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelFontSize = _getResponsiveFontSize(14);
    final verticalPadding = _getResponsivePadding(18);
    final horizontalPadding = _getResponsivePadding(18);
    
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor,
        fontSize: labelFontSize,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: isDark ? JenixColorsApp.surfaceColor : JenixColorsApp.backgroundWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? JenixColorsApp.primaryColor : JenixColorsApp.inputBorder,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? JenixColorsApp.primaryColor : JenixColorsApp.inputBorder,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: JenixColorsApp.accentColor,
          width: 2.5,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      isDense: false,
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final usersController = ref.read(usersControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';
    final userId = user?.id ?? '';

    try {
      print('📤 Actualizando perfil: $userId');
      final res = await usersController.updateUser(
        userId: userId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        documentNumber: _documentNumberController.text.trim(),
        token: token,
      );

      if (mounted) {
        if (res.isRight) {
          print('✅ Perfil actualizado: ${res.right.email}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Perfil actualizado exitosamente'),
            backgroundColor: JenixColorsApp.successColor,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context, true);
        } else {
          print('❌ Error al actualizar perfil: ${res.left}');
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Error al actualizar perfil'),
            backgroundColor: JenixColorsApp.errorColor,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      print('❌ Excepción al actualizar perfil: $e');
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: JenixColorsApp.errorColor,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tamaños responsivos - Base aumentada para mejor legibilidad
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.backgroundWhite;
    final appBarBg = isDark ? JenixColorsApp.primaryColor : JenixColorsApp.primaryBlue;
    final gradientStart = isDark ? JenixColorsApp.primaryColor : JenixColorsApp.infoLight;
    final gradientEnd = isDark ? JenixColorsApp.surfaceColor : JenixColorsApp.infoLight;
    
    final appBarTitleFontSize = _getResponsiveFontSize(22);
    final inputTextFontSize = _getResponsiveFontSize(18);
    final buttonTextFontSize = _getResponsiveFontSize(18);
    final spacingBetweenFields = _getResponsivePadding(24);
    final paddingForm = _getResponsivePadding(28);
    final spacingButton = _getResponsivePadding(40);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: appBarTitleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(paddingForm),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_submitting,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: inputTextFontSize),
                    decoration: _inputDecoration("Nombre completo"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  SizedBox(height: spacingBetweenFields),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_submitting,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: inputTextFontSize),
                    decoration: _inputDecoration("Teléfono"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el teléfono' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: spacingBetweenFields),
                  TextFormField(
                    controller: _documentNumberController,
                    enabled: !_submitting,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: inputTextFontSize),
                    decoration: _inputDecoration("Número de documento"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el número de documento' : null,
                  ),
                  SizedBox(height: spacingButton),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _submitting ? Colors.grey : JenixColorsApp.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: spacingButton * 0.4),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonTextFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
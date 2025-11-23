import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9DA9B9), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0A2647),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5090), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5090), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBE1723), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context, true);
        } else {
          print('❌ Error al actualizar perfil: ${res.left}');
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al actualizar perfil'),
            backgroundColor: Color(0xFFBE1723),
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
          backgroundColor: const Color(0xFFBE1723),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2647),
        title: const Text('Editar Perfil'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A2647), Color(0xFF09131E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_submitting,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Nombre completo"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_submitting,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Teléfono"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el teléfono' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _documentNumberController,
                    enabled: !_submitting,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Número de documento"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el número de documento' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _submitting ? Colors.grey : const Color(0xFFBE1723),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
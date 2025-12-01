import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final UserEntity? userToEdit;

  const UserFormDialog({super.key, this.userToEdit});

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _documentNumberController;
  bool _submitting = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  bool get _isEditing => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userToEdit?.email ?? '');
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: widget.userToEdit?.name ?? '');
    _phoneController = TextEditingController(text: widget.userToEdit?.phone ?? '');
    _documentNumberController = TextEditingController(text: widget.userToEdit?.documentNumber ?? '');

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final usersController = ref.read(usersControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    try {
      if (widget.userToEdit != null) {
        // Editar usuario existente
        print('✏️ Actualizando usuario: ${widget.userToEdit!.email}');
        final res = await usersController.updateUser(
          userId: widget.userToEdit!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          documentNumber: _documentNumberController.text,
          token: token,
        );

        if (mounted) {
          if (res.isRight) {
            print('✅ Usuario actualizado: ${res.right.email}');
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Usuario actualizado exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            print('❌ Error al actualizar usuario: ${res.left}');
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error al actualizar usuario'),
              backgroundColor: Color(0xFFBE1723),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      } else {
        // Crear nuevo usuario organizador
        print('🆕 Creando usuario organizador: ${_emailController.text}');
        final res = await usersController.createOrganizer(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
          documentNumber: _documentNumberController.text,
          token: token,
        );

        if (mounted) {
          if (res.isRight) {
            print('✅ Usuario creado: ${res.right.email}');
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Usuario creado exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            print('❌ Error al crear usuario: ${res.left}');
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error al crear usuario'),
              backgroundColor: Color(0xFFBE1723),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      }
    } catch (e) {
      print('❌ Excepción al procesar usuario: $e');
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
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: const Color(0xFF12263F).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userToEdit != null ? "Editar Usuario" : "Nuevo Organizador",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  if (widget.userToEdit == null) ...[
                    TextFormField(
                      controller: _emailController,
                      enabled: !_submitting,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Correo electrónico"),
                      validator: (v) => v == null || v.isEmpty ? 'Ingrese el correo' : null,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_submitting,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Contraseña"),
                      validator: (v) => v == null || v.isEmpty ? 'Ingrese la contraseña' : null,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                  ],
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
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting ? null : () => Navigator.pop(context),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color: _submitting ? Colors.white30 : Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _submitting ? Colors.grey : const Color(0xFFBE1723),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Crear",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF0A2647),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBE1723), width: 1.4),
        ),
      );
}
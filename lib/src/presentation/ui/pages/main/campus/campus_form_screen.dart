import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';

class CampusFormDialog extends StatefulWidget {
  final Campus? campus;
  const CampusFormDialog({super.key, this.campus});

  @override
  State<CampusFormDialog> createState() => _CampusFormDialogState();
}

class _CampusFormDialogState extends State<CampusFormDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _state;
  bool _isActive = true;

  final List<String> campusStates = ['Abierto', 'En mantenimiento', 'Cerrado'];
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.campus?.name ?? '');
    _state = widget.campus?.state ?? 'Abierto';
    _isActive = widget.campus?.isActive ?? true;

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final campus = Campus(
        id: widget.campus?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        state: _state,
        isActive: _isActive,
        createdAt: widget.campus?.createdAt ?? DateTime.now(),
      );
      Navigator.pop(context, campus);
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.campus == null ? "Nuevo Campus" : "Editar Campus",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nombre del campus",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0A2647),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFBE1723), width: 1.4),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _state,
                  dropdownColor: const Color(0xFF0A2647),
                  decoration: InputDecoration(
                    labelText: "Estado",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0A2647),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: campusStates
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _state = v!),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text("Activo", style: TextStyle(color: Colors.white)),
                  activeColor: const Color(0xFFBE1723),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE1723),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(widget.campus == null ? "Crear" : "Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

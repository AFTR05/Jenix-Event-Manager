import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';

class RoomFormDialog extends StatefulWidget {
  final Room? room;
  final List<Campus> campuses;
  const RoomFormDialog({super.key, this.room, required this.campuses});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _capacityController;
  late String _state;
  Campus? _selectedCampus;
  bool _isActive = true;

  final List<String> roomStates = ['Abierto', 'En mantenimiento', 'Cerrado'];
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.room?.type ?? '');
    _capacityController = TextEditingController(
        text: widget.room?.capacity != null ? widget.room!.capacity.toString() : '');
    _state = widget.room?.state ?? 'Abierto';
    _selectedCampus = widget.room?.campus ?? widget.campuses.first;
    _isActive = widget.room?.isActive ?? true;

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final room = Room(
        id: widget.room?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: _typeController.text,
        capacity: int.parse(_capacityController.text),
        state: _state,
        campus: _selectedCampus!,
        isActive: _isActive,
        createdAt: widget.room?.createdAt ?? DateTime.now(),
      );
      Navigator.pop(context, room);
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
                  widget.room == null ? "Nuevo Salón" : "Editar Salón",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _typeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Tipo de salón"),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese el tipo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Capacidad"),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese la capacidad' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _state,
                  dropdownColor: const Color(0xFF0A2647),
                  decoration: _inputDecoration("Estado"),
                  items: roomStates
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _state = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Campus>(
                  value: _selectedCampus,
                  dropdownColor: const Color(0xFF0A2647),
                  decoration: _inputDecoration("Campus asociado"),
                  items: widget.campuses
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCampus = v!),
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
                      child: Text(widget.room == null ? "Crear" : "Guardar"),
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

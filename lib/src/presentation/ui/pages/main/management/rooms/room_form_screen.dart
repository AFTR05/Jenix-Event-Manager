import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/room_status_enum.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

/// Dialog used to create/edit a Room. It uses the campus stream so the dropdown
/// is always populated with current data without blocking the UI.
class RoomFormDialog extends ConsumerStatefulWidget {
  final RoomEntity? room;
  const RoomFormDialog({super.key, this.room});

  @override
  ConsumerState<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends ConsumerState<RoomFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _capacityController;
  late RoomStatusEnum _state;
  CampusEntity? _selectedCampus;
  List<CampusEntity> _campuses = [];
  bool _loadingCampuses = true;
  // Equipment options and selected values for the checklist
  final List<String> _equipmentOptions = [
    'Aire acondicionado',
    'Proyector',
    'Ventilador',
    'Computadores',
    'Televisor inteligente',
    'Pizarra',
    'Micrófono',
  ];
  List<String> _equipmentSelected = [];
  bool _submitting = false;
  bool _isActive = true;

  final List<RoomStatusEnum> roomStates = [
    RoomStatusEnum.disponible,
    RoomStatusEnum.mantenimiento,
    RoomStatusEnum.cerrado,
  ];
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.room?.type ?? '');
    _capacityController = TextEditingController(
        text: widget.room?.capacity != null ? widget.room!.capacity.toString() : '');
    _state = widget.room?.state ?? RoomStatusEnum.disponible;
    _isActive = widget.room?.isActive ?? true;
    // initialize equipment from existing room when editing
    _equipmentSelected = widget.room?.equipment != null ? List.from(widget.room!.equipment!) : [];

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
    
    _loadCampuses();
  }

  Future<void> _loadCampuses() async {
    final controller = ref.read(campusControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';
    
    final res = await controller.getAllCampuses(token);
    if (mounted) {
      setState(() {
        _loadingCampuses = false;
        if (res.isRight) {
          _campuses = res.right;
          if (widget.room?.campus != null) {
            _selectedCampus = _campuses.firstWhere(
              (c) => c.id == widget.room!.campus.id,
              orElse: () => _campuses.isNotEmpty ? _campuses.first : widget.room!.campus,
            );
          } else if (_campuses.isNotEmpty) {
            _selectedCampus = _campuses.first;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }





  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCampus == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Debe seleccionar un campus'),
        backgroundColor: Color(0xFFBE1723),
      ));
      return;
    }
    
    setState(() => _submitting = true);
    final roomController = ref.read(roomControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    final equipment = _equipmentSelected.isNotEmpty ? _equipmentSelected : null;

    try {
      if (widget.room == null) {
        // Create
        print('🆕 Creando salón: ${_typeController.text}');
        final res = await roomController.createRoom(
          type: _typeController.text,
          capacity: int.parse(_capacityController.text),
          state: _state.toText(),
          equipment: equipment,
          campusId: _selectedCampus!.id,
          token: token,
        );
        
        if (mounted) {
          if (res.isRight) {
            print('✅ Salón creado: ${res.right.type}');
            Navigator.pop(context, true); // Retornar true para indicar éxito
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Salón creado exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            print('❌ Error al crear salón: ${res.left}');
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error al crear salón'),
              backgroundColor: Color(0xFFBE1723),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      } else {
        // Update
        print('✏️ Actualizando salón: ${widget.room!.id}');
        final res = await roomController.updateRoom(
          id: widget.room!.id,
          type: _typeController.text,
          capacity: int.parse(_capacityController.text),
          state: _state.toText(),
          equipment: equipment,
          campusId: _selectedCampus!.id,
          token: token,
        );
        
        if (mounted) {
          if (res.isRight) {
            print('✅ Salón actualizado: ${widget.room!.id}');
            Navigator.pop(context, true); // Retornar true para indicar éxito
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Salón actualizado exitosamente'),
              backgroundColor: Color(0xFF1976D2),
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            print('❌ Error al actualizar salón: ${res.left}');
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error al actualizar salón'),
              backgroundColor: Color(0xFFBE1723),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      }
    } catch (e) {
      print('❌ Excepción al procesar salón: $e');
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
                    widget.room == null ? "Nuevo Salón" : "Editar Salón",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _typeController,
                    enabled: !_submitting,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Tipo de salón"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el tipo' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _capacityController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Capacidad"),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese la capacidad' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RoomStatusEnum>(
                    value: _state,
                    dropdownColor: const Color(0xFF0A2647),
                    decoration: _inputDecoration("Estado"),
                    items: roomStates
                        .map((e) => DropdownMenuItem<RoomStatusEnum>(
                              value: e,
                              child: Text(_displayState(e), style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: _submitting ? null : (v) => setState(() => _state = v!),
                  ),
                  const SizedBox(height: 16),
                  _loadingCampuses
                      ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
                      : DropdownButtonFormField<CampusEntity>(
                          value: _selectedCampus,
                          dropdownColor: const Color(0xFF0A2647),
                          decoration: _inputDecoration("Campus asociado"),
                          items: _campuses
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: _submitting ? null : (v) => setState(() => _selectedCampus = v),
                          validator: (v) => v == null ? 'Seleccione un campus' : null,
                        ),
                  const SizedBox(height: 16),
                  // Equipment checklist
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Equipamiento',
                      style: TextStyle(
                        color: _submitting ? Colors.white30 : Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _equipmentOptions.map((opt) {
                      final checked = _equipmentSelected.contains(opt);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: _submitting ? null : (v) {
                          setState(() {
                            if (v == true) {
                              if (!_equipmentSelected.contains(opt)) _equipmentSelected.add(opt);
                            } else {
                              _equipmentSelected.remove(opt);
                            }
                          });
                        },
                        title: Text(
                          opt,
                          style: TextStyle(
                            color: _submitting ? Colors.white30 : Colors.white,
                          ),
                        ),
                        activeColor: const Color(0xFFBE1723),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: _submitting ? null : (v) => setState(() => _isActive = v),
                    title: Text(
                      "Activo",
                      style: TextStyle(
                        color: _submitting ? Colors.white30 : Colors.white,
                      ),
                    ),
                    activeColor: const Color(0xFFBE1723),
                    contentPadding: EdgeInsets.zero,
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
                            : Text(
                                widget.room == null ? "Crear" : "Guardar",
                                style: const TextStyle(color: Colors.white),
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

  String _displayState(RoomStatusEnum state) {
    switch (state) {
      case RoomStatusEnum.disponible:
        return 'Abierto';
      case RoomStatusEnum.mantenimiento:
        return 'En mantenimiento';
      case RoomStatusEnum.cerrado:
        return 'Cerrado';
    }
  }
}


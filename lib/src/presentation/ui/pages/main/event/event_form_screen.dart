import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class EventFormDialog extends ConsumerStatefulWidget {
  final EventEntity? event;
  const EventFormDialog({super.key, this.event});

  @override
  ConsumerState<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends ConsumerState<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlImageController;
  late TextEditingController _maxAttendeesController;

  RoomEntity? _selectedRoom;
  List<RoomEntity> _rooms = [];
  bool _loadingRooms = true;

  String? _selectedOrganizationArea;
  ModalityType? _selectedModality;

  DateTime? _initialDate;   // Solo fecha
  TimeOfDay? _beginTime;    // Solo hora
  DateTime? _finalDate;     // Solo fecha
  TimeOfDay? _endTime;      // Solo hora

  bool _submitting = false;

  final List<String> _organizationAreas = [
    'Facultad de Ciencias',
    'Facultad de Ciencias Médicas',
    'Facultad de Ciencias Administrativas',
    'Facultad de Ingenierías y Ciencias Básicas',
    'Facultad de Ciencias Humanas y de la Educación',
    'Facultad de Ciencias Sociales y Jurídicas',
    'Facultad de Ciencias de la Salud',
    'Facultad de Ciencias Agropecuarias',
  ];

  final List<ModalityType> _modalities = [
    ModalityType.presential,
    ModalityType.virtual,
    ModalityType.hybrid,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _urlImageController = TextEditingController(text: widget.event?.urlImage ?? '');
    _maxAttendeesController = TextEditingController(
        text: widget.event?.maxAttendees.toString() ?? '');
    _selectedModality = widget.event?.modality ?? ModalityType.presential;
    _selectedOrganizationArea = widget.event?.organizationArea ?? _organizationAreas.first;
    _initialDate = widget.event?.createdAt;
    _finalDate = widget.event?.finalDate;
    _beginTime = widget.event != null
        ? TimeOfDay.fromDateTime(widget.event!.createdAt)
        : null;
    _endTime = widget.event != null
        ? TimeOfDay.fromDateTime(widget.event!.finalDate)
        : null;
    _selectedRoom = widget.event?.room;

    _loadRooms();
  }

Future<void> _loadRooms() async {
  final roomController = ref.read(roomControllerProvider);
  final token = ref.read(loginProviderProvider)?.accessToken ?? '';
  final res = await roomController.getAllRooms(token);

  if (mounted) {
    if (res.isRight) {
      setState(() {
        _rooms = res.right;

        // Si hay habitaciones cargadas, seleccionar la correcta o la primera
        if (_rooms.isNotEmpty) {
          if (widget.event != null) {
            _selectedRoom = _rooms.firstWhere(
              (r) => r.id == widget.event!.room.id,
              orElse: () => _rooms.first,
            );
          } else {
            _selectedRoom = _rooms.first;
          }
        } else {
          _selectedRoom = null;
        }

        _loadingRooms = false;
      });
    } else {
      setState(() => _loadingRooms = false);
    }
  }
}

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlImageController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _pickInitialDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _initialDate = date);
  }

  Future<void> _pickFinalDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _finalDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _finalDate = date);
  }

  Future<void> _pickBeginTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _beginTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _beginTime = time);
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _endTime = time);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_initialDate == null || _finalDate == null || _beginTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione fecha y hora de inicio y fin')),
      );
      return;
    }
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una sala')),
      );
      return;
    }

    setState(() => _submitting = true);
    final controller = ref.read(eventControllerProvider);
    final token = ref.read(loginProviderProvider)?.accessToken ?? '';

    final initialDateTime = DateTime(
      _initialDate!.year,
      _initialDate!.month,
      _initialDate!.day,
      _beginTime!.hour,
      _beginTime!.minute,
    );

    final finalDateTime = DateTime(
      _finalDate!.year,
      _finalDate!.month,
      _finalDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final res = widget.event == null
        ? await controller.createAndCache(
            name: _nameController.text,
            roomId: _selectedRoom!.id,
            organizationArea: _selectedOrganizationArea!,
            description: _descriptionController.text,
            state: "Activo",
            modality: _selectedModality!.label,
            maxAttendees: int.parse(_maxAttendeesController.text),
            urlImage: _urlImageController.text,
            beginHour:
                "${_beginTime!.hour.toString().padLeft(2,'0')}:${_beginTime!.minute.toString().padLeft(2,'0')}",
            endHour:
                "${_endTime!.hour.toString().padLeft(2,'0')}:${_endTime!.minute.toString().padLeft(2,'0')}",
            initialDate: initialDateTime,
            finalDate: finalDateTime,
            token: token,
          )
        : await controller.updateAndCache(
            id: widget.event!.id,
            name: _nameController.text,
            roomId: _selectedRoom!.id,
            organizationArea: _selectedOrganizationArea!,
            description: _descriptionController.text,
            state: "Activo",
            modality: _selectedModality!.label,
            maxAttendees: int.parse(_maxAttendeesController.text),
            urlImage: _urlImageController.text,
            beginHour:
                "${_beginTime!.hour.toString().padLeft(2,'0')}:${_beginTime!.minute.toString().padLeft(2,'0')}",
            endHour:
                "${_endTime!.hour.toString().padLeft(2,'0')}:${_endTime!.minute.toString().padLeft(2,'0')}",
            initialDate: initialDateTime,
            finalDate: finalDateTime,
            token: token,
          );

    setState(() => _submitting = false);

    if (res.isRight) {
  Navigator.pop(context, true);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(widget.event == null ? 'Evento creado' : 'Evento actualizado')),
  );
} else {
  // Mostrar error genérico en un AlertDialog
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(res.left.toString()), // Genérico: muestra cualquier valor de left
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return Dialog(
      backgroundColor: const Color(0xFF12263F).withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.event == null ? "Nuevo Evento" : "Editar Evento",
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese una descripción' : null,
                ),
                const SizedBox(height: 16),
                _loadingRooms
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<RoomEntity>(
                        value: _selectedRoom,
                        decoration: const InputDecoration(labelText: 'Salón'),
                        items: _rooms
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.type),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRoom = v),
                        validator: (v) => v == null ? 'Seleccione un salón' : null,
                      ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedOrganizationArea,
                  decoration: const InputDecoration(labelText: 'Área'),
                  items: _organizationAreas
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedOrganizationArea = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ModalityType>(
                  value: _selectedModality,
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                  items: _modalities
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedModality = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxAttendeesController,
                  decoration: const InputDecoration(labelText: 'Máx. asistentes'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese número de asistentes' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlImageController,
                  decoration: const InputDecoration(labelText: 'URL Imagen'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _pickInitialDate,
                          child: Text(_initialDate == null
                              ? 'Seleccionar fecha inicio'
                              : dateFormat.format(_initialDate!))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _pickBeginTime,
                          child: Text(_beginTime == null
                              ? 'Seleccionar hora inicio'
                              : "${_beginTime!.hour.toString().padLeft(2,'0')}:${_beginTime!.minute.toString().padLeft(2,'0')}")),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _pickFinalDate,
                          child: Text(_finalDate == null
                              ? 'Seleccionar fecha fin'
                              : dateFormat.format(_finalDate!))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _pickEndTime,
                          child: Text(_endTime == null
                              ? 'Seleccionar hora fin'
                              : "${_endTime!.hour.toString().padLeft(2,'0')}:${_endTime!.minute.toString().padLeft(2,'0')}")),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _submitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const CircularProgressIndicator()
                          : Text(widget.event == null ? 'Crear' : 'Guardar'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

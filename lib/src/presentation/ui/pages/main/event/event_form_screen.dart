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

  DateTime? _initialDate;
  TimeOfDay? _beginTime;
  DateTime? _finalDate;
  TimeOfDay? _endTime;

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
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _urlImageController = TextEditingController(text: widget.event?.urlImage ?? '');
    _maxAttendeesController = TextEditingController(
        text: widget.event?.maxAttendees.toString() ?? '');
    _selectedModality = widget.event?.modality ?? ModalityType.presential;
    _selectedOrganizationArea =
        widget.event?.organizationArea ?? _organizationAreas.first;
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD32F2F),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF1A1A1A),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _initialDate = date);
  }

  Future<void> _pickFinalDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _finalDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD32F2F),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF1A1A1A),
        ),
        child: child!,
      ),
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
    if (_initialDate == null ||
        _finalDate == null ||
        _beginTime == null ||
        _endTime == null) {
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
                "${_beginTime!.hour.toString().padLeft(2, '0')}:${_beginTime!.minute.toString().padLeft(2, '0')}",
            endHour:
                "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}",
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
                "${_beginTime!.hour.toString().padLeft(2, '0')}:${_beginTime!.minute.toString().padLeft(2, '0')}",
            endHour:
                "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}",
            initialDate: initialDateTime,
            finalDate: finalDateTime,
            token: token,
          );

    setState(() => _submitting = false);

    if (res.isRight) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(widget.event == null ? 'Evento creado' : 'Evento actualizado')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          content: Text(res.left.toString(), style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeStyle = const TextStyle(color: Colors.white);

    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.event == null ? "Nuevo Evento" : "Editar Evento",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Sección Información General
                _buildCard(
                  child: Column(
                    children: [
                      _buildTextField(
                          controller: _nameController,
                          label: "Nombre",
                          icon: Icons.event,
                          validatorMsg: "Ingrese un nombre"),
                      const SizedBox(height: 16),
                      _buildTextField(
                          controller: _descriptionController,
                          label: "Descripción",
                          icon: Icons.description,
                          validatorMsg: "Ingrese una descripción"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _urlImageController,
                        label: "URL Imagen",
                        icon: Icons.image,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sección Ubicación y Asistentes
                _buildCard(
                  child: Column(
                    children: [
                      _loadingRooms
                          ? const CircularProgressIndicator()
                          : _buildDropdown<RoomEntity>(
                              value: _selectedRoom,
                              label: "Salón",
                              items: _rooms,
                              onChanged: (v) => setState(() => _selectedRoom = v),
                              displayLabel: (r) => r.type,
                            ),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        value: _selectedOrganizationArea,
                        label: "Área",
                        items: _organizationAreas,
                        onChanged: (v) =>
                            setState(() => _selectedOrganizationArea = v),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                          controller: _maxAttendeesController,
                          label: "Máx. asistentes",
                          icon: Icons.people,
                          validatorMsg: "Ingrese número de asistentes",
                          keyboard: TextInputType.number),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sección Modalidad y Horarios
                _buildCard(
                  child: Column(
                    children: [
                      _buildDropdown<ModalityType>(
                        value: _selectedModality,
                        label: "Modalidad",
                        items: _modalities,
                        onChanged: (v) => setState(() => _selectedModality = v),
                        displayLabel: (m) => m.label,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateButton(
                                label: "Fecha Inicio",
                                date: _initialDate,
                                onTap: _pickInitialDate),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeButton(
                                label: "Hora Inicio",
                                time: _beginTime,
                                onTap: _pickBeginTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateButton(
                                label: "Fecha Fin",
                                date: _finalDate,
                                onTap: _pickFinalDate),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeButton(
                                label: "Hora Fin",
                                time: _endTime,
                                onTap: _pickEndTime),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _submitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(widget.event == null ? 'Crear' : 'Guardar',
                              style: const TextStyle(fontSize: 16)),
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

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]),
      child: child,
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      IconData? icon,
      String? validatorMsg,
      TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard ?? TextInputType.text,
      style: const TextStyle(color: Colors.white),
      validator: validatorMsg != null
          ? (v) => v == null || v.isEmpty ? validatorMsg : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: Colors.redAccent) : null,
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white12),
            borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown<T>(
      {required T? value,
      required String label,
      required List<T> items,
      required void Function(T?) onChanged,
      String Function(T)? displayLabel}) {
    return DropdownButtonFormField<T>(
      value: value,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent)),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(displayLabel != null ? displayLabel(e) : e.toString()),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateButton(
      {required String label, required DateTime? date, required VoidCallback onTap}) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today, color: Colors.white70),
      label: Text(
        date != null ? dateFormat.format(date) : label,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  Widget _buildTimeButton(
      {required String label, required TimeOfDay? time, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.access_time, color: Colors.white70),
      label: Text(
        time != null
            ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
            : label,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}

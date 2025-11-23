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

class _EventFormDialogState extends ConsumerState<EventFormDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlImageController;
  late TextEditingController _maxAttendeesController;

  RoomEntity? _selectedRoom;
  List<RoomEntity> _rooms = [];
  bool _loadingRooms = true;
  
  List<EventEntity> _allEvents = [];

  String? _selectedOrganizationArea;
  ModalityType? _selectedModality;

  DateTime? _initialDate;
  TimeOfDay? _beginTime;
  DateTime? _finalDate;
  TimeOfDay? _endTime;

  bool _submitting = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final List<String> _organizationAreas = [
    'Todas las Facultades',
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

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();

    _loadRooms();
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    final eventController = ref.read(eventControllerProvider);
    final token = ref.read(loginProviderProvider)?.accessToken ?? '';
    final res = await eventController.getAllEvents(token);

    if (mounted) {
      if (res.isRight) {
        setState(() {
          _allEvents = res.right;
        });
      }
    }
  }

  bool _isRoomAvailable(RoomEntity room, DateTime startTime, DateTime endTime) {
    // Filtrar eventos que no sean el actual (si es edición)
    final relevantEvents = _allEvents.where((event) {
      if (widget.event != null && event.id == widget.event!.id) {
        return false; // Excluir el evento actual si está editando
      }
      return event.room.id == room.id; // Solo eventos en este salón
    }).toList();

    // Si no hay eventos en este salón, está disponible
    if (relevantEvents.isEmpty) {
      return true;
    }

    // Verificar si hay conflicto de horario con algún evento existente
    for (var event in relevantEvents) {
      final eventStart = event.initialDate;
      final eventEnd = event.finalDate;

      // Si el horario solicitado se superpone con el evento existente, no está disponible
      if (startTime.isBefore(eventEnd) && endTime.isAfter(eventStart)) {
        return false;
      }
    }

    return true;
  }

  String? _getRoomUnavailableReason(RoomEntity room, DateTime startTime, DateTime endTime) {
    final conflictingEvents = _allEvents.where((event) {
      if (widget.event != null && event.id == widget.event!.id) {
        return false;
      }
      if (event.room.id != room.id) return false;
      
      final eventStart = event.initialDate;
      final eventEnd = event.finalDate;
      
      return startTime.isBefore(eventEnd) && endTime.isAfter(eventStart);
    }).toList();

    if (conflictingEvents.isEmpty) return null;

    if (conflictingEvents.length == 1) {
      final conflict = conflictingEvents.first;
      final dateFormat = DateFormat('dd MMM yyyy HH:mm');
      return 'Ocupado: ${conflict.name} (${dateFormat.format(conflict.initialDate)} - ${dateFormat.format(conflict.finalDate)})';
    }

    return 'Ocupado: ${conflictingEvents.length} eventos en ese horario';
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
    _animController.dispose();
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

    // Construir horarios completos
    final startDateTime = DateTime(
      _initialDate!.year,
      _initialDate!.month,
      _initialDate!.day,
      _beginTime!.hour,
      _beginTime!.minute,
    );

    final endDateTime = DateTime(
      _finalDate!.year,
      _finalDate!.month,
      _finalDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    // Validar que la fecha de inicio sea menor o igual a la fecha final
    if (startDateTime.isAfter(endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha/hora de inicio debe ser anterior a la de fin')),
      );
      return;
    }

    // Validar que si es el mismo día, la hora de inicio sea menor a la de fin
    if (_initialDate!.compareTo(_finalDate!) == 0 && _beginTime!.hour == _endTime!.hour && _beginTime!.minute >= _endTime!.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La hora de inicio debe ser anterior a la hora de fin')),
      );
      return;
    }

    // Validar que si es presencial o híbrido, tenga un salón seleccionado
    if ((_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) && _selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione una sala para eventos ${_selectedModality == ModalityType.presential ? 'presenciales' : 'híbridos'}')),
      );
      return;
    }

    // Validar disponibilidad del salón (solo si no es virtual)
    if ((_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) && _selectedRoom != null) {
      if (!_isRoomAvailable(_selectedRoom!, startDateTime, endDateTime)) {
        final reason = _getRoomUnavailableReason(_selectedRoom!, startDateTime, endDateTime);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Salón no disponible: ${reason ?? "conflicto de horario"}')),
        );
        return;
      }
    }

    // Validar capacidad si es presencial (capacidad exacta)
    if (_selectedModality == ModalityType.presential && _selectedRoom != null) {
      try {
        final maxAttendees = int.parse(_maxAttendeesController.text);
        if (maxAttendees > _selectedRoom!.capacity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Capacidad insuficiente: ${maxAttendees} personas exceden la capacidad del salón (${_selectedRoom!.capacity})',
              ),
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese un número válido de asistentes')),
        );
        return;
      }
    }
    // Nota: Para híbrido no validamos capacidad completa ya que algunos asistentes pueden participar virtualmente

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

    // Si la URL de imagen está vacía, usar valor por defecto
    final imageUrl = _urlImageController.text.isEmpty 
        ? 'Por defecto'
        : _urlImageController.text;

    final res = widget.event == null
        ? await controller.createAndCache(
            name: _nameController.text,
            roomId: (_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) ? _selectedRoom!.id : '',
            organizationArea: _selectedOrganizationArea!,
            description: _descriptionController.text,
            state: "Activo",
            modality: _selectedModality!.label,
            maxAttendees: int.parse(_maxAttendeesController.text),
            urlImage: imageUrl,
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
            roomId: (_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) ? _selectedRoom!.id : '',
            organizationArea: _selectedOrganizationArea!,
            description: _descriptionController.text,
            state: "Activo",
            modality: _selectedModality!.label,
            maxAttendees: int.parse(_maxAttendeesController.text),
            urlImage: imageUrl,
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
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: const Color(0xFF12263F).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.event == null ? "Nuevo Evento" : "Editar Evento",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Sección Modalidad (PRIMERA)
                  _buildInfoCard(
                    child: Column(
                      children: [
                        _buildDropdown<ModalityType>(
                          value: _selectedModality,
                          label: "Modalidad",
                          items: _modalities,
                          onChanged: (v) {
                            setState(() {
                              _selectedModality = v;
                              // Si es virtual, limpiar selección de salón
                              if (v == ModalityType.virtual) {
                                _selectedRoom = null;
                              }
                            });
                          },
                          displayLabel: (m) => m.label,
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sección Información General
                  _buildInfoCard(
                    child: Column(
                      children: [
                        _buildTextField(
                            controller: _nameController,
                            label: "Nombre",
                            icon: Icons.event,
                            validatorMsg: "Ingrese un nombre",
                            enabled: !_submitting),
                        const SizedBox(height: 16),
                        _buildTextField(
                            controller: _descriptionController,
                            label: "Descripción",
                            icon: Icons.description,
                            validatorMsg: "Ingrese una descripción",
                            enabled: !_submitting),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _urlImageController,
                          label: "URL Imagen",
                          icon: Icons.image,
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sección Fechas y Horarios
                  _buildInfoCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateButton(
                                  label: "Fecha Inicio",
                                  date: _initialDate,
                                  onTap: _submitting ? null : _pickInitialDate),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTimeButton(
                                  label: "Hora Inicio",
                                  time: _beginTime,
                                  onTap: _submitting ? null : _pickBeginTime),
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
                                  onTap: _submitting ? null : _pickFinalDate),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTimeButton(
                                  label: "Hora Fin",
                                  time: _endTime,
                                  onTap: _submitting ? null : _pickEndTime),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sección Ubicación y Área
                  _buildInfoCard(
                    child: Column(
                      children: [
                        _buildTextField(
                            controller: _maxAttendeesController,
                            label: "Máx. asistentes",
                            icon: Icons.people,
                            validatorMsg: "Ingrese número de asistentes",
                            keyboard: TextInputType.number,
                            enabled: !_submitting,
                            onChanged: (_) => setState(() {}),
                          ),
                        const SizedBox(height: 16),
                        _buildDropdown<String>(
                          value: _selectedOrganizationArea,
                          label: "Área",
                          items: _organizationAreas,
                          onChanged: (v) =>
                              setState(() => _selectedOrganizationArea = v),
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sección Salón (SI ES PRESENCIAL O HÍBRIDO)
                  if (_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid)
                    _buildInfoCard(
                      child: Column(
                        children: [
                          _loadingRooms
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
                                  ),
                                )
                              : _buildDropdown<RoomEntity>(
                                  value: _selectedRoom,
                                  label: "Salón",
                                  items: _getAvailableRooms(),
                                  onChanged: (v) => setState(() => _selectedRoom = v),
                                  displayLabel: (r) => '${r.type} (Cap: ${r.capacity})',
                                  enabled: !_submitting,
                                ),
                          if (_selectedRoom != null && _maxAttendeesController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildCapacityWarning(),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Botones
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
                                widget.event == null ? "Crear" : "Guardar",
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

  List<RoomEntity> _getAvailableRooms() {
    if (_maxAttendeesController.text.isEmpty) {
      return _rooms;
    }

    try {
      final maxAttendees = int.parse(_maxAttendeesController.text);
      
      // Si no tenemos fechas/horarios completos, no podemos filtrar por disponibilidad
      if (_initialDate == null || _finalDate == null || _beginTime == null || _endTime == null) {
        // Solo filtrar por capacidad
        if (_selectedModality == ModalityType.presential) {
          return _rooms.where((room) => room.capacity >= maxAttendees).toList();
        } else {
          return _rooms;
        }
      }

      final startDateTime = DateTime(
        _initialDate!.year,
        _initialDate!.month,
        _initialDate!.day,
        _beginTime!.hour,
        _beginTime!.minute,
      );

      final endDateTime = DateTime(
        _finalDate!.year,
        _finalDate!.month,
        _finalDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Para presencial: filtrar por capacidad Y disponibilidad
      if (_selectedModality == ModalityType.presential) {
        return _rooms.where((room) {
          final hasCapacity = room.capacity >= maxAttendees;
          final isAvailable = _isRoomAvailable(room, startDateTime, endDateTime);
          return hasCapacity && isAvailable;
        }).toList();
      } 
      // Para híbrido: mostrar todos pero con indicador de disponibilidad
      else {
        return _rooms.where((room) {
          final isAvailable = _isRoomAvailable(room, startDateTime, endDateTime);
          return isAvailable;
        }).toList();
      }
    } catch (e) {
      return _rooms;
    }
  }

  Widget _buildCapacityWarning() {
    if (_selectedRoom == null || _maxAttendeesController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final maxAttendees = int.parse(_maxAttendeesController.text);
      final roomCapacity = _selectedRoom!.capacity;

      // Verificar disponibilidad del salón si tenemos fechas/horarios
      bool isAvailable = true;
      String? unavailableReason;
      
      if (_initialDate != null && _finalDate != null && _beginTime != null && _endTime != null) {
        final startDateTime = DateTime(
          _initialDate!.year,
          _initialDate!.month,
          _initialDate!.day,
          _beginTime!.hour,
          _beginTime!.minute,
        );

        final endDateTime = DateTime(
          _finalDate!.year,
          _finalDate!.month,
          _finalDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );

        isAvailable = _isRoomAvailable(_selectedRoom!, startDateTime, endDateTime);
        if (!isAvailable) {
          unavailableReason = _getRoomUnavailableReason(_selectedRoom!, startDateTime, endDateTime);
        }
      }

      // Si el salón no está disponible, mostrar error
      if (!isAvailable) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD32F2F), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_busy, color: Color(0xFFD32F2F), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  unavailableReason ?? 'Salón no disponible en ese horario',
                  style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }

      // Para eventos PRESENCIALES: validar capacidad
      if (_selectedModality == ModalityType.presential) {
        if (maxAttendees > roomCapacity) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD32F2F), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Capacidad insuficiente: ${maxAttendees} > ${roomCapacity}',
                    style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else if (maxAttendees == roomCapacity) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA500).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFA500), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFFA500), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Capacidad exacta: ${roomCapacity} personas',
                    style: const TextStyle(color: Color(0xFFFFA500), fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4CAF50), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Disponible - Capacidad: ${maxAttendees}/${roomCapacity}',
                    style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }
      }
      
      // Para eventos HÍBRIDOS: mostrar información pero sin bloquear
      else if (_selectedModality == ModalityType.hybrid) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2196F3), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sin límite de asistentes. Salón: ${roomCapacity} (resto virtual)',
                  style: const TextStyle(color: Color(0xFF2196F3), fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }
      
      return const SizedBox.shrink();
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2647),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? validatorMsg,
    TextInputType? keyboard,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboard ?? TextInputType.text,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      validator: validatorMsg != null
          ? (v) => v == null || v.isEmpty ? validatorMsg : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFBE1723)) : null,
        filled: true,
        fillColor: const Color(0xFF0A2647),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBE1723), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? displayLabel,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: enabled ? onChanged : null,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF0A2647),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: enabled ? Colors.white70 : Colors.white30),
        filled: true,
        fillColor: enabled ? const Color(0xFF0A2647) : const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: enabled ? Colors.white10 : Colors.white10,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBE1723), width: 1.4),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  displayLabel != null ? displayLabel(e) : e.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback? onTap,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(
        Icons.calendar_today,
        color: onTap == null ? Colors.white30 : Colors.white70,
      ),
      label: Text(
        date != null ? dateFormat.format(date) : label,
        style: TextStyle(
          color: onTap == null ? Colors.white30 : Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: onTap == null ? const Color(0xFF1A1A1A) : const Color(0xFF0A2647),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(
        Icons.access_time,
        color: onTap == null ? Colors.white30 : Colors.white70,
      ),
      label: Text(
        time != null
            ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
            : label,
        style: TextStyle(
          color: onTap == null ? Colors.white30 : Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: onTap == null ? const Color(0xFF1A1A1A) : const Color(0xFF0A2647),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

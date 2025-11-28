import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_initialDate == null ||
        _finalDate == null ||
        _beginTime == null ||
        _endTime == null) {
      _showErrorDialog('Seleccione fecha y hora de inicio y fin');
      return;
    }

    // Validar que máx asistentes sea mayor a 0
    try {
      final maxAttendees = int.parse(_maxAttendeesController.text);
      if (maxAttendees <= 0) {
        _showErrorDialog('El número máximo de asistentes debe ser mayor a 0');
        return;
      }
    } catch (e) {
      _showErrorDialog('Ingrese un número válido de asistentes');
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

    // Validar que la fecha/hora de inicio sea anterior a la de fin
    if (!startDateTime.isBefore(endDateTime)) {
      _showErrorDialog('La fecha y hora de inicio debe ser anterior a la de fin');
      return;
    }

    // Validar que si es presencial o híbrido, tenga un salón seleccionado
    if ((_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) && _selectedRoom == null) {
      _showErrorDialog('Seleccione una sala para eventos ${_selectedModality == ModalityType.presential ? 'presenciales' : 'híbridos'}');
      return;
    }

    // Validar disponibilidad del salón (solo si no es virtual)
    if ((_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) && _selectedRoom != null) {
      if (!_isRoomAvailable(_selectedRoom!, startDateTime, endDateTime)) {
        final reason = _getRoomUnavailableReason(_selectedRoom!, startDateTime, endDateTime);
        _showErrorDialog('Salón no disponible: ${reason ?? "conflicto de horario"}');
        return;
      }
    }

    // Validar capacidad si es presencial (capacidad exacta)
    if (_selectedModality == ModalityType.presential && _selectedRoom != null) {
      try {
        final maxAttendees = int.parse(_maxAttendeesController.text);
        if (maxAttendees > _selectedRoom!.capacity) {
          _showErrorDialog(
            'Capacidad insuficiente: ${maxAttendees} personas exceden la capacidad del salón (${_selectedRoom!.capacity})',
          );
          return;
        }
      } catch (e) {
        _showErrorDialog('Ingrese un número válido de asistentes');
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
          content: Text(widget.event == null ? 'Evento creado' : 'Evento actualizado',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: JenixColorsApp.successColor,
        ),
      );
    } else {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final dialogBg = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.backgroundWhite;
      final textColor = isDark ? Colors.white : JenixColorsApp.darkColorText;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: dialogBg,
          title: Text('Error', style: TextStyle(color: isDark ? Colors.white : JenixColorsApp.darkColorText, fontWeight: FontWeight.bold)),
          content: Text(res.left.toString(), style: TextStyle(color: textColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: TextStyle(color: JenixColorsApp.errorColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.backgroundWhite;
    final textColor = isDark ? Colors.white : JenixColorsApp.darkColorText;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Error', style: TextStyle(color: isDark ? Colors.white : JenixColorsApp.darkColorText, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: JenixColorsApp.errorColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? JenixColorsApp.surfaceColor.withOpacity(0.95) : JenixColorsApp.backgroundWhite;
    final titleColor = isDark ? Colors.white : JenixColorsApp.darkColorText;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: dialogBg,
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
                    style: TextStyle(
                        color: titleColor, fontWeight: FontWeight.bold, fontSize: 22),
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
                        Text(
                          'Seleccionar Fechas',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : JenixColorsApp.darkColorText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Calendario para fecha inicial
                        _buildDatePickerButton(
                          label: 'Fecha Inicio',
                          date: _initialDate,
                          onTap: _submitting
                              ? null
                              : () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _initialDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: JenixColorsApp.accentColor,
                                          onPrimary: Colors.white,
                                          surface: Color(0xFF2C2C2C),
                                          onSurface: Colors.white,
                                        ),
                                        dialogBackgroundColor: Color(0xFF1A1A1A),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _initialDate = date;
                                      if (_finalDate != null && date.isAfter(_finalDate!)) {
                                        _finalDate = date.add(const Duration(hours: 1));
                                      }
                                    });
                                  }
                                },
                        ),
                        const SizedBox(height: 12),
                        // Calendario para fecha final
                        _buildDatePickerButton(
                          label: 'Fecha Fin',
                          date: _finalDate,
                          onTap: _submitting
                              ? null
                              : () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _finalDate ?? (_initialDate?.add(const Duration(hours: 1)) ?? DateTime.now()),
                                    firstDate: _initialDate ?? DateTime(2020),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: JenixColorsApp.accentColor,
                                          onPrimary: Colors.white,
                                          surface: Color(0xFF2C2C2C),
                                          onSurface: Colors.white,
                                        ),
                                        dialogBackgroundColor: Color(0xFF1A1A1A),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() => _finalDate = date);
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                        // Horas
                        Text(
                          'Seleccionar Horas',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : JenixColorsApp.darkColorText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePickerButton(
                                label: 'Hora Inicio',
                                time: _beginTime,
                                onTap: _submitting
                                    ? null
                                    : () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _beginTime ?? TimeOfDay.now(),
                                          builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: JenixColorsApp.accentColor,
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF2C2C2C),
                                                onSurface: Colors.white,
                                              ),
                                            ),
                                            child: child!,
                                          ),
                                        );
                                        if (time != null) {
                                          setState(() => _beginTime = time);
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimePickerButton(
                                label: 'Hora Fin',
                                time: _endTime,
                                onTap: _submitting
                                    ? null
                                    : () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _endTime ?? TimeOfDay.now(),
                                          builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: JenixColorsApp.accentColor,
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF2C2C2C),
                                                onSurface: Colors.white,
                                              ),
                                            ),
                                            child: child!,
                                          ),
                                        );
                                        if (time != null) {
                                          setState(() => _endTime = time);
                                        }
                                      },
                              ),
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
                            validatorMsg: "Ingrese un número válido mayor a 0",
                            keyboard: TextInputType.number,
                            enabled: !_submitting,
                            onChanged: (_) => setState(() {}),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Ingrese el número máximo de asistentes";
                              }
                              try {
                                final num = int.parse(v);
                                if (num <= 0) {
                                  return "El número debe ser mayor a 0";
                                }
                              } catch (e) {
                                return "Ingrese un número válido";
                              }
                              return null;
                            },
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
            color: JenixColorsApp.errorColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JenixColorsApp.errorColor, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_busy, color: JenixColorsApp.errorColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  unavailableReason ?? 'Salón no disponible en ese horario',
                  style: const TextStyle(color: JenixColorsApp.errorColor, fontSize: 12),
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
              color: JenixColorsApp.errorColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JenixColorsApp.errorColor, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: JenixColorsApp.errorColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Capacidad insuficiente: ${maxAttendees} > ${roomCapacity}',
                    style: const TextStyle(color: JenixColorsApp.errorColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else if (maxAttendees == roomCapacity) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: JenixColorsApp.warningColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JenixColorsApp.warningColor, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: JenixColorsApp.warningColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Capacidad exacta: ${roomCapacity} personas',
                    style: const TextStyle(color: JenixColorsApp.warningColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: JenixColorsApp.successColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JenixColorsApp.successColor, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: JenixColorsApp.successColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Disponible - Capacidad: ${maxAttendees}/${roomCapacity}',
                    style: const TextStyle(color: JenixColorsApp.successColor, fontSize: 12),
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
            color: JenixColorsApp.infoColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JenixColorsApp.infoColor, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: JenixColorsApp.infoColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sin límite de asistentes. Salón: ${roomCapacity} (resto virtual)',
                  style: const TextStyle(color: JenixColorsApp.infoColor, fontSize: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? JenixColorsApp.primaryColor.withOpacity(0.3) : JenixColorsApp.backgroundLightGray;
    final borderColor = isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required DateTime? date,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? JenixColorsApp.primaryColor.withOpacity(0.3) : JenixColorsApp.backgroundLightGray;
    final borderColor = onTap == null 
        ? (isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder)
        : JenixColorsApp.accentColor.withOpacity(0.4);
    final iconColor = onTap == null 
        ? (isDark ? Colors.white30 : JenixColorsApp.lightGray)
        : JenixColorsApp.accentColor;
    final labelColor = isDark ? Colors.white70 : JenixColorsApp.subtitleColor;
    final dateTextColor = onTap == null 
        ? (isDark ? Colors.white30 : JenixColorsApp.lightGray)
        : (isDark ? Colors.white : JenixColorsApp.darkColorText);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Seleccionar',
                    style: TextStyle(
                      color: dateTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? JenixColorsApp.primaryColor.withOpacity(0.3) : JenixColorsApp.backgroundLightGray;
    final borderColor = onTap == null 
        ? (isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder)
        : JenixColorsApp.accentColor.withOpacity(0.4);
    final iconColor = onTap == null 
        ? (isDark ? Colors.white30 : JenixColorsApp.lightGray)
        : JenixColorsApp.accentColor;
    final labelColor = isDark ? Colors.white70 : JenixColorsApp.subtitleColor;
    final timeTextColor = onTap == null 
        ? (isDark ? Colors.white30 : JenixColorsApp.lightGray)
        : (isDark ? Colors.white : JenixColorsApp.darkColorText);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: iconColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  time != null ? time.format(context) : '--:--',
                  style: TextStyle(
                    color: timeTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = enabled 
        ? (isDark ? JenixColorsApp.primaryColor.withOpacity(0.3) : JenixColorsApp.backgroundLightGray)
        : (isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder);
    final labelColor = enabled ? (isDark ? Colors.white70 : JenixColorsApp.subtitleColor) : JenixColorsApp.lightGray;
    final inputTextColor = isDark ? Colors.white : JenixColorsApp.darkColorText;
    const accentColor = JenixColorsApp.accentColor;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboard ?? TextInputType.text,
      onChanged: onChanged,
      style: TextStyle(color: inputTextColor),
      validator: validator ?? (validatorMsg != null
          ? (v) => v == null || v.isEmpty ? validatorMsg : null
          : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: icon != null ? Icon(icon, color: accentColor) : null,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: JenixColorsApp.errorColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = enabled 
        ? (isDark ? JenixColorsApp.primaryColor.withOpacity(0.3) : JenixColorsApp.backgroundLightGray)
        : (isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder);
    final labelColor = enabled ? (isDark ? Colors.white70 : JenixColorsApp.subtitleColor) : JenixColorsApp.lightGray;
    const accentColor = JenixColorsApp.accentColor;

    return DropdownButtonFormField<T>(
      value: value,
      onChanged: enabled ? onChanged : null,
      style: TextStyle(color: isDark ? Colors.white : JenixColorsApp.darkColorText),
      dropdownColor: isDark ? JenixColorsApp.primaryColor.withOpacity(0.5) : JenixColorsApp.backgroundLightGray,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 1.4),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  displayLabel != null ? displayLabel(e) : e.toString(),
                  style: TextStyle(color: isDark ? Colors.white : JenixColorsApp.darkColorText),
                ),
              ))
          .toList(),
    );
  }
}

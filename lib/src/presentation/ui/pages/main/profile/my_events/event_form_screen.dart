import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/organization_area_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/my_events/widgets/event_form_widgets.dart';

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

  OrganizationAreaEnum? _selectedOrganizationArea;
  ModalityType? _selectedModality;

  DateTime? _initialDate;
  TimeOfDay? _beginTime;
  DateTime? _finalDate;
  TimeOfDay? _endTime;

  bool _submitting = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

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
    _selectedOrganizationArea = widget.event != null 
        ? OrganizationAreaEnum.fromString(widget.event!.organizationArea)
        : OrganizationAreaEnum.allFaculties;
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
      // Ignorar eventos inactivos
      if (!event.isActive) return false;

      if (widget.event != null) {
        final currentId = widget.event!.id.toString().trim();
        final eventId = event.id.toString().trim();
        if (currentId == eventId) return false; // Excluir el evento actual por ID
        
        // Exclusión adicional por si los IDs fallan (mismo nombre y fechas originales)
        if (event.name == widget.event!.name && 
            event.initialDate.isAtSameMomentAs(widget.event!.initialDate)) {
          return false;
        }
      }
      return event.room?.id == room.id; // Solo eventos en este salón (validar que room no sea nulo)
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
      // Ignorar eventos inactivos
      if (!event.isActive) return false;

      if (widget.event != null) {
        final currentId = widget.event!.id.toString().trim();
        final eventId = event.id.toString().trim();
        if (currentId == eventId) return false;

        // Exclusión adicional por si los IDs fallan
        if (event.name == widget.event!.name && 
            event.initialDate.isAtSameMomentAs(widget.event!.initialDate)) {
          return false;
        }
      }
      if (event.room?.id != room.id) return false; // Validar que room no sea nulo
      
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
            if (widget.event != null && widget.event!.room != null) {
              _selectedRoom = _rooms.firstWhere(
                (r) => r.id == widget.event!.room!.id,
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
      // Verificar si es el mismo salón que ya tenía el evento (si es edición)
      bool isSameRoom = false;
      if (widget.event != null && widget.event!.room != null) {
        // Comparación robusta de IDs
        if (widget.event!.room!.id.toString().trim() == _selectedRoom!.id.toString().trim()) {
          isSameRoom = true;
        }
      }

      // Si es el mismo salón, NO validamos disponibilidad (petición explícita para permitir actualizar)
      // Si es un salón diferente, o es un evento nuevo, sí validamos.
      if (!isSameRoom) {
        if (!_isRoomAvailable(_selectedRoom!, startDateTime, endDateTime)) {
          final reason = _getRoomUnavailableReason(_selectedRoom!, startDateTime, endDateTime);
          _showErrorDialog('Salón no disponible: ${reason ?? "conflicto de horario"}');
          return;
        }
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
            organizationArea: _selectedOrganizationArea?.displayName ?? OrganizationAreaEnum.allFaculties.displayName,
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
            roomId: (_selectedModality == ModalityType.presential || _selectedModality == ModalityType.hybrid) ? _selectedRoom!.id : null,
            organizationArea: _selectedOrganizationArea?.displayName ?? OrganizationAreaEnum.allFaculties.displayName,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Sección Modalidad (PRIMERA)
                  EventFormInfoCard(
                    child: Column(
                      children: [
                        EventFormDropdown<ModalityType>(
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
                  EventFormInfoCard(
                    child: Column(
                      children: [
                        EventFormTextField(
                            controller: _nameController,
                            label: "Nombre",
                            icon: Icons.event,
                            validatorMsg: "Ingrese un nombre",
                            enabled: !_submitting),
                        const SizedBox(height: 16),
                        EventFormTextField(
                            controller: _descriptionController,
                            label: "Descripción",
                            icon: Icons.description,
                            validatorMsg: "Ingrese una descripción",
                            enabled: !_submitting),
                        const SizedBox(height: 16),
                        EventFormTextField(
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
                  EventFormInfoCard(
                    child: Column(
                      children: [
                        const Text(
                          'Seleccionar Rango de Fechas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Rango de fechas
                        EventFormDateRangePickerButton(
                          initialDate: _initialDate,
                          finalDate: _finalDate,
                          onTap: _submitting
                              ? null
                              : () async {
                                  final isDark =
                                      Theme.of(context).brightness ==
                                          Brightness.dark;

                                  final DateTimeRange? picked =
                                      await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    currentDate: DateTime.now(),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme(
                                          brightness: isDark
                                              ? Brightness.dark
                                              : Brightness.light,
                                          primary: JenixColorsApp.primaryBlue,
                                          onPrimary: Colors.white,
                                          secondary: JenixColorsApp.primaryBlue,
                                          onSecondary: Colors.white,
                                          tertiary:
                                              JenixColorsApp.primaryBlueLight,
                                          surface: isDark
                                              ? JenixColorsApp.surfaceColor
                                              : JenixColorsApp.backgroundWhite,
                                          onSurface: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          outline: isDark
                                              ? Colors.white24
                                              : Colors.black12,
                                          outlineVariant: isDark
                                              ? JenixColorsApp.lightGrayBorder
                                              : Colors.black26,
                                          error: JenixColorsApp.errorColor,
                                          onError: Colors.white,
                                          errorContainer:
                                              JenixColorsApp.errorLight,
                                          onErrorContainer:
                                              JenixColorsApp.errorColor,
                                          scrim: Colors.black,
                                        ),
                                        dialogBackgroundColor: isDark
                                            ? JenixColorsApp.backgroundColor
                                            : JenixColorsApp.backgroundWhite,
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _initialDate = picked.start;
                                      _finalDate = picked.end;
                                    });
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                        // Horas
                        const Text(
                          'Seleccionar Horas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: EventFormTimePickerButton(
                                label: 'Hora Inicio',
                                time: _beginTime,
                                onTap: _submitting
                                    ? null
                                    : () async {
                                        final isDark =
                                            Theme.of(context).brightness ==
                                                Brightness.dark;

                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _beginTime ?? TimeOfDay.now(),
                                          builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme(
                                                brightness: isDark
                                                    ? Brightness.dark
                                                    : Brightness.light,
                                                primary:
                                                    JenixColorsApp.primaryBlue,
                                                onPrimary: Colors.white,
                                                secondary:
                                                    JenixColorsApp.primaryBlue,
                                                onSecondary: Colors.white,
                                                tertiary: JenixColorsApp
                                                    .primaryBlueLight,
                                                surface: isDark
                                                    ? JenixColorsApp
                                                        .surfaceColor
                                                    : JenixColorsApp
                                                        .backgroundWhite,
                                                onSurface: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                outline: isDark
                                                    ? Colors.white24
                                                    : Colors.black12,
                                                outlineVariant: isDark
                                                    ? JenixColorsApp
                                                        .lightGrayBorder
                                                    : Colors.black26,
                                                error:
                                                    JenixColorsApp.errorColor,
                                                onError: Colors.white,
                                                errorContainer:
                                                    JenixColorsApp.errorLight,
                                                onErrorContainer:
                                                    JenixColorsApp.errorColor,
                                                scrim: Colors.black,
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
                              child: EventFormTimePickerButton(
                                label: 'Hora Fin',
                                time: _endTime,
                                onTap: _submitting
                                    ? null
                                    : () async {
                                        final isDark =
                                            Theme.of(context).brightness ==
                                                Brightness.dark;

                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _endTime ?? TimeOfDay.now(),
                                          builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme(
                                                brightness: isDark
                                                    ? Brightness.dark
                                                    : Brightness.light,
                                                primary:
                                                    JenixColorsApp.primaryBlue,
                                                onPrimary: Colors.white,
                                                secondary:
                                                    JenixColorsApp.primaryBlue,
                                                onSecondary: Colors.white,
                                                tertiary: JenixColorsApp
                                                    .primaryBlueLight,
                                                surface: isDark
                                                    ? JenixColorsApp
                                                        .surfaceColor
                                                    : JenixColorsApp
                                                        .backgroundWhite,
                                                onSurface: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                outline: isDark
                                                    ? Colors.white24
                                                    : Colors.black12,
                                                outlineVariant: isDark
                                                    ? JenixColorsApp
                                                        .lightGrayBorder
                                                    : Colors.black26,
                                                error:
                                                    JenixColorsApp.errorColor,
                                                onError: Colors.white,
                                                errorContainer:
                                                    JenixColorsApp.errorLight,
                                                onErrorContainer:
                                                    JenixColorsApp.errorColor,
                                                scrim: Colors.black,
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
                  EventFormInfoCard(
                    child: Column(
                      children: [
                        EventFormTextField(
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
                        EventFormDropdown<OrganizationAreaEnum>(
                          value: _selectedOrganizationArea,
                          label: "Área Organizacional",
                          items: OrganizationAreaEnum.values,
                          onChanged: (v) =>
                              setState(() => _selectedOrganizationArea = v),
                          displayLabel: (area) => area.displayName,
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sección Salón (SI ES PRESENCIAL O HÍBRIDO)
                  if (_selectedModality == ModalityType.presential ||
                      _selectedModality == ModalityType.hybrid)
                    EventFormInfoCard(
                      child: Column(
                        children: [
                          _loadingRooms
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFBE1723)),
                                  ),
                                )
                              : _getAvailableRooms().isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD32F2F)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFD32F2F),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.event_busy,
                                            color: Color(0xFFD32F2F),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'No hay salones disponibles para este horario',
                                              style: const TextStyle(
                                                color: Color(0xFFD32F2F),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : EventFormDropdown<RoomEntity>(
                                      value: _getAvailableRooms()
                                              .contains(_selectedRoom)
                                          ? _selectedRoom
                                          : null,
                                      label: "Salón",
                                      items: _getAvailableRooms(),
                                      onChanged: (v) =>
                                          setState(() => _selectedRoom = v),
                                      displayLabel: (r) =>
                                          '${r.type} (Cap: ${r.capacity})',
                                      enabled: !_submitting,
                                    ),
                          if (_selectedRoom != null &&
                              _maxAttendeesController.text.isNotEmpty)
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
                        onPressed:
                            _submitting ? null : () => Navigator.pop(context),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color:
                                _submitting ? Colors.white30 : Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _submitting
                              ? Colors.grey
                              : const Color(0xFFBE1723),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
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
    List<RoomEntity> availableRooms = [];
    if (_maxAttendeesController.text.isEmpty) {
      availableRooms = _rooms;
    } else {
      try {
        final maxAttendees = int.parse(_maxAttendeesController.text);
        
        // Si no tenemos fechas/horarios completos, no podemos filtrar por disponibilidad
        if (_initialDate == null || _finalDate == null || _beginTime == null || _endTime == null) {
          // Solo filtrar por capacidad
          if (_selectedModality == ModalityType.presential) {
            availableRooms = _rooms.where((room) => room.capacity >= maxAttendees).toList();
          } else {
            availableRooms = _rooms;
          }
        } else {
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
            availableRooms = _rooms.where((room) {
              final hasCapacity = room.capacity >= maxAttendees;
              final isAvailable = _isRoomAvailable(room, startDateTime, endDateTime);
              return hasCapacity && isAvailable;
            }).toList();
          } 
          // Para híbrido: mostrar todos pero con indicador de disponibilidad
          else {
            availableRooms = _rooms.where((room) {
              final isAvailable = _isRoomAvailable(room, startDateTime, endDateTime);
              return isAvailable;
            }).toList();
          }
        }
      } catch (e) {
        availableRooms = _rooms;
      }
    }

    // Asegurar que el salón seleccionado esté en la lista (para edición)
    if (_selectedRoom != null) {
      final isSelectedInList = availableRooms.any((r) => r.id == _selectedRoom!.id);
      if (!isSelectedInList) {
        // Verificar si existe en la lista general de salones
        final originalRoom = _rooms.where((r) => r.id == _selectedRoom!.id).firstOrNull;
        if (originalRoom != null) {
          return [...availableRooms, originalRoom];
        }
      }
    }
    
    return availableRooms;
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
      
      // Verificar si es el mismo salón que ya tenía el evento (si es edición)
      bool isSameRoom = false;
      if (widget.event != null && widget.event!.room != null) {
        if (widget.event!.room!.id.toString().trim() == _selectedRoom!.id.toString().trim()) {
          isSameRoom = true;
        }
      }
      
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

        // Si es el mismo salón, asumimos disponible (o usamos _isRoomAvailable si confiamos en él)
        // Para evitar alertas rojas falsas, si es el mismo salón, no mostramos error de disponibilidad
        if (!isSameRoom) {
          isAvailable = _isRoomAvailable(_selectedRoom!, startDateTime, endDateTime);
          if (!isAvailable) {
            unavailableReason = _getRoomUnavailableReason(_selectedRoom!, startDateTime, endDateTime);
          }
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

}
    
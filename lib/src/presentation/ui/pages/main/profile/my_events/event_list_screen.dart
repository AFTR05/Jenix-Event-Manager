import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/my_events/event_form_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/my_events/event_enrollments_dialog.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  List<EventEntity> _events = [];

  final dateFormat = DateFormat('dd MMM yyyy HH:mm');

  /// Calcula el tamaño responsivo de fuente
  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  /// Calcula el padding/tamaño responsivo
  double _getResponsiveDimension(double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _setProcessing(bool value) {
    if (mounted) setState(() => _isProcessing = value);
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final controller = ref.read(eventControllerProvider);
    final currentUser = ref.read(loginProviderProvider);
    final token = currentUser?.accessToken ?? '';
    final res = await controller.getAllEvents(token);
    if (mounted) {
      if (res.isRight) {
        // Filtrar solo eventos creados por el usuario autenticado
        final allEvents = List<EventEntity>.from(res.right);
        final userEvents = allEvents
            .where(
              (event) =>
                  (event.responsablePerson?.id ?? event.responsablePersonId) ==
                  currentUser?.id,
            )
            .toList();

        // Ordenar por fecha inicial (más próximos primero)
        userEvents.sort((a, b) => a.initialDate.compareTo(b.initialDate));

        setState(() => _events = userEvents);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando eventos: ${res.left}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _openForm({EventEntity? event}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EventFormDialog(event: event),
    );

    if (result == true) {
      _setProcessing(true);
      await Future.delayed(const Duration(milliseconds: 200));
      await _loadEvents();
      _setProcessing(false);
    }
  }

  void _deleteEvent(EventEntity event) async {
    _setProcessing(true);
    final controller = ref.read(eventControllerProvider);
    final token = ref.read(loginProviderProvider)?.accessToken ?? '';

    final res = await controller.deleteEvent(event.id, token);
    if (res.isRight && res.right == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento "${event.name}" eliminado')),
      );
      await _loadEvents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando evento: ${res.left}')),
      );
    }
    _setProcessing(false);
  }

  bool _isEventPassed(EventEntity event) {
    final now = DateTime.now();
    return now.isAfter(event.finalDate);
  }

  @override
  Widget build(BuildContext context) {
    // Tamaños responsivos
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? JenixColorsApp.backgroundColor
        : JenixColorsApp.backgroundWhite;
    final gradientStart = isDark
        ? JenixColorsApp.primaryColor
        : JenixColorsApp.infoLight;
    final gradientEnd = isDark
        ? JenixColorsApp.surfaceColor
        : JenixColorsApp.infoLight;

    final paddingMain = _getResponsiveDimension(16);
    final marginBottom = _getResponsiveDimension(16);
    final borderRadius = _getResponsiveDimension(18);
    final contentPadding = _getResponsiveDimension(12);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: SecondaryAppbarWidget(title: 'Gestion de Eventos'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : () => _openForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
        backgroundColor: JenixColorsApp.accentColor,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(paddingMain),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        JenixColorsApp.accentColor,
                      ),
                    ),
                  )
                : _events.isEmpty
                ? const Center(
                    child: Text(
                      'No hay eventos',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : _buildListView(
                    _events,
                    marginBottom,
                    borderRadius,
                    contentPadding,
                  ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    JenixColorsApp.accentColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(
    List<EventEntity> events,
    double marginBottom,
    double borderRadius,
    double contentPadding,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final titleFontSize = _getResponsiveFontSize(14);
        final subtitleFontSize = _getResponsiveFontSize(12);
        final smallTextFontSize = _getResponsiveFontSize(11);
        final imageSize = _getResponsiveDimension(60);

        return Container(
          margin: EdgeInsets.only(bottom: marginBottom),
          decoration: BoxDecoration(
            color: isDark
                ? JenixColorsApp.surfaceColor.withOpacity(0.9)
                : JenixColorsApp.backgroundWhite,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? Colors.white24 : JenixColorsApp.lightGrayBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(contentPadding),
            leading:
                (event.urlImage != null &&
                    event.urlImage!.isNotEmpty &&
                    event.urlImage != 'Por defecto')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.urlImage!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.event,
                        color: isDark
                            ? Colors.white70
                            : JenixColorsApp.subtitleColor,
                        size: imageSize * 0.6,
                      ),
                    ),
                  )
                : Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A2B44)
                          : JenixColorsApp.backgroundLightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event,
                      color: isDark
                          ? Colors.white70
                          : JenixColorsApp.subtitleColor,
                      size: imageSize * 0.6,
                    ),
                  ),
            title: Text(
              event.name,
              style: TextStyle(
                color: isDark ? Colors.white : JenixColorsApp.darkColorText,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Sala: ${event.room?.type ?? (event.modality.name == 'virtual' ? 'Virtual' : 'Por definir')}',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : JenixColorsApp.subtitleColor,
                    fontSize: subtitleFontSize,
                  ),
                ),
                Text(
                  'Área: ${event.organizationArea}',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : JenixColorsApp.subtitleColor,
                    fontSize: subtitleFontSize,
                  ),
                ),
                Text(
                  'Modalidad: ${event.modality.label}',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : JenixColorsApp.subtitleColor,
                    fontSize: subtitleFontSize,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Inicio: ${dateFormat.format(event.initialDate)}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : JenixColorsApp.darkColorText,
                          fontSize: smallTextFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fin: ${dateFormat.format(event.finalDate)}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : JenixColorsApp.darkColorText,
                          fontSize: smallTextFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              color: isDark
                  ? JenixColorsApp.surfaceColor
                  : JenixColorsApp.backgroundWhite,
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white70 : JenixColorsApp.subtitleColor,
              ),
              onSelected: (value) {
                if (value == 'edit' && !_isEventPassed(event)) {
                  _openForm(event: event);
                }
                if (value == 'delete') _deleteEvent(event);
                if (value == 'enrollments') {
                  showDialog(
                    context: context,
                    builder: (_) => EventEnrollmentsDialog(event: event),
                  );
                }
              },
              itemBuilder: (context) {
                final isPassed = _isEventPassed(event);
                final menuTextSize = _getResponsiveFontSize(13);
                return [
                  PopupMenuItem(
                    enabled: !isPassed,
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: isPassed
                              ? JenixColorsApp.lightGray
                              : (isDark
                                    ? Colors.white70
                                    : JenixColorsApp.accentColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Editar',
                          style: TextStyle(
                            color: isPassed
                                ? JenixColorsApp.lightGray
                                : (isDark
                                      ? Colors.white
                                      : JenixColorsApp.darkColorText),
                            fontSize: menuTextSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'enrollments',
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: isDark
                              ? JenixColorsApp.successColor
                              : JenixColorsApp.infoColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ver inscripciones',
                          style: TextStyle(
                            color: isDark
                                ? JenixColorsApp.successColor
                                : JenixColorsApp.infoColor,
                            fontSize: menuTextSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: isDark
                              ? JenixColorsApp.errorColor
                              : const Color(0xFFD32F2F),
                          size: _getResponsiveDimension(18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(
                            color: isDark
                                ? JenixColorsApp.errorColor
                                : const Color(0xFFD32F2F),
                            fontSize: menuTextSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }
}

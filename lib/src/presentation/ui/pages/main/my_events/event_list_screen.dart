import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/event/event_form_screen.dart';

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
    final token = ref.read(loginProviderProvider)?.accessToken ?? '';
    final res = await controller.getAllEvents(token);
    if (mounted) {
      if (res.isRight) {
        setState(() => _events = List<EventEntity>.from(res.right));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      appBar: SecondaryAppbarWidget(title: 'Gestion de Eventos'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : () => _openForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1723),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A2647), Color(0xFF09131E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? const Center(
                        child: Text('No hay eventos',
                            style: TextStyle(color: Colors.white70)),
                      )
                    : _buildListView(_events),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List<EventEntity> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12263F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: (event.urlImage != null && event.urlImage!.isNotEmpty && event.urlImage != 'Por defecto')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.urlImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.event,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2B44),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event, color: Colors.white70, size: 40),
                  ),
            title: Text(
              event.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sala: ${event.room.type}', style: const TextStyle(color: Colors.white70)),
                Text('Área: ${event.organizationArea}', style: const TextStyle(color: Colors.white70)),
                Text('Modalidad: ${event.modality.name}', style: const TextStyle(color: Colors.white70)),
                Text('Inicio: ${dateFormat.format(event.createdAt)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('Fin: ${dateFormat.format(event.initialDate)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            trailing: PopupMenuButton<String>(
              color: const Color(0xFF12263F),
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                if (value == 'edit') _openForm(event: event);
                if (value == 'delete') _deleteEvent(event);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white70),
                      SizedBox(width: 8),
                      Text('Editar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Color(0xFFBE1723)),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Color(0xFFBE1723))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

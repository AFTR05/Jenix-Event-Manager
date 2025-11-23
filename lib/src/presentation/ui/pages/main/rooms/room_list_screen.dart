import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/room_status_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/rooms/room_form_screen.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class RoomListScreen extends ConsumerStatefulWidget {
  const RoomListScreen({super.key});

  @override
  ConsumerState<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends ConsumerState<RoomListScreen> {
  final dateFormat = DateFormat('dd MMM yyyy');
  bool _isLoading = true;
  bool _isProcessing = false;
  List<RoomEntity> _rooms = [];

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

  @override
  void initState() {
    super.initState();
    _loadRooms(showLoading: true);
    _loadCampuses(); // Cargar campus para el formulario
  }

  Future<void> _loadRooms({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }
    
    final controller = ref.read(roomControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';
    
    print('🔄 Llamando al endpoint de rooms...');
    final res = await controller.getAllRooms(token);
    
    if (mounted) {
      if (res.isRight) {
        print('✅ Recibidos ${res.right.length} salones del backend');
        // Forzar rebuild limpiando primero la lista
        setState(() {
          if (showLoading) _isLoading = false;
          _rooms = [];
        });
        setState(() {
          _rooms = List<RoomEntity>.from(res.right);
        });
        print('✅ UI actualizada con ${_rooms.length} salones');
      } else {
        print('❌ Error al cargar salones: ${res.left}');
        setState(() {
          if (showLoading) _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCampuses() async {
    final campusController = ref.read(campusControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';
    await campusController.fetchAllAndCache(token);
  }

  void _setProcessing(bool processing) {
    if (mounted) {
      setState(() => _isProcessing = processing);
    }
  }

  void _openForm({RoomEntity? room}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => RoomFormDialog(room: room),
    );

    if (result == true) {
      // Si el formulario retornó true, recargar la lista
      _setProcessing(true);
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadRooms();
      _setProcessing(false);
    }
  }

  void _deleteRoom(RoomEntity room) async {
    _setProcessing(true);
    final roomController = ref.read(roomControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    try {
      print('🗑️ Eliminando salón: ${room.id}');
      final res = await roomController.deleteRoom(room.id, token);
      
      if (res.isRight && res.right == true) {
        print('✅ Salón eliminado: ${room.id}');
        await Future.delayed(const Duration(milliseconds: 300));
        await _loadRooms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Salón "${room.type}" eliminado exitosamente'),
            backgroundColor: const Color(0xFFBE1723),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        print('❌ Error al eliminar salón: ${res.left}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al eliminar salón'),
            backgroundColor: Color(0xFFBE1723),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } finally {
      _setProcessing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      appBar: SecondaryAppbarWidget(title: 'Gestion de Salones'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : () => _openForm(),
        backgroundColor: _isProcessing ? Colors.grey : const Color(0xFFBE1723),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo", style: TextStyle(color: Colors.white)),
      ),

      body: Stack(
        children: [
          // Fondo institucional
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A2647), Color(0xFF09131E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Lista de salones
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rooms.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay salones disponibles',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : _buildListView(_rooms),
          ),

          /// Overlay de carga durante operaciones (crear/actualizar/eliminar)
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List<RoomEntity> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final room = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12263F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: room.state == RoomStatusEnum.disponible
                  ? Colors.greenAccent.withOpacity(0.4)
                  : room.state == RoomStatusEnum.cerrado
                      ? Colors.redAccent.withOpacity(0.4)
                      : Colors.amberAccent.withOpacity(0.4),
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Icon(Icons.meeting_room, color: Colors.white.withOpacity(0.8), size: 28),
            ),
            title: Text(
              room.type,
              style: const TextStyle(
                color: Color(0xFFE6EEF5),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Capacidad: ${room.capacity}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                  Text("Campus: ${room.campus.name}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                  Text("Estado: ${_displayState(room.state)}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                  Text("Creado: ${dateFormat.format(room.createdAt)}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: const Color(0xFF12263F),
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                if (value == 'edit') {
                  _openForm(room: room);
                } else if (value == 'delete') {
                  _deleteRoom(room);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text("Editar", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Color(0xFFBE1723), size: 18),
                      SizedBox(width: 8),
                      Text("Eliminar", style: TextStyle(color: Color(0xFFBE1723))),
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

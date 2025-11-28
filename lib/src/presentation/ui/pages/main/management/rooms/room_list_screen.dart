import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/room_status_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/management/rooms/room_form_screen.dart';
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

  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1C2C) : Colors.white,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0A2647), const Color(0xFF09131E)]
                    : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Lista de salones
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : const Color(0xFF1976D2),
                      ),
                    ),
                  )
                : _rooms.isEmpty
                    ? Center(
                        child: Text(
                          'No hay salones disponibles',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: _getResponsiveFontSize(14),
                          ),
                        ),
                      )
                    : _buildListView(_rooms),
          ),

          /// Overlay de carga durante operaciones (crear/actualizar/eliminar)
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
                    ),
                    SizedBox(height: _getResponsiveDimension(16)),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final room = list[index];
        return Container(
          margin: EdgeInsets.only(bottom: _getResponsiveDimension(16)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12263F).withOpacity(0.9) : Colors.white.withOpacity(0.9),
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
              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              child: Icon(Icons.meeting_room, color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54, size: _getResponsiveDimension(28)),
            ),
            title: Text(
              room.type,
              style: TextStyle(
                color: isDark ? const Color(0xFFE6EEF5) : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: _getResponsiveFontSize(18),
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: _getResponsiveDimension(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Capacidad: ${room.capacity}", style: TextStyle(color: isDark ? const Color(0xFF9DA9B9) : Colors.black54, fontSize: _getResponsiveFontSize(12))),
                  Text("Campus: ${room.campus.name}", style: TextStyle(color: isDark ? const Color(0xFF9DA9B9) : Colors.black54, fontSize: _getResponsiveFontSize(12))),
                  Text("Estado: ${_displayState(room.state)}", style: TextStyle(color: isDark ? const Color(0xFF9DA9B9) : Colors.black54, fontSize: _getResponsiveFontSize(12))),
                  Text("Creado: ${dateFormat.format(room.createdAt)}", style: TextStyle(color: isDark ? const Color(0xFF9DA9B9) : Colors.black54, fontSize: _getResponsiveFontSize(12))),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: isDark ? const Color(0xFF12263F) : Colors.white,
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.black54),
              onSelected: (value) {
                if (value == 'edit') {
                  _openForm(room: room);
                } else if (value == 'delete') {
                  _deleteRoom(room);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: isDark ? Colors.white70 : Colors.black54, size: 18),
                      const SizedBox(width: 8),
                      Text("Editar", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Color(0xFFBE1723), size: 18),
                      const SizedBox(width: 8),
                      const Text("Eliminar", style: TextStyle(color: Color(0xFFBE1723))),
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

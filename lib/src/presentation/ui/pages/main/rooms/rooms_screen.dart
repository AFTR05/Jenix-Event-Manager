import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/rooms/room_form_screen.dart';

final List<Campus> dummyCampusList = [
  Campus(id: '1', name: 'Campus Central', state: 'Abierto', isActive: true, createdAt: DateTime(2023, 6, 12)),
  Campus(id: '2', name: 'Campus Norte', state: 'En mantenimiento', isActive: true, createdAt: DateTime(2024, 2, 18)),
];

final List<Room> dummyRoomList = [
  Room(
    id: '101',
    type: 'Sala de informática',
    capacity: 30,
    state: 'Abierto',
    campus: dummyCampusList[0],
    isActive: true,
    createdAt: DateTime(2023, 6, 10),
  ),
  Room(
    id: '102',
    type: 'Laboratorio de física',
    capacity: 20,
    state: 'En mantenimiento',
    campus: dummyCampusList[1],
    isActive: true,
    createdAt: DateTime(2024, 1, 12),
  ),
];

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final dateFormat = DateFormat('dd MMM yyyy');

  void _openForm({Room? room}) async {
    final result = await showDialog<Room>(
      context: context,
      barrierDismissible: true,
      builder: (_) => RoomFormDialog(room: room, campuses: dummyCampusList),
    );

    if (result != null) {
      setState(() {
        if (room == null) {
          dummyRoomList.add(result);
        } else {
          final index = dummyRoomList.indexWhere((r) => r.id == room.id);
          if (index != -1) dummyRoomList[index] = result;
        }
      });
    }
  }

  void _deleteRoom(Room room) {
    setState(() => dummyRoomList.removeWhere((r) => r.id == room.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Salón "${room.type}" eliminado'),
        backgroundColor: const Color(0xFFBE1723),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFFBE1723),
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
            child: ListView.builder(
              itemCount: dummyRoomList.length,
              itemBuilder: (context, index) {
                final room = dummyRoomList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12263F).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: room.state == 'Abierto'
                          ? Colors.greenAccent.withOpacity(0.4)
                          : room.state == 'Cerrado'
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
                          Text("Capacidad: ${room.capacity}",
                              style: const TextStyle(color: Color(0xFF9DA9B9))),
                          Text("Campus: ${room.campus.name}",
                              style: const TextStyle(color: Color(0xFF9DA9B9))),
                          Text("Estado: ${room.state}",
                              style: const TextStyle(color: Color(0xFF9DA9B9))),
                          Text("Creado: ${dateFormat.format(room.createdAt)}",
                              style: const TextStyle(color: Color(0xFF9DA9B9))),
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
            ),
          ),
        ],
      ),
    );
  }
}

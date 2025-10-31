import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/event/event_detail_screen.dart';

// === Datos de prueba (los puedes mover al provider luego) ===
final UserEntity demoUser = UserEntity(
  name: 'Ana Gómez',
  email: 'ana.gomez@example.com',
  phone: '555-1234',
  role: 'Organizadora',
);

final List<EventEntity> dummyEvents = [
  EventEntity(
    id: '1',
    name: 'Congreso de Innovación',
    date: DateTime(2025, 10, 30),
    beginHour: '09:00:00',
    endHour: '17:00:00',
    room: Room(
      id: 'R1',
      type: 'Auditorio',
      capacity: 300,
      state: 'Disponible',
      campus: Campus(
        id: 'C1',
        name: 'Campus Central',
        state: 'Abierto',
        isActive: true,
        createdAt: DateTime(2023, 6, 12),
      ),
      isActive: true,
      createdAt: DateTime.now(),
    ),
    organizationArea: 'Tecnología',
    description: 'Evento Internacional sobre Innovación y Tecnología.',
    state: 'Activo',
    responsablePerson: demoUser,
    modality: ModalityType.presential,
    maxAttendees: 150,
    urlImage: 'https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=800',
    isActive: true,
    createdAt: DateTime.now(),
  ),
];

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: JenixColorsApp.backgroundColor,
      padding: const EdgeInsets.all(20),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Text(
            'Eventos Disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...dummyEvents.map((event) => _buildEventCard(event, context)).toList(),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventEntity event, BuildContext context) {
    final statusColor = switch (event.state) {
      'Activo' => Colors.greenAccent,
      'En curso' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event, onNavTap: (index) {})),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: JenixColorsApp.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Image.network(
                event.urlImage,
                height: 130,
                width: 130,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white54, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${event.beginHour} - ${event.endHour}',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor),
                          color: statusColor.withOpacity(0.15),
                        ),
                        child: Text(
                          event.state,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

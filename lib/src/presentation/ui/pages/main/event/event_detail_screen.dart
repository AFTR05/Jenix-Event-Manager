import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/widgets/bottom_nav_bar_widget.dart';

class EventDetailScreen extends StatelessWidget {
  final EventEntity event;
  final bool canRegister;
  final int currentIndex;
  final void Function(int) onNavTap;

  const EventDetailScreen({
    Key? key,
    required this.event,
    this.canRegister = true,
    this.currentIndex = 2,
    required this.onNavTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (event.state) {
      'Activo' => Colors.greenAccent,
      'En curso' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0d1b2a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header con botón de volver y botón de inscripción
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canRegister)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Lógica de inscripción
                      },
                      icon: const Icon(Icons.event_available, color: Colors.white),
                      label: const Text(
                        "Inscribirme",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 10,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 🔹 Imagen fuera del contenedor principal
              _eventImageCard(event, isSquare: true),

              const SizedBox(height: 24),

              // 🔹 Contenedor de información
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                ),
                child: _infoColumns(event, statusColor),
              ),

              const SizedBox(height: 24),

              // 🔹 Descripción debajo
              _descriptionCard(event),
              const SizedBox(height: 80), // Espacio para footer
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventImageCard(EventEntity event, {bool isSquare = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        event.urlImage ?? 'https://via.placeholder.com/300',
        height: isSquare ? 250 : 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: isSquare ? 250 : 300,
          color: Colors.black26,
          child: const Icon(Icons.broken_image, size: 60, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _infoColumns(EventEntity event, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.calendar_today, "${event.date.toLocal()}".split(' ')[0]),
        const SizedBox(height: 8),
        _infoRow(Icons.access_time,
            "${event.beginHour.toString().padLeft(2, '0')}:${event.beginHour.toString().padLeft(2, '0')} - "
            "${event.endHour.toString().padLeft(2, '0')}:${event.endHour.toString().padLeft(2, '0')}"),
        const SizedBox(height: 8),
        _infoRow(Icons.location_on, event.room.type),
        const SizedBox(height: 8),
        _infoRow(Icons.wifi, event.modality.name),
        const SizedBox(height: 8),
        _infoRow(Icons.account_tree, event.organizationArea),
        const SizedBox(height: 8),
        _infoRow(Icons.person, event.responsablePerson.name),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            event.state,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _descriptionCard(EventEntity event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Descripción",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

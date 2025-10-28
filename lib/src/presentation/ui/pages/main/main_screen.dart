import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/modality_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/presentation/providers_ui/bottom_nav_bar_state.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/event/event_detail_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/profile_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/screens/schedule_screen.dart';

// === Colores institucionales ===
const Color primaryColor = Color(0xFF103e69);
const Color accentColor = Color(0xFFbe1723);
const Color backgroundColor = Color(0xFF0d1b2a);
const Color surfaceColor = Color(0xFF1b263b);
const Color textColor = Colors.white;

final UserEntity user1 = UserEntity(
  name: 'Carlos Pérez',
  email: 'carlos.perez@example.com',
  phone: '555-1234',
  role: 'Administrador',
);

final UserEntity user2 = UserEntity(
  name: 'Ana Gómez',
  email: 'ana.gomez@example.com',
  phone: '555-1234',
  role: 'Organizadora',
  
);

final UserEntity user3 = UserEntity(
  name: 'Luis Ramírez',
  email: 'luis.ramirez@example.com',
  phone: '555-1234',
  role: 'Asistente',
);

// === Datos quemados ===
final List<EventEntity> dummyEvents = [
  EventEntity(
    id: '1',
    name: 'Congreso de Innovación',
    organizationArea: 'Tecnología',
    description: 'Evento Internacional de Tecnología donde se presentan las últimas innovaciones.',
    beginHour: DateTime(2025, 10, 30, 9, 0),
    finishHour: DateTime(2025, 10, 30, 17, 0),
    status: 'Activo',
    date: DateTime(2025, 10, 30),
    campus: 'Auditorio Principal',
    responsible: user1,
    maxAttendees: 150,
    participants: [user2, user3],
    modality: ModalityType.presential,
    imageUrl: 'https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=800',
  ),
  EventEntity(
    id: '2',
    name: 'Jornada Académica',
    organizationArea: 'Ingeniería',
    description: 'Semana de la Ingeniería con conferencias y talleres prácticos.',
    beginHour: DateTime(2025, 11, 3, 14, 0),
    finishHour: DateTime(2025, 11, 3, 18, 0),
    status: 'En curso',
    date: DateTime(2025, 11, 3),
    campus: 'Sede Alcázar',
    responsible: user2,
    maxAttendees: 200,
    participants: [user1, user3],
    modality: ModalityType.hybrid,
    imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
  ),
  EventEntity(
    id: '3',
    name: 'Feria Empresarial',
    organizationArea: 'Negocios',
    description: 'Oportunidades Laborales y Networking con empresas destacadas.',
    beginHour: DateTime(2025, 11, 10, 10, 30),
    finishHour: DateTime(2025, 11, 10, 16, 30),
    status: 'Finalizado',
    date: DateTime(2025, 11, 10),
    campus: 'Sede Nogal',
    responsible: user3,
    maxAttendees: 100,
    participants: [user1, user2],
    modality: ModalityType.virtual,
    imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
  ),
];

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavBarStateProvider);

    final screens = [
      _buildHomeScreen(context),
      const ScheduleScreen(),
      _buildEventsScreen(context),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        child: screens[currentIndex],
      ),
      bottomNavigationBar: _buildAnimatedBottomNavBar(currentIndex),
    );
  }

  // === APP BAR ===
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 6,
      shadowColor: Colors.black87,
      title: const Row(
        children: [
          Icon(Icons.event_available, color: accentColor, size: 30),
          SizedBox(width: 10),
          Text(
            'Eventum',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: textColor),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: accentColor,
          child: Icon(Icons.person, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // === HOME SCREEN ===
  Widget _buildHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido a la plataforma 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Eventos principales',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ...dummyEvents.map((event) => _buildEventCard(event, context)).toList(),
        ],
      ),
    );
  }

  // === LISTADO DE EVENTOS ===
  Widget _buildEventsScreen(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: backgroundColor,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Text(
            'Listado de Eventos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...dummyEvents.map((e) => _buildEventCard(e, context)).toList(),
        ],
      ),
    );
  }

  // === TARJETA DE EVENTO (DISEÑO HORIZONTAL) ===
  Widget _buildEventCard(EventEntity event, BuildContext context) {
    final Color statusColor = switch (event.status) {
      'Activo' => Colors.greenAccent,
      'En curso' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, 5),
            blurRadius: 12,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event, currentIndex: 2, onNavTap: (index) {}),
            ),
          );
        },
        child: Row(
          children: [
            // === Imagen lateral ===
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
              child: Image.network(
                event.imageUrl ??
                    'https://via.placeholder.com/140x140.png?text=Sin+Imagen',
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  width: 140,
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image,
                      color: Colors.white54, size: 50),
                ),
              ),
            ),

            // === Contenido textual ===
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.white54, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date} • ${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          border: Border.all(color: statusColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.status,
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

  // === NAV BAR ANIMADO ===
  Widget _buildAnimatedBottomNavBar(int currentIndex) {
    const icons = [
      Icons.home_rounded,
      Icons.schedule_rounded,
      Icons.event_rounded,
      Icons.person_rounded,
    ];

    const labels = ['Inicio', 'Agenda', 'Eventos', 'Perfil'];

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => ref
                .read(bottomNavBarStateProvider.notifier)
                .select(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? accentColor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    icons[index],
                    color: isActive ? accentColor : Colors.white70,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: const TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Text(labels[index]),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

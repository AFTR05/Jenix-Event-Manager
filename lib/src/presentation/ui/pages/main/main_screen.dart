import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/presentation/providers_ui/bottom_nav_bar_state.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/event/event_list_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/screens/schedule_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/profile_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/campus/campus_list_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/rooms/rooms_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/widgets/bottom_nav_bar_widget.dart';

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
      const EventListScreen(), // ✅ ahora la lista de eventos está separada
      const ScheduleScreen(),
      const EventListScreen(),
      const ProfileScreen(),
      const RoomListScreen(),
      const CampusListScreen(),
    ];

    return Scaffold(
      backgroundColor: JenixColorsApp.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[currentIndex],
      ),
      bottomNavigationBar: BottomNavBarWidget(currentIndex: currentIndex),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: JenixColorsApp.surfaceColor,
      elevation: 6,
      title: const Row(
        children: [
          Icon(Icons.event_available, color: JenixColorsApp.accentColor, size: 28),
          SizedBox(width: 10),
          Text(
            'Eventum',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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

    final labels = [
      LocaleKeys.navLabelInicio.tr(),
      LocaleKeys.navLabelAgenda.tr(),
      LocaleKeys.navLabelEventos.tr(),
      LocaleKeys.navLabelPerfil.tr(),
    ];

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

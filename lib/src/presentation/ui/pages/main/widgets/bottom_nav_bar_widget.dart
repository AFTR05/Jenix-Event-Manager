import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/presentation/providers_ui/bottom_nav_bar_state.dart';

class BottomNavBarWidget extends ConsumerWidget {
  final int currentIndex;

  const BottomNavBarWidget({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const icons = [
      Icons.home_rounded,
      Icons.schedule_rounded,
      Icons.event_rounded,
      Icons.person_rounded,
      Icons.location_city_rounded,
      Icons.meeting_room_rounded,
    ];

    const labels = ['Inicio', 'Agenda', 'Eventos', 'Perfil', 'Campus', 'Salones'];

    return Container(
      decoration: BoxDecoration(
        color: JenixColorsApp.surfaceColor,
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
            onTap: () => ref.read(bottomNavBarStateProvider.notifier).select(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? JenixColorsApp.accentColor.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    icons[index],
                    color: isActive
                        ? JenixColorsApp.accentColor
                        : Colors.white70,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: const TextStyle(
                        color: JenixColorsApp.accentColor,
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

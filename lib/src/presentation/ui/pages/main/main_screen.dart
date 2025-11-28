import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/role_enum.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/providers_ui/bottom_nav_bar_state.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/events_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/my_events/event_list_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/management/management_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/screens/schedule_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/profile_screen.dart';
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
    final isAdmin = ref.read(loginProviderProvider)?.role == RoleEnum.admin;

    final screens = [
      const EventsScreen(),
      const ScheduleScreen(),
      if (isAdmin) const ManagementScreen(),
      const ProfileScreen(),
    ];
    
    // Validar que currentIndex sea válido para evitar RangeError
    final validIndex = currentIndex < screens.length ? currentIndex : 0;

    return Scaffold(
      backgroundColor: JenixColorsApp.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[validIndex],
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
          Icon(
            Icons.event_available,
            color: JenixColorsApp.accentColor,
            size: 28,
          ),
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
    );
  }
}

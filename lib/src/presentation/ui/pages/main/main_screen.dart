import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/presentation/providers_ui/bottom_nav_bar_state.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/screens/schedule_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/widgets/bottom_nav_bar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/profile/screens/profile_screen.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<Widget> _screens = [
    // Home Screen - Placeholder temporal
    Container(
      color: Colors.amber,
      child: Center(
        child: Text(
          LocaleKeys.fieldIsRequired.tr(),
          style: TextStyle(
            fontFamily: 'OpenSansHebrew',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    // Schedule Screen - Placeholder temporal
    ScheduleScreen(),
    // Events Screen - Placeholder temporal
    Container(
      color: Colors.green,
      child: Center(
        child: Text(
          LocaleKeys.fieldIsRequired.tr(),
          style: TextStyle(
            fontFamily: 'OpenSansHebrew',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    // Profile Screen - Implementado
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavBarStateProvider);

    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavBarStateProvider.notifier).select(index);
        },
      ),
    );
  }
}

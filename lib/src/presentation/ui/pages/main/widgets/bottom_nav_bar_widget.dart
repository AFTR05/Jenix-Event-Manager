import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/widgets/bottom_nav_bar_item_widget.dart';

/// BottomNavBarWidget - Alexander von Humboldt Event Manager
/// Bottom navigation bar principal con diseño Jenix
class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const BottomNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? JenixColorsApp.darkBackground 
            : JenixColorsApp.backgroundWhite,
        border: Border(
          top: BorderSide(
            color: isDark
                ? JenixColorsApp.darkGray
                : JenixColorsApp.lightGrayBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark 
                ? JenixColorsApp.shadowColor 
                : JenixColorsApp.grayColor).withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BottomNavItemWidget(
                currentIndex: currentIndex,
                onTap: onTap,
                iconPath: 'assets/images/icons/home_icon.svg',
                label: 'Home',
                index: 0,
              ),
              BottomNavItemWidget(
                currentIndex: currentIndex,
                onTap: onTap,
                iconPath: 'assets/images/icons/schedule_icon.svg',
                label: 'Schedule',
                index: 1,
              ),
              BottomNavItemWidget(
                currentIndex: currentIndex,
                onTap: onTap,
                iconPath: 'assets/images/icons/events_icon.svg',
                label: 'Events',
                index: 2,
              ),
              BottomNavItemWidget(
                currentIndex: currentIndex,
                onTap: onTap,
                iconPath: 'assets/images/icons/account_icon.svg',
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
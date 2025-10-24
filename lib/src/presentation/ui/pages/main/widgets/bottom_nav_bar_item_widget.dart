import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

/// BottomNavItemWidget - Alexander von Humboldt Event Manager
/// Item individual del bottom navigation bar con colores de marca
class BottomNavItemWidget extends StatelessWidget {
  const BottomNavItemWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.iconPath,
    required this.label,
    required this.index,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final String iconPath;
  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: (isDark 
              ? JenixColorsApp.primaryBlueLight 
              : JenixColorsApp.primaryBlue).withOpacity(0.1),
          highlightColor: (isDark 
              ? JenixColorsApp.primaryBlueLight 
              : JenixColorsApp.primaryBlue).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono con animación sutil
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: (isDark
                                  ? JenixColorsApp.primaryBlueLight
                                  : JenixColorsApp.primaryBlue)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? (isDark
                              ? JenixColorsApp.primaryBlueLight
                              : JenixColorsApp.primaryBlue)
                          : (isDark
                              ? JenixColorsApp.lightGray
                              : JenixColorsApp.grayColor),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Label con colores Jenix
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'OpenSansHebrew',
                    color: isSelected
                        ? (isDark
                            ? JenixColorsApp.primaryBlueLight
                            : JenixColorsApp.primaryBlue)
                        : (isDark
                            ? JenixColorsApp.lightGray
                            : JenixColorsApp.grayColor),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

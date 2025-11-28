import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class ScheduleTotalsCard extends StatelessWidget {
  final int totalEvents;

  const ScheduleTotalsCard({
    required this.totalEvents,
    super.key,
  });

  double _getResponsiveFontSize(double baseFontSize, double screenWidth) {
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension, double screenWidth) {
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerMargin = _getResponsiveDimension(16, screenWidth);
    final containerPadding = _getResponsiveDimension(16, screenWidth);
    final containerRadius = _getResponsiveDimension(16, screenWidth);

    return Container(
      margin: EdgeInsets.all(containerMargin),
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundLightGray,
        borderRadius: BorderRadius.circular(containerRadius),
        border: Border.all(
          color: isDark 
              ? JenixColorsApp.primaryBlue.withOpacity(0.2)
              : JenixColorsApp.primaryBlue.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : JenixColorsApp.primaryBlue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.event_rounded,
              iconColor: JenixColorsApp.primaryBlue,
              iconBgColor: isDark 
                  ? JenixColorsApp.primaryBlue.withOpacity(0.2)
                  : JenixColorsApp.primaryBlue.withOpacity(0.12),
              label: LocaleKeys.eventsThisWeek.tr(),
              value: '$totalEvents',
              valueColor: JenixColorsApp.primaryBlue,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final labelFontSize = _getResponsiveFontSize(12, screenWidth);
    final valueFontSize = _getResponsiveFontSize(18, screenWidth);
    final iconPadding = _getResponsiveDimension(10, screenWidth);
    final iconSize = _getResponsiveDimension(22, screenWidth);
    final iconRadius = _getResponsiveDimension(12, screenWidth);
    final spaceBetween = _getResponsiveDimension(12, screenWidth);
    final spaceBetweenRows = _getResponsiveDimension(4, screenWidth);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(iconRadius),
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
        SizedBox(width: spaceBetween),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark 
                      ? JenixColorsApp.lightGray
                      : JenixColorsApp.darkColorText,
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spaceBetweenRows),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                  fontSize: valueFontSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

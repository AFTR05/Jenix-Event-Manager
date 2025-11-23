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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? JenixColorsApp.primaryBlue.withOpacity(0.2)
              : JenixColorsApp.lightGrayBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : JenixColorsApp.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.event_rounded,
              iconColor: JenixColorsApp.primaryBlue,
              iconBgColor: isDark 
                  ? JenixColorsApp.primaryBlue.withOpacity(0.2)
                  : JenixColorsApp.infoLight,
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

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark 
                      ? JenixColorsApp.lightGray
                      : JenixColorsApp.subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/translations/locale_keys.g.dart';

class ScheduleHeaderWidget extends StatelessWidget {
  final DateTime currentWeekStart;
  final String dateRange;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onDatePicker;

  const ScheduleHeaderWidget({
    required this.currentWeekStart,
    required this.dateRange,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onDatePicker,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [JenixColorsApp.primaryBlueDark, JenixColorsApp.primaryBlue]
              : [JenixColorsApp.primaryBlue, JenixColorsApp.primaryBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: JenixColorsApp.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: Título y Mes
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JenixColorsApp.backgroundWhite.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_view_week_rounded,
                  color: JenixColorsApp.backgroundWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.scheduleTitle.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMMM yyyy', Localizations.localeOf(context).toString()).format(currentWeekStart),
                      style: TextStyle(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Fila 2: Controles (responsive)
          if (screenWidth > 600)
            // Modo tablet/desktop
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: JenixColorsApp.backgroundWhite.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: JenixColorsApp.backgroundWhite,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateRange,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildNavButton(Icons.chevron_left_rounded, onPreviousWeek),
                const SizedBox(width: 6),
                _buildNavButton(Icons.chevron_right_rounded, onNextWeek),
              ],
            )
          else
            // Modo móvil: apilado
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: onDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: JenixColorsApp.backgroundWhite.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: JenixColorsApp.backgroundWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateRange,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(Icons.chevron_left_rounded, onPreviousWeek),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Navegar',
                        style: TextStyle(
                          color: JenixColorsApp.backgroundWhite.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildNavButton(Icons.chevron_right_rounded, onNextWeek),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: JenixColorsApp.backgroundWhite.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: JenixColorsApp.backgroundWhite.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: JenixColorsApp.backgroundWhite,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

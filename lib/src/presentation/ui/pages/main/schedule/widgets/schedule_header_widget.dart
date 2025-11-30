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
    final titleFontSize = _getResponsiveFontSize(20, screenWidth);
    final subtitleFontSize = _getResponsiveFontSize(12, screenWidth);
    final buttonTextFontSize = _getResponsiveFontSize(13, screenWidth);
    final containerRadius = _getResponsiveDimension(10, screenWidth);
    final headerPadding = _getResponsiveDimension(16, screenWidth);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: headerPadding, horizontal: headerPadding),
      color: isDark ? JenixColorsApp.surfaceColor : JenixColorsApp.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: Título y Mes
          Row(
            children: [
              SizedBox(width: _getResponsiveDimension(12, screenWidth)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.scheduleTitle.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: _getResponsiveDimension(2, screenWidth)),
                    Text(
                      DateFormat('MMMM yyyy', Localizations.localeOf(context).toString()).format(currentWeekStart),
                      style: TextStyle(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.85),
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveDimension(14, screenWidth)),
          // Fila 2: Controles (responsive)
          if (screenWidth > 600)
            // Modo tablet/desktop
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDatePicker,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: _getResponsiveDimension(14, screenWidth), vertical: _getResponsiveDimension(10, screenWidth)),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(containerRadius),
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
                            size: _getResponsiveDimension(16, screenWidth),
                          ),
                          SizedBox(width: _getResponsiveDimension(8, screenWidth)),
                          Text(
                            dateRange,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonTextFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: _getResponsiveDimension(8, screenWidth)),
                _buildNavButton(Icons.chevron_left_rounded, onPreviousWeek, screenWidth),
                SizedBox(width: _getResponsiveDimension(6, screenWidth)),
                _buildNavButton(Icons.chevron_right_rounded, onNextWeek, screenWidth),
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
                    padding: EdgeInsets.symmetric(horizontal: _getResponsiveDimension(14, screenWidth), vertical: _getResponsiveDimension(12, screenWidth)),
                    decoration: BoxDecoration(
                      color: JenixColorsApp.backgroundWhite.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(containerRadius),
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
                          size: _getResponsiveDimension(18, screenWidth),
                        ),
                        SizedBox(width: _getResponsiveDimension(8, screenWidth)),
                        Text(
                          dateRange,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonTextFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: _getResponsiveDimension(10, screenWidth)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(Icons.chevron_left_rounded, onPreviousWeek, screenWidth),
                    SizedBox(width: _getResponsiveDimension(12, screenWidth)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: _getResponsiveDimension(12, screenWidth), vertical: _getResponsiveDimension(6, screenWidth)),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(_getResponsiveDimension(8, screenWidth)),
                      ),
                      child: Text(
                        'Navegar',
                        style: TextStyle(
                          color: JenixColorsApp.backgroundWhite.withOpacity(0.8),
                          fontSize: _getResponsiveFontSize(12, screenWidth),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: _getResponsiveDimension(12, screenWidth)),
                    _buildNavButton(Icons.chevron_right_rounded, onNextWeek, screenWidth),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: JenixColorsApp.backgroundWhite.withOpacity(0.12),
        borderRadius: BorderRadius.circular(_getResponsiveDimension(10, screenWidth)),
        border: Border.all(
          color: JenixColorsApp.backgroundWhite.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_getResponsiveDimension(10, screenWidth)),
          child: Padding(
            padding: EdgeInsets.all(_getResponsiveDimension(8, screenWidth)),
            child: Icon(
              icon,
              color: JenixColorsApp.backgroundWhite,
              size: _getResponsiveDimension(20, screenWidth),
            ),
          ),
        ),
      ),
    );
  }
}

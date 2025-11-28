import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/date_utils.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class ScheduleEventDetailsModal {
  static double _getResponsiveFontSize(double baseFontSize, double screenWidth) {
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  static double _getResponsiveDimension(double baseDimension, double screenWidth) {
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  static void show(
    BuildContext context, {
    required DateTime date,
    required List<dynamic> events,
    required bool isDark,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(date, isDark, screenWidth),
              Container(
                height: 1,
                color: isDark 
                    ? JenixColorsApp.darkGray.withOpacity(0.3)
                    : JenixColorsApp.lightGrayBorder,
              ),
              _buildEventsList(events, isDark, screenWidth),
              _buildCloseButton(context, screenWidth),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildHeader(DateTime date, bool isDark, double screenWidth) {
    final titleFontSize = _getResponsiveFontSize(24, screenWidth);
    final subtitleFontSize = _getResponsiveFontSize(14, screenWidth);
    final headerPadding = _getResponsiveDimension(20, screenWidth);
    final spaceBetween = _getResponsiveDimension(20, screenWidth);
    final spaceBetweenSmall = _getResponsiveDimension(4, screenWidth);

    return Padding(
      padding: EdgeInsets.all(headerPadding),
      child: Column(
        children: [
          Container(
            width: _getResponsiveDimension(40, screenWidth),
            height: _getResponsiveDimension(4, screenWidth),
            decoration: BoxDecoration(
              color: isDark 
                  ? JenixColorsApp.darkGray 
                  : JenixColorsApp.lightGrayBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: spaceBetween),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: isDark 
                  ? JenixColorsApp.backgroundWhite 
                  : JenixColorsApp.darkColorText,
            ),
          ),
          SizedBox(height: spaceBetweenSmall),
          Text(
            WeekdayUtils.getFullName(date.weekday),
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: isDark 
                  ? JenixColorsApp.lightGray 
                  : JenixColorsApp.subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEventsList(List<dynamic> events, bool isDark, double screenWidth) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      padding: EdgeInsets.symmetric(vertical: _getResponsiveDimension(12, screenWidth)),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventListItem(event, index, isDark, screenWidth);
      },
    );
  }

  static Widget _buildEventListItem(dynamic event, int index, bool isDark, double screenWidth) {
    final eventNameFontSize = _getResponsiveFontSize(15, screenWidth);
    final eventTimeFontSize = _getResponsiveFontSize(12, screenWidth);
    final numberFontSize = _getResponsiveFontSize(14, screenWidth);
    final containerMargin = EdgeInsets.symmetric(
      horizontal: _getResponsiveDimension(16, screenWidth),
      vertical: _getResponsiveDimension(8, screenWidth),
    );
    final containerPadding = _getResponsiveDimension(14, screenWidth);
    final containerRadius = _getResponsiveDimension(14, screenWidth);
    final numberBoxSize = _getResponsiveDimension(32, screenWidth);
    final numberBoxRadius = _getResponsiveDimension(8, screenWidth);

    return Container(
      margin: containerMargin,
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isDark 
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.backgroundWhite,
        borderRadius: BorderRadius.circular(containerRadius),
        border: Border.all(
          color: isDark
              ? JenixColorsApp.primaryBlue.withOpacity(0.2)
              : JenixColorsApp.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: numberBoxSize,
                height: numberBoxSize,
                decoration: BoxDecoration(
                  color: JenixColorsApp.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(numberBoxRadius),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: JenixColorsApp.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: numberFontSize,
                    ),
                  ),
                ),
              ),
              SizedBox(width: _getResponsiveDimension(12, screenWidth)),
              Expanded(
                child: Text(
                  event.name,
                  style: TextStyle(
                    fontSize: eventNameFontSize,
                    fontWeight: FontWeight.w600,
                    color: isDark 
                        ? JenixColorsApp.backgroundWhite 
                        : JenixColorsApp.darkColorText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveDimension(8, screenWidth)),
          if (event.beginHour != null || event.endHour != null)
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: _getResponsiveDimension(14, screenWidth),
                  color: isDark 
                      ? JenixColorsApp.lightGray 
                      : JenixColorsApp.subtitleColor,
                ),
                SizedBox(width: _getResponsiveDimension(6, screenWidth)),
                Text(
                  '${event.beginHour ?? '--:--'} - ${event.endHour ?? '--:--'}',
                  style: TextStyle(
                    fontSize: eventTimeFontSize,
                    color: isDark 
                        ? JenixColorsApp.lightGray 
                        : JenixColorsApp.subtitleColor,
                  ),
                ),
              ],
            ),
          if (event.room != null) ...[
            SizedBox(height: _getResponsiveDimension(6, screenWidth)),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: _getResponsiveDimension(14, screenWidth),
                  color: isDark 
                      ? JenixColorsApp.lightGray 
                      : JenixColorsApp.subtitleColor,
                ),
                SizedBox(width: _getResponsiveDimension(6, screenWidth)),
                Expanded(
                  child: Text(
                    event.room.name ?? 'Sala',
                    style: TextStyle(
                      fontSize: eventTimeFontSize,
                      color: isDark 
                          ? JenixColorsApp.lightGray 
                          : JenixColorsApp.subtitleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildCloseButton(BuildContext context, double screenWidth) {
    final buttonPadding = _getResponsiveDimension(20, screenWidth);
    final buttonVerticalPadding = _getResponsiveDimension(14, screenWidth);
    final buttonRadius = _getResponsiveDimension(12, screenWidth);
    final buttonTextFontSize = _getResponsiveFontSize(16, screenWidth);

    return Padding(
      padding: EdgeInsets.all(buttonPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: JenixColorsApp.primaryBlue,
            padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
          child: Text(
            'Cerrar',
            style: TextStyle(
              color: JenixColorsApp.backgroundWhite,
              fontSize: buttonTextFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/date_utils.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
class ScheduleEventDetailsModal {
  static void show(
    BuildContext context, {
    required DateTime date,
    required List<dynamic> events,
    required bool isDark,
  }) {
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
              _buildHeader(date, isDark),
              Container(
                height: 1,
                color: isDark 
                    ? JenixColorsApp.darkGray.withOpacity(0.3)
                    : JenixColorsApp.lightGrayBorder,
              ),
              _buildEventsList(events, isDark),
              _buildCloseButton(context),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildHeader(DateTime date, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark 
                  ? JenixColorsApp.darkGray 
                  : JenixColorsApp.lightGrayBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark 
                  ? JenixColorsApp.backgroundWhite 
                  : JenixColorsApp.darkColorText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            WeekdayUtils.getFullName(date.weekday),
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? JenixColorsApp.lightGray 
                  : JenixColorsApp.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEventsList(List<dynamic> events, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventListItem(event, index, isDark);
      },
    );
  }

  static Widget _buildEventListItem(dynamic event, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark 
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.backgroundLightGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JenixColorsApp.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: JenixColorsApp.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: JenixColorsApp.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.name,
                  style: TextStyle(
                    fontSize: 15,
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
          const SizedBox(height: 8),
          if (event.beginHour != null || event.endHour != null)
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isDark 
                      ? JenixColorsApp.lightGray 
                      : JenixColorsApp.subtitleColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${event.beginHour ?? '--:--'} - ${event.endHour ?? '--:--'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? JenixColorsApp.lightGray 
                        : JenixColorsApp.subtitleColor,
                  ),
                ),
              ],
            ),
          if (event.room != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: isDark 
                      ? JenixColorsApp.lightGray 
                      : JenixColorsApp.subtitleColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.room.name ?? 'Sala',
                    style: TextStyle(
                      fontSize: 12,
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

  static Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: JenixColorsApp.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Cerrar',
            style: TextStyle(
              color: JenixColorsApp.backgroundWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

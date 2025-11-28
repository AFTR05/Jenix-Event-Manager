import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/date_utils.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/screens/event_details_screen.dart';

class ScheduleDayItem extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final List<dynamic> events;
  final String Function(String) weekdayTranslator;

  const ScheduleDayItem({
    required this.date,
    required this.isToday,
    required this.events,
    required this.weekdayTranslator,
    super.key,
  });

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(BuildContext context, double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite;
    final mainTextColor = isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText;
    final hasEvents = events.isNotEmpty;
    final responsiveMargin = _getResponsiveDimension(context, 12);
    final responsivePadding = _getResponsiveDimension(context, 16);
    final responsiveRadius = _getResponsiveDimension(context, 20);

    return GestureDetector(
      onTap: hasEvents ? () => _handleEventsTap(context) : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsiveMargin, vertical: responsiveMargin),
        decoration: BoxDecoration(
          color: hasEvents 
              ? JenixColorsApp.primaryBlue.withOpacity(0.12)
              : (isToday 
                  ? JenixColorsApp.primaryBlue.withOpacity(0.05)
                  : cardColor),
          borderRadius: BorderRadius.circular(responsiveRadius),
          border: Border.all(
            color: hasEvents
                ? JenixColorsApp.primaryBlue.withOpacity(0.8)
                : (isToday
                    ? JenixColorsApp.primaryBlue.withOpacity(0.3)
                    : (isDark 
                        ? JenixColorsApp.darkGray.withOpacity(0.4)
                        : JenixColorsApp.lightGrayBorder)),
            width: hasEvents ? 2.5 : (isToday ? 1.5 : 1),
          ),
          boxShadow: hasEvents
              ? [
                  BoxShadow(
                    color: JenixColorsApp.primaryBlue.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: JenixColorsApp.primaryBlue.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isToday
                  ? [
                      BoxShadow(
                        color: JenixColorsApp.primaryBlue.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasEvents ? () => _handleEventsTap(context) : null,
            borderRadius: BorderRadius.circular(responsiveRadius),
            child: Padding(
              padding: EdgeInsets.all(responsivePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasEvents)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveDimension(context, 12),
                        vertical: _getResponsiveDimension(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.primaryBlue,
                        borderRadius: BorderRadius.circular(_getResponsiveDimension(context, 8)),
                        boxShadow: [
                          BoxShadow(
                            color: JenixColorsApp.primaryBlue.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '✓ Eventos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getResponsiveFontSize(context, 12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else if (isToday)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveDimension(context, 10),
                        vertical: _getResponsiveDimension(context, 6),
                      ),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(_getResponsiveDimension(context, 8)),
                      ),
                      child: Text(
                        'HOY',
                        style: TextStyle(
                          color: JenixColorsApp.primaryBlue,
                          fontSize: _getResponsiveFontSize(context, 11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  SizedBox(height: _getResponsiveDimension(context, 12)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateBox(context, mainTextColor, isDark),
                      SizedBox(width: _getResponsiveDimension(context, 16)),
                      Expanded(
                        child: _buildEventInfo(context, mainTextColor, isDark),
                      ),
                    ],
                  ),
                  if (hasEvents && events.length > 1) ...[
                    SizedBox(height: _getResponsiveDimension(context, 12)),
                    _buildEventTags(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox(BuildContext context, Color mainTextColor, bool isDark) {
    final boxSize = _getResponsiveDimension(context, 70);
    final fontSize28 = _getResponsiveFontSize(context, 28);
    final fontSize13 = _getResponsiveFontSize(context, 13);
    final boxRadius = _getResponsiveDimension(context, 16);

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        gradient: isToday
            ? LinearGradient(
                colors: [
                  JenixColorsApp.primaryBlue,
                  JenixColorsApp.primaryBlueLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isToday 
            ? null 
            : (isDark 
                ? JenixColorsApp.darkGray.withOpacity(0.5)
                : JenixColorsApp.infoLight),
        borderRadius: BorderRadius.circular(boxRadius),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: JenixColorsApp.primaryBlue.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: JenixColorsApp.primaryBlue.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: fontSize28,
              fontWeight: FontWeight.w900,
              color: isToday 
                  ? JenixColorsApp.backgroundWhite 
                  : Colors.white70,
            ),
          ),
          SizedBox(height: _getResponsiveDimension(context, 4)),
          Text(
            WeekdayUtils.getShortName(date.weekday, weekdayTranslator),
            style: TextStyle(
              fontSize: fontSize13,
              fontWeight: FontWeight.w800,
              color: isToday
                  ? JenixColorsApp.backgroundWhite
                  : Colors.white70,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo(BuildContext context, Color mainTextColor, bool isDark) {
    final hasEvents = events.isNotEmpty;
    final fontSize19 = _getResponsiveFontSize(context, 19);
    final fontSize15 = _getResponsiveFontSize(context, 15);
    final fontSize16 = _getResponsiveFontSize(context, 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hasEvents 
              ? '${events.length} evento${events.length > 1 ? 's' : ''}'
              : 'Sin eventos',
          style: TextStyle(
            color: hasEvents ? Colors.white : mainTextColor,
            fontWeight: hasEvents ? FontWeight.w900 : FontWeight.w700,
            fontSize: hasEvents ? fontSize19 : fontSize15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (hasEvents) ...[
          SizedBox(height: _getResponsiveDimension(context, 8)),
          Text(
            events.first.name,
            style: TextStyle(
              color: Colors.white70,
              fontSize: fontSize16,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ] else
          SizedBox(height: _getResponsiveDimension(context, 4)),
      ],
    );
  }

  Widget _buildEventTags(BuildContext context) {
    final fontSize11 = _getResponsiveFontSize(context, 11);
    final containerPadding = _getResponsiveDimension(context, 10);
    final borderRadius = _getResponsiveDimension(context, 20);
    final spacing = _getResponsiveDimension(context, 6);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: events.sublist(1).map((event) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: containerPadding, vertical: _getResponsiveDimension(context, 4)),
          decoration: BoxDecoration(
            color: JenixColorsApp.primaryBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: JenixColorsApp.primaryBlue.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            event.name,
            style: TextStyle(
              color: JenixColorsApp.primaryBlue,
              fontSize: fontSize11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  void _handleEventsTap(BuildContext context) {
    if (events.isEmpty) return;

    if (events.length == 1) {
      // Si hay solo un evento, ir directamente a la pantalla de detalles
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            event: events.first as EventEntity,
          ),
        ),
      );
    } else {
      // Si hay múltiples eventos, mostrar modal de selección
      _showEventsModal(context);
    }
  }

  void _showEventsModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleFontSize = _getResponsiveFontSize(context, 18);
    final subtitleFontSize = _getResponsiveFontSize(context, 13);
    final eventNameFontSize = _getResponsiveFontSize(context, 14);
    final eventTimeFontSize = _getResponsiveFontSize(context, 12);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark 
          ? JenixColorsApp.backgroundDark 
          : JenixColorsApp.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: _getResponsiveDimension(context, 16)),
              child: Container(
                width: _getResponsiveDimension(context, 40),
                height: _getResponsiveDimension(context, 4),
                decoration: BoxDecoration(
                  color: isDark 
                      ? JenixColorsApp.darkGray 
                      : JenixColorsApp.lightGrayBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _getResponsiveDimension(context, 16), vertical: _getResponsiveDimension(context, 8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos del día',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDark 
                          ? JenixColorsApp.backgroundWhite 
                          : JenixColorsApp.darkColorText,
                    ),
                  ),
                  SizedBox(height: _getResponsiveDimension(context, 4)),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: isDark 
                          ? JenixColorsApp.lightGray 
                          : JenixColorsApp.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _getResponsiveDimension(context, 8)),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: _getResponsiveDimension(context, 16)),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index] as EventEntity;
                  return Padding(
                    padding: EdgeInsets.only(bottom: _getResponsiveDimension(context, 8)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(
                                event: event,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(_getResponsiveDimension(context, 12)),
                        child: Container(
                          padding: EdgeInsets.all(_getResponsiveDimension(context, 12)),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? JenixColorsApp.darkGray.withOpacity(0.3)
                                : JenixColorsApp.infoLight,
                            borderRadius: BorderRadius.circular(_getResponsiveDimension(context, 12)),
                            border: Border.all(
                              color: JenixColorsApp.primaryBlue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _getResponsiveDimension(context, 8),
                                      vertical: _getResponsiveDimension(context, 4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: JenixColorsApp.primaryBlue,
                                      borderRadius: BorderRadius.circular(_getResponsiveDimension(context, 6)),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _getResponsiveFontSize(context, 12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: _getResponsiveDimension(context, 12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.name,
                                          style: TextStyle(
                                            fontSize: eventNameFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: isDark 
                                                ? JenixColorsApp.backgroundWhite 
                                                : JenixColorsApp.darkColorText,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: _getResponsiveDimension(context, 4)),
                                        if (event.beginHour != null)
                                          Text(
                                            '${event.beginHour} - ${event.endHour ?? ''}',
                                            style: TextStyle(
                                              fontSize: eventTimeFontSize,
                                              color: isDark 
                                                  ? JenixColorsApp.lightGray 
                                                  : JenixColorsApp.subtitleColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: _getResponsiveDimension(context, 8)),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: _getResponsiveDimension(context, 14),
                                    color: JenixColorsApp.primaryBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: _getResponsiveDimension(context, 16)),
          ],
        ),
      ),
    );
  }
}

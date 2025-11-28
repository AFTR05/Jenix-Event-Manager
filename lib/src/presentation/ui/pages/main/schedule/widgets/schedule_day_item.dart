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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite;
    final mainTextColor = isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText;
    final hasEvents = events.isNotEmpty;

    return GestureDetector(
      onTap: hasEvents ? () => _handleEventsTap(context) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: hasEvents 
              ? JenixColorsApp.primaryBlue.withOpacity(0.12)
              : (isToday 
                  ? JenixColorsApp.primaryBlue.withOpacity(0.05)
                  : cardColor),
          borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasEvents)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: JenixColorsApp.primaryBlue.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '✓ Eventos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HOY',
                        style: TextStyle(
                          color: JenixColorsApp.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateBox(mainTextColor, isDark),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEventInfo(mainTextColor, isDark),
                      ),
                    ],
                  ),
                  if (hasEvents && events.length > 1) ...[
                    const SizedBox(height: 12),
                    _buildEventTags(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox(Color mainTextColor, bool isDark) {
    return Container(
      width: 70,
      height: 70,
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
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isToday 
                  ? JenixColorsApp.backgroundWhite 
                  : Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            WeekdayUtils.getShortName(date.weekday, weekdayTranslator),
            style: TextStyle(
              fontSize: 13,
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

  Widget _buildEventInfo(Color mainTextColor, bool isDark) {
    final hasEvents = events.isNotEmpty;

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
            fontSize: hasEvents ? 19 : 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (hasEvents) ...[
          const SizedBox(height: 8),
          Text(
            events.first.name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ] else
          const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEventTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: events.sublist(1).map((event) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: JenixColorsApp.primaryBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: JenixColorsApp.primaryBlue.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            event.name,
            style: TextStyle(
              color: JenixColorsApp.primaryBlue,
              fontSize: 11,
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark 
                      ? JenixColorsApp.darkGray 
                      : JenixColorsApp.lightGrayBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos del día',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark 
                          ? JenixColorsApp.backgroundWhite 
                          : JenixColorsApp.darkColorText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark 
                          ? JenixColorsApp.lightGray 
                          : JenixColorsApp.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index] as EventEntity;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? JenixColorsApp.darkGray.withOpacity(0.3)
                                : JenixColorsApp.infoLight,
                            borderRadius: BorderRadius.circular(12),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: JenixColorsApp.primaryBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark 
                                                ? JenixColorsApp.backgroundWhite 
                                                : JenixColorsApp.darkColorText,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (event.beginHour != null)
                                          Text(
                                            '${event.beginHour} - ${event.endHour ?? ''}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark 
                                                  ? JenixColorsApp.lightGray 
                                                  : JenixColorsApp.subtitleColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
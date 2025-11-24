import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/core/helpers/date_utils.dart' as core_date_utils;
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/widgets/schedule_day_item.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/widgets/schedule_header_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/widgets/schedule_totals_card.dart';


class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime today;
  late DateTime currentWeekStart;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    final eventController = ref.read(eventControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    try {
      await eventController.fetchAll(token);
      print('✅ Eventos cargados: ${eventController.cache.length} eventos');
      for (var event in eventController.cache) {
        print('   - ${event.name} (${event.initialDate})');
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error al cargar eventos: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  DateTime get currentWeekEnd => currentWeekStart.add(const Duration(days: 6));

  void _previousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    });
  }

  List<dynamic> _getEventsForDate(DateTime date) {
    final eventController = ref.read(eventControllerProvider);
    final events = eventController.cache
        .where((event) {
          final eventStart = DateTime(event.initialDate.year, event.initialDate.month, event.initialDate.day);
          final eventEnd = DateTime(event.finalDate.year, event.finalDate.month, event.finalDate.day);
          final dateOnly = DateTime(date.year, date.month, date.day);
          return !dateOnly.isBefore(eventStart) && !dateOnly.isAfter(eventEnd);
        })
        .toList();
    return events;
  }

  int _getTotalEventsThisWeek() {
    final uniqueEventIds = <String>{};
    
    for (int i = 0; i < 7; i++) {
      final dateInWeek = currentWeekStart.add(Duration(days: i));
      final eventsForDay = _getEventsForDate(dateInWeek);
      for (var event in eventsForDay) {
        uniqueEventIds.add(event.id);
      }
    }
    
    return uniqueEventIds.length;
  }

  String _formatRange() {
    final start = currentWeekStart;
    final end = currentWeekEnd;
    return "${start.day}/${start.month} - ${end.day}/${end.month}";
  }

  Future<void> _openDatePicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selected = await showDatePicker(
      context: context,
      initialDate: currentWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: JenixColorsApp.primaryBlue,
              onPrimary: JenixColorsApp.backgroundWhite,
              surface: isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite,
              onSurface: isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        currentWeekStart = selected.subtract(Duration(days: selected.weekday - 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => currentWeekStart.add(Duration(days: i)));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? JenixColorsApp.darkBackground 
        : JenixColorsApp.backgroundLightGray;

    ref.watch(eventControllerProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ScheduleHeaderWidget(
              currentWeekStart: currentWeekStart,
              dateRange: _formatRange(),
              onPreviousWeek: _previousWeek,
              onNextWeek: _nextWeek,
              onDatePicker: _openDatePicker,
            ),
            ScheduleTotalsCard(
              totalEvents: _getTotalEventsThisWeek(),
            ),
            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: JenixColorsApp.primaryBlue,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final date = days[index];
                    final isToday = core_date_utils.DateUtils.isSameDay(date, today);
                    final events = _getEventsForDate(date);
                    
                    return ScheduleDayItem(
                      date: date,
                      isToday: isToday,
                      events: events,
                      weekdayTranslator: (key) {
                        const keys = {
                          'weekdayMon': 'Mon',
                          'weekdayTue': 'Tue',
                          'weekdayWed': 'Wed',
                          'weekdayThu': 'Thu',
                          'weekdayFri': 'Fri',
                          'weekdaySat': 'Sat',
                          'weekdaySun': 'Sun',
                        };
                        return keys[key] ?? key;
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
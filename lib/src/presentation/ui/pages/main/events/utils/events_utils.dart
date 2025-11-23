import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';

class EventsUtils {
  // Obtiene eventos disponibles desde ahora en adelante
  // (fecha fin >= ahora actual)
  // ordenados por fecha inicial
  static List<EventEntity> getActiveEvents(List<EventEntity> events) {
    final now = DateTime.now();

    final activeEvents = events
        .where((event) {
          if (!event.isActive) return false;
          
          // El evento está disponible si su fecha fin es >= ahora
          // Esto significa que aún no ha terminado
          return event.finalDate.isAfter(now) || 
                 event.finalDate.isAtSameMomentAs(now);
        })
        .toList();

    // Ordenar por fecha inicial
    activeEvents.sort((a, b) => a.initialDate.compareTo(b.initialDate));
    return activeEvents;
  }

  // Obtiene solo eventos desde hoy hacia el futuro
  static List<EventEntity> getUpcomingEvents(List<EventEntity> events) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final upcomingEvents = events
        .where((event) {
          final eventStart = DateTime(
            event.initialDate.year,
            event.initialDate.month,
            event.initialDate.day,
          );
          return !eventStart.isBefore(todayOnly);
        })
        .toList();

    // Ordenar por fecha inicial
    upcomingEvents.sort((a, b) => a.initialDate.compareTo(b.initialDate));
    return upcomingEvents;
  }

  static String formatMonthAbbr(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[month - 1];
  }

  static bool isDatesSeparator(EventEntity current, EventEntity? next) {
    if (next == null) return false;

    final currentDateOnly = DateTime(
      current.initialDate.year,
      current.initialDate.month,
      current.initialDate.day,
    );

    final nextDateOnly = DateTime(
      next.initialDate.year,
      next.initialDate.month,
      next.initialDate.day,
    );

    return currentDateOnly.compareTo(nextDateOnly) != 0;
  }
}

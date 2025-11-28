class DateUtils {
  /// Compara si dos DateTime son el mismo día (ignora horas, minutos, segundos)
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Retorna solo la fecha sin la hora
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Verifica si una fecha está dentro del rango de un evento (inclusive)
  /// Útil para eventos que duran varios días
  static bool isEventOnDate(DateTime date, DateTime eventStart, DateTime eventEnd) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final eventStartOnly = DateTime(eventStart.year, eventStart.month, eventStart.day);
    final eventEndOnly = DateTime(eventEnd.year, eventEnd.month, eventEnd.day);
    
    return !dateOnly.isBefore(eventStartOnly) && !dateOnly.isAfter(eventEndOnly);
  }

  /// Retorna el inicio de la semana (lunes) para una fecha dada
  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Retorna el fin de la semana (domingo) para una fecha dada
  static DateTime getWeekEnd(DateTime date) {
    final weekStart = getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }

  /// Verifica si una fecha está en la semana actual
  static bool isInCurrentWeek(DateTime date) {
    final today = DateTime.now();
    final weekStart = getWeekStart(today);
    final weekEnd = getWeekEnd(today);
    
    return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
  }

  /// Formatea una fecha como "dd/MM/yyyy"
  static String formatDateShort(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  /// Formatea un rango de fechas como "dd/MM - dd/MM"
  static String formatDateRange(DateTime start, DateTime end) {
    return "${start.day}/${start.month} - ${end.day}/${end.month}";
  }

  /// Retorna el número de días entre dos fechas (inclusive del primer día, exclusive del último)
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Verifica si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Verifica si una fecha es en el pasado
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Verifica si una fecha es en el futuro
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}

class WeekdayUtils {
  static String getShortName(int weekday, String Function(String) translator) {
    switch (weekday) {
      case 1:
        return translator('weekdayMon');
      case 2:
        return translator('weekdayTue');
      case 3:
        return translator('weekdayWed');
      case 4:
        return translator('weekdayThu');
      case 5:
        return translator('weekdayFri');
      case 6:
        return translator('weekdaySat');
      case 7:
      default:
        return translator('weekdaySun');
    }
  }

  static String getFullName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
      default:
        return 'Domingo';
    }
  }
}
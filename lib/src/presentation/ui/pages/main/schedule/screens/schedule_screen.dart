import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime today;
  late DateTime currentWeekStart;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
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

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_view_week_rounded,
                        color: JenixColorsApp.backgroundWhite,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule',
                            style: TextStyle(
                              color: JenixColorsApp.backgroundWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM yyyy', Localizations.localeOf(context).toString()).format(currentWeekStart),
                            style: TextStyle(
                              color: JenixColorsApp.backgroundWhite.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _openDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: JenixColorsApp.backgroundWhite.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: JenixColorsApp.backgroundWhite.withOpacity(0.2),
                          width: 1,
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
                          const SizedBox(width: 6),
                          Text(
                            _formatRange(),
                            style: TextStyle(
                              color: JenixColorsApp.backgroundWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _previousWeek,
                    icon: Icon(Icons.chevron_left_rounded, color: JenixColorsApp.backgroundWhite),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: JenixColorsApp.backgroundWhite.withOpacity(0.15),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _nextWeek,
                    icon: Icon(Icons.chevron_right_rounded, color: JenixColorsApp.backgroundWhite),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: JenixColorsApp.backgroundWhite.withOpacity(0.15),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
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
              label: 'Events this week',
              value: '3',
              valueColor: JenixColorsApp.primaryBlue,
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JenixColorsApp.lightGrayBorder.withOpacity(0.0),
                  JenixColorsApp.lightGrayBorder.withOpacity(0.6),
                  JenixColorsApp.lightGrayBorder.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.event_available_rounded,
              iconColor: JenixColorsApp.primaryBlueLight,
              iconBgColor: isDark
                  ? JenixColorsApp.primaryBlueLight.withOpacity(0.12)
                  : JenixColorsApp.infoLight,
              label: 'Upcoming events',
              value: '5',
              valueColor: JenixColorsApp.primaryBlueLight,
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

  Widget _buildDayItem(DateTime date, {bool isToday = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite;
    final mainTextColor = isDark ? JenixColorsApp.backgroundWhite : JenixColorsApp.darkColorText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? JenixColorsApp.primaryBlue.withOpacity(0.4)
              : (isDark 
                  ? JenixColorsApp.darkGray.withOpacity(0.5)
                  : JenixColorsApp.lightGrayBorder),
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: JenixColorsApp.primaryBlue.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Acción al tocar
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
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
                            ? JenixColorsApp.darkGray.withOpacity(0.4)
                            : JenixColorsApp.backgroundLightGray),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: JenixColorsApp.primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isToday 
                              ? JenixColorsApp.backgroundWhite 
                              : mainTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _weekdayShort(date.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? JenixColorsApp.backgroundWhite.withOpacity(0.9)
                              : (isDark 
                                  ? JenixColorsApp.lightGray
                                  : JenixColorsApp.subtitleColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: JenixColorsApp.primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TODAY',
                                style: TextStyle(
                                  color: JenixColorsApp.primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              isToday ? 'Your events today' : 'No events scheduled',
                              style: TextStyle(
                                color: mainTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to see details',
                        style: TextStyle(
                          color: isDark 
                              ? JenixColorsApp.lightGray
                              : JenixColorsApp.secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark 
                      ? JenixColorsApp.lightGray
                      : JenixColorsApp.grayColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7:
      default: return 'Sun';
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => currentWeekStart.add(Duration(days: i)));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? JenixColorsApp.darkBackground 
        : JenixColorsApp.backgroundLightGray;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTotalsCard(),
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
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final date = days[index];
                    final isToday = DateUtils.isSameDay(date, today);
                    return _buildDayItem(date, isToday: isToday);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
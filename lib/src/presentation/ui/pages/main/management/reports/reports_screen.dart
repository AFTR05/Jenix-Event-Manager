import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isLoading = true;
  String? _error;
  List<EventEntity> _events = [];
  List<EnrollmentEntity> _enrollments = [];

  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eventController = ref.read(eventControllerProvider);
      final enrollmentController = ref.read(enrollmentControllerProvider);
      final token = ref.read(loginProviderProvider)?.accessToken ?? '';

      if (token.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Token no disponible';
            _isLoading = false;
          });
        }
        return;
      }

      // Cargar eventos
      final eventsResult = await eventController.getAllEvents(token);
      eventsResult.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _error = 'Error al cargar eventos: $failure';
              _isLoading = false;
            });
          }
        },
        (events) async {
          _events = events;

          // Cargar todas las inscripciones
          final enrollmentsResult = await enrollmentController.getMyEnrollments(token);
          enrollmentsResult.fold(
            (failure) {
              if (mounted) {
                setState(() {
                  _error = 'Error al cargar inscripciones: $failure';
                  _isLoading = false;
                });
              }
            },
            (enrollments) {
              if (mounted) {
                setState(() {
                  _enrollments = enrollments;
                  _isLoading = false;
                });
              }
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A1929) : Colors.white;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: SecondaryAppbarWidget(title: 'Reportes y Estadísticas'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : const Color(0xFFBE1723),
                ),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: isDark ? Colors.white : Colors.red, size: _getResponsiveDimension(64)),
                      SizedBox(height: _getResponsiveDimension(16)),
                      Text(
                        'Error al cargar datos',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: _getResponsiveFontSize(16)),
                      ),
                      SizedBox(height: _getResponsiveDimension(8)),
                      Text(
                        _error ?? '',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: _getResponsiveFontSize(12)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: _getResponsiveDimension(24)),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE1723),
                        ),
                        child: const Text(
                          'Reintentar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(_getResponsiveDimension(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjetas KPI
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.event,
                              label: 'Total Eventos',
                              value: _events.length.toString(),
                              color: Colors.blue,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(width: _getResponsiveDimension(12)),
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.person_add,
                              label: 'Total Inscripciones',
                              value: _enrollments.length.toString(),
                              color: Colors.green,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: _getResponsiveDimension(16)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.calendar_today,
                              label: 'Eventos Activos',
                              value: _getActiveEventsCount().toString(),
                              color: Colors.orange,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(width: _getResponsiveDimension(12)),
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.check_circle,
                              label: 'Asistencias',
                              value: _getAttendedCount().toString(),
                              color: Colors.purple,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: _getResponsiveDimension(24)),
                      // Gráfico de pastel - Estado de Inscripciones
                      _buildEnrollmentPieChart(isDark),
                      SizedBox(height: _getResponsiveDimension(24)),
                      // Gráfico de barras - Capacidad de eventos
                      _buildEventCapacityBarChart(isDark),
                      SizedBox(height: _getResponsiveDimension(24)),
                      // Estadísticas de eventos
                      _buildEventStats(isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveDimension(16)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12263F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsiveDimension(10)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: _getResponsiveDimension(24)),
          ),
          SizedBox(height: _getResponsiveDimension(12)),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: _getResponsiveFontSize(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: _getResponsiveDimension(4)),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: _getResponsiveFontSize(12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentPieChart(bool isDark) {
    final enrolled = _enrollments.where((e) => e.status.value == 'ENROLLED').length;
    final waitlisted = _enrollments.where((e) => e.status.value == 'WAITLISTED').length;
    final attended = _enrollments.where((e) => e.status.value == 'ATTENDED').length;
    final cancelled = _enrollments.where((e) => e.status.value == 'CANCELLED').length;
    final total = _enrollments.length;

    if (total == 0) {
      return Container(
        padding: EdgeInsets.all(_getResponsiveDimension(16)),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF12263F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Center(
          child: Text('Sin datos de inscripciones', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(_getResponsiveDimension(16)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12263F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Inscripciones',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: _getResponsiveFontSize(16), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: _getResponsiveDimension(20)),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: enrolled.toDouble(),
                    title: '$enrolled',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: waitlisted.toDouble(),
                    title: '$waitlisted',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: attended.toDouble(),
                    title: '$attended',
                    color: Colors.blue,
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: cancelled.toDouble(),
                    title: '$cancelled',
                    color: Colors.red,
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: _getResponsiveDimension(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Inscrito', Colors.green, '$enrolled', isDark),
              _buildLegendItem('Espera', Colors.orange, '$waitlisted', isDark),
              _buildLegendItem('Asistió', Colors.blue, '$attended', isDark),
              _buildLegendItem('Cancelada', Colors.red, '$cancelled', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String count, bool isDark) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: _getResponsiveFontSize(11))),
        Text(count, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: _getResponsiveFontSize(12), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEventCapacityBarChart(bool isDark) {
    if (_events.isEmpty) {
      return Container(
        padding: EdgeInsets.all(_getResponsiveDimension(16)),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF12263F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Center(
          child: Text('Sin eventos', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
      );
    }

    final topEvents = _events.take(5).toList();

    return Container(
      padding: EdgeInsets.all(_getResponsiveDimension(16)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12263F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capacidad de Eventos (Top 5)',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: _getResponsiveFontSize(16), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: _getResponsiveDimension(20)),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  topEvents.length,
                  (index) {
                    final event = topEvents[index];
                    final capacity = event.maxAttendees.toDouble();
                    final enrolled = _enrollments
                        .where((e) => e.event?.id == event.id && e.status.value == 'ENROLLED')
                        .length
                        .toDouble();

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: enrolled,
                          color: Colors.green.withOpacity(0.8),
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: capacity - enrolled,
                          color: Colors.grey.withOpacity(0.3),
                          width: 12,
                        ),
                      ],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < topEvents.length) {
                          final eventName = topEvents[value.toInt()].name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              eventName.length > 10 ? '${eventName.substring(0, 10)}...' : eventName,
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: _getResponsiveFontSize(10)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: _getResponsiveFontSize(10)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: 20,
              ),
            ),
          ),
          SizedBox(height: _getResponsiveDimension(16)),
          Row(
            children: [
              Container(width: 12, height: 12, color: Colors.green),
              SizedBox(width: _getResponsiveDimension(6)),
              Text('Inscritos', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: _getResponsiveFontSize(12))),
              SizedBox(width: _getResponsiveDimension(16)),
              Container(width: 12, height: 12, color: Colors.grey),
              SizedBox(width: _getResponsiveDimension(6)),
              Text('Disponible', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: _getResponsiveFontSize(12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventStats(bool isDark) {
    final now = DateTime.now();
    final upcomingEvents = _events
        .where((e) => e.initialDate.isAfter(now))
        .length;
    final pastEvents = _events
        .where((e) => e.finalDate.isBefore(now))
        .length;

    final avgCapacity =
        _events.isNotEmpty ? (_events.map((e) => e.maxAttendees).reduce((a, b) => a + b) / _events.length).toStringAsFixed(1) : '0';

    return Container(
      padding: EdgeInsets.all(_getResponsiveDimension(16)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12263F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas Generales',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: _getResponsiveFontSize(16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: _getResponsiveDimension(16)),
          _buildStatRow(
            icon: Icons.trending_up,
            label: 'Eventos Próximos',
            value: upcomingEvents.toString(),
            color: Colors.cyan,
            isDark: isDark,
          ),
          SizedBox(height: _getResponsiveDimension(12)),
          _buildStatRow(
            icon: Icons.history,
            label: 'Eventos Pasados',
            value: pastEvents.toString(),
            color: Colors.orange,
            isDark: isDark,
          ),
          SizedBox(height: _getResponsiveDimension(12)),
          _buildStatRow(
            icon: Icons.people,
            label: 'Capacidad Promedio',
            value: avgCapacity,
            color: Colors.purple,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(_getResponsiveDimension(8)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: _getResponsiveDimension(18)),
        ),
        SizedBox(width: _getResponsiveDimension(12)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: _getResponsiveFontSize(13)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: _getResponsiveFontSize(14),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  int _getActiveEventsCount() {
    final now = DateTime.now();
    return _events
        .where((e) => e.initialDate.isBefore(now) && e.finalDate.isAfter(now))
        .length;
  }

  int _getAttendedCount() {
    return _enrollments.where((e) => e.status.value == 'ATTENDED').length;
  }
}
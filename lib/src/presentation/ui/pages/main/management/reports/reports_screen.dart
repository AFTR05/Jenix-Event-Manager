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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: SecondaryAppbarWidget(title: 'Reportes y Estadísticas'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Error al cargar datos',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
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
                  padding: const EdgeInsets.all(16),
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
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.person_add,
                              label: 'Total Inscripciones',
                              value: _enrollments.length.toString(),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.calendar_today,
                              label: 'Eventos Activos',
                              value: _getActiveEventsCount().toString(),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard(
                              icon: Icons.check_circle,
                              label: 'Asistencias',
                              value: _getAttendedCount().toString(),
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Gráfico de pastel - Estado de Inscripciones
                      _buildEnrollmentPieChart(),
                      const SizedBox(height: 24),
                      // Gráfico de barras - Capacidad de eventos
                      _buildEventCapacityBarChart(),
                      const SizedBox(height: 24),
                      // Estadísticas de eventos
                      _buildEventStats(),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12263F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentPieChart() {
    final enrolled = _enrollments.where((e) => e.status.value == 'ENROLLED').length;
    final waitlisted = _enrollments.where((e) => e.status.value == 'WAITLISTED').length;
    final attended = _enrollments.where((e) => e.status.value == 'ATTENDED').length;
    final cancelled = _enrollments.where((e) => e.status.value == 'CANCELLED').length;
    final total = _enrollments.length;

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12263F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: const Center(
          child: Text('Sin datos de inscripciones', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12263F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución de Inscripciones',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Inscrito', Colors.green, '$enrolled'),
              _buildLegendItem('Espera', Colors.orange, '$waitlisted'),
              _buildLegendItem('Asistió', Colors.blue, '$attended'),
              _buildLegendItem('Cancelada', Colors.red, '$cancelled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String count) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEventCapacityBarChart() {
    if (_events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12263F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: const Center(
          child: Text('Sin eventos', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final topEvents = _events.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12263F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Capacidad de Eventos (Top 5)',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
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
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 12, height: 12, color: Colors.green),
              const SizedBox(width: 6),
              const Text('Inscritos', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, color: Colors.grey),
              const SizedBox(width: 6),
              const Text('Disponible', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventStats() {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12263F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas Generales',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.trending_up,
            label: 'Eventos Próximos',
            value: upcomingEvents.toString(),
            color: Colors.cyan,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.history,
            label: 'Eventos Pasados',
            value: pastEvents.toString(),
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.people,
            label: 'Capacidad Promedio',
            value: avgCapacity,
            color: Colors.purple,
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
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
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
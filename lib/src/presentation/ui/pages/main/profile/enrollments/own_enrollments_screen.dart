import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';

class OwnEnrollmentsScreen extends ConsumerStatefulWidget {
  const OwnEnrollmentsScreen({super.key});

  @override
  ConsumerState<OwnEnrollmentsScreen> createState() =>
      _OwnEnrollmentsScreenState();
}

class _OwnEnrollmentsScreenState extends ConsumerState<OwnEnrollmentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<EnrollmentEntity> _enrollments = [];

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
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

      final result = await enrollmentController.getMyEnrollments(token);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _error = failure.toString();
            _isLoading = false;
          });
        },
        (enrollments) {
          setState(() {
            _enrollments = List<EnrollmentEntity>.from(enrollments);
            _isLoading = false;
          });
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

  final dateFormat = DateFormat('dd MMM yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: SecondaryAppbarWidget(title: 'Mis Inscripciones'),
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
                        'Error al cargar inscripciones',
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
                        onPressed: _loadEnrollments,
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
              : _enrollments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            color: Colors.white30,
                            size: 80,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Sin inscripciones',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Aún no te has inscrito en ningún evento',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : _buildEnrollmentsList()
    );
  }

  Widget _buildEnrollmentsList() {
    // Separar inscripciones activas de canceladas
    final activeEnrollments = _enrollments
        .where(
          (e) =>
              e.status.value != 'CANCELLED' &&
              e.status.value != 'REJECTED',
        )
        .toList();
    final inactiveEnrollments = _enrollments
        .where(
          (e) =>
              e.status.value == 'CANCELLED' ||
              e.status.value == 'REJECTED',
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sección de inscripciones activas
        if (activeEnrollments.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Activas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...activeEnrollments.map(
            (enrollment) => _buildEnrollmentCard(enrollment),
          ),
        ],
        // Sección de inscripciones inactivas
        if (inactiveEnrollments.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Canceladas/Rechazadas',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...inactiveEnrollments.map(
            (enrollment) => _buildEnrollmentCard(
              enrollment,
              inactive: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnrollmentCard(EnrollmentEntity enrollment, {bool inactive = false}) {
    final statusColor = _getStatusColor(enrollment.status.value);
    final statusLabel = _getStatusLabel(enrollment.status.value);
    final eventInfo = enrollment.event;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: inactive ? const Color(0xFF0F1F2E) : const Color(0xFF12263F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                border: Border.all(color: statusColor, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(enrollment.status.value),
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Event Name - Grande y destacado
            if (eventInfo != null)
              Text(
                eventInfo.name,
                style: TextStyle(
                  color: inactive ? Colors.white54 : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16),
            // Evento Info - Mejor organizados
            if (eventInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha inicial
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Inicia',
                      value: dateFormat.format(eventInfo.initialDate),
                      inactive: inactive,
                    ),
                    const SizedBox(height: 12),
                    // Fecha final
                    _buildInfoRow(
                      icon: Icons.event_available,
                      label: 'Finaliza',
                      value: dateFormat.format(eventInfo.finalDate),
                      inactive: inactive,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Enrollment Date minimalista
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Inscripción: ${dateFormat.format(enrollment.enrollmentDate)}',
                style: TextStyle(
                  color: inactive ? Colors.white38 : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            // Cancelled Date (si existe)
            if (enrollment.cancelledAt != null && inactive) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancelada',
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dateFormat.format(enrollment.cancelledAt!),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool inactive,
    bool isGreen = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isGreen ? Colors.green : (inactive ? Colors.white38 : Colors.white54),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isGreen ? Colors.green.withOpacity(0.7) : (inactive ? Colors.white38 : Colors.white54),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isGreen ? Colors.green : (inactive ? Colors.white38 : Colors.white),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ENROLLED':
        return Colors.green;
      case 'WAITLISTED':
        return Colors.orange;
      case 'ATTENDED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ENROLLED':
        return Icons.check_circle;
      case 'WAITLISTED':
        return Icons.schedule;
      case 'ATTENDED':
        return Icons.verified;
      case 'CANCELLED':
        return Icons.cancel;
      case 'REJECTED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ENROLLED':
        return 'Inscrito';
      case 'WAITLISTED':
        return 'En espera';
      case 'ATTENDED':
        return 'Asistió';
      case 'CANCELLED':
        return 'Cancelada';
      case 'REJECTED':
        return 'Rechazada';
      default:
        return status;
    }
  }
}

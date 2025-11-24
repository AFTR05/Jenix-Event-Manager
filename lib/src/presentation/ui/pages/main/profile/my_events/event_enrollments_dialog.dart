import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class EventEnrollmentsDialog extends ConsumerStatefulWidget {
  final EventEntity event;

  const EventEnrollmentsDialog({required this.event, super.key});

  @override
  ConsumerState<EventEnrollmentsDialog> createState() => _EventEnrollmentsDialogState();
}

class _EventEnrollmentsDialogState extends ConsumerState<EventEnrollmentsDialog> {
  bool _isLoading = true;
  List<EnrollmentEntity> _enrollments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final enrollmentController = ref.read(enrollmentControllerProvider);
      final token = ref.read(loginProviderProvider)?.accessToken ?? '';

      if (token.isEmpty) {
        setState(() {
          _error = 'Token no disponible';
          _isLoading = false;
        });
        return;
      }

      final result = await enrollmentController.getEnrollmentsByEvent(
        widget.event.id,
        token,
      );

      result.fold(
        (failure) {
          setState(() {
            _error = failure.toString();
            _isLoading = false;
          });
        },
        (enrollments) {
          // Filtrar solo inscripciones válidas
          final validEnrollments = enrollments
              .where((e) =>
                  e.status.value != 'CANCELLED' &&
                  e.status.value != 'REJECTED' &&
                  e.status.value != 'NO_SHOW')
              .toList();

          setState(() {
            _enrollments = validEnrollments;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF12263F).withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inscripciones',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.event.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Content
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
                    ),
                  )
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Error al cargar inscripciones',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : _enrollments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_off_rounded, color: Colors.white30, size: 48),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Sin inscripciones',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: _enrollments.length,
                            itemBuilder: (context, index) {
                              final enrollment = _enrollments[index];
                              return _buildEnrollmentCard(enrollment);
                            },
                          ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_enrollments.length}/${widget.event.maxAttendees}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE1723),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentCard(EnrollmentEntity enrollment) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2647),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE1723).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: Color(0xFFBE1723), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario ID: ${enrollment.userId ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estado: ${enrollment.status.value}',
                      style: TextStyle(
                        color: _getStatusColor(enrollment.status.value),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Inscripción: ${dateFormat.format(enrollment.enrollmentDate)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          if (enrollment.cancelledAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Cancelada: ${dateFormat.format(enrollment.cancelledAt!)}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
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
      default:
        return Colors.white70;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
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

  /// Calcula el tamaño responsivo de fuente
  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  /// Calcula el padding/tamaño responsivo
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? JenixColorsApp.surfaceColor.withOpacity(0.95) : JenixColorsApp.backgroundWhite;
    final headerTextColor = isDark ? Colors.white : JenixColorsApp.darkColorText;
    final subtitleColor = isDark ? Colors.white70 : JenixColorsApp.subtitleColor;
    final dividerColor = isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder;
    
    final headerFontSize = _getResponsiveFontSize(20);
    final eventNameFontSize = _getResponsiveFontSize(14);
    final cardUserFontSize = _getResponsiveFontSize(13);
    final cardStatusFontSize = _getResponsiveFontSize(11);
    final dateFormatFontSize = _getResponsiveFontSize(11);
    final totalFontSize = _getResponsiveFontSize(14);
    final headerPadding = _getResponsiveDimension(20);
    final cardPadding = _getResponsiveDimension(12);
    
    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(headerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inscripciones',
                  style: TextStyle(
                    color: headerTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: headerFontSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.event.name,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: eventNameFontSize,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1),
          // Content
          Flexible(
            child: _isLoading
                ? Padding(
                    padding: EdgeInsets.all(headerPadding),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(JenixColorsApp.accentColor),
                    ),
                  )
                : _error != null
                    ? Padding(
                        padding: EdgeInsets.all(headerPadding),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: JenixColorsApp.errorColor, size: _getResponsiveDimension(48)),
                              SizedBox(height: _getResponsiveDimension(12)),
                              Text(
                                'Error al cargar inscripciones',
                                style: TextStyle(color: isDark ? Colors.white : JenixColorsApp.darkColorText, fontSize: cardUserFontSize),
                              ),
                              SizedBox(height: _getResponsiveDimension(8)),
                              Text(
                                _error!,
                                style: TextStyle(color: isDark ? Colors.white70 : JenixColorsApp.subtitleColor, fontSize: dateFormatFontSize),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : _enrollments.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(headerPadding),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_off_rounded, color: isDark ? Colors.white30 : JenixColorsApp.lightGray, size: _getResponsiveDimension(48)),
                                  SizedBox(height: _getResponsiveDimension(12)),
                                  Text(
                                    'Sin inscripciones',
                                    style: TextStyle(color: isDark ? Colors.white70 : JenixColorsApp.subtitleColor, fontSize: cardUserFontSize),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(cardPadding),
                            itemCount: _enrollments.length,
                            itemBuilder: (context, index) {
                              final enrollment = _enrollments[index];
                              return _buildEnrollmentCard(enrollment, cardUserFontSize, cardStatusFontSize, dateFormatFontSize, cardPadding);
                            },
                          ),
          ),
          Divider(color: dividerColor, height: 1),
          // Footer
          Padding(
            padding: EdgeInsets.all(_getResponsiveDimension(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_enrollments.length}/${widget.event.maxAttendees}',
                  style: TextStyle(
                    color: headerTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: totalFontSize,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JenixColorsApp.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Cerrar', style: TextStyle(color: Colors.white, fontSize: dateFormatFontSize)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentCard(
    EnrollmentEntity enrollment,
    double cardUserFontSize,
    double cardStatusFontSize,
    double dateFormatFontSize,
    double cardPadding,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final cardBg = isDark ? JenixColorsApp.primaryColor.withOpacity(0.3) : JenixColorsApp.backgroundLightGray;
    final cardBorder = isDark ? Colors.white10 : JenixColorsApp.lightGrayBorder;
    final textColor = isDark ? Colors.white : JenixColorsApp.darkColorText;
    final subtextColor = isDark ? Colors.white70 : JenixColorsApp.subtitleColor;

    return Container(
      margin: EdgeInsets.only(bottom: _getResponsiveDimension(12)),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_getResponsiveDimension(12)),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(_getResponsiveDimension(8)),
                decoration: BoxDecoration(
                  color: JenixColorsApp.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(_getResponsiveDimension(8)),
                ),
                child: Icon(Icons.person, color: JenixColorsApp.accentColor, size: _getResponsiveDimension(20)),
              ),
              SizedBox(width: _getResponsiveDimension(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario: ${enrollment.username ?? 'N/A'}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: cardUserFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _getResponsiveDimension(2)),
                    Text(
                      'Estado: ${enrollment.status.value}',
                      style: TextStyle(
                        color: _getStatusColor(enrollment.status.value),
                        fontSize: cardStatusFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveDimension(8)),
          Text(
            'Inscripción: ${dateFormat.format(enrollment.enrollmentDate)}',
            style: TextStyle(
              color: subtextColor,
              fontSize: dateFormatFontSize,
            ),
          ),
          if (enrollment.cancelledAt != null) ...[
            SizedBox(height: _getResponsiveDimension(4)),
            Text(
              'Cancelada: ${dateFormat.format(enrollment.cancelledAt!)}',
              style: TextStyle(
                color: JenixColorsApp.errorColor,
                fontSize: dateFormatFontSize,
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
        return JenixColorsApp.successColor;
      case 'WAITLISTED':
        return JenixColorsApp.warningColor;
      case 'ATTENDED':
        return JenixColorsApp.infoColor;
      default:
        return JenixColorsApp.subtitleColor;
    }
  }
}

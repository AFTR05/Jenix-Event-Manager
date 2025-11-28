import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.backgroundWhite;
    
    final subtitleFontSize = _getResponsiveFontSize(18);
    final bodyFontSize = _getResponsiveFontSize(14);
    final smallFontSize = _getResponsiveFontSize(12);
    final iconSize = _getResponsiveDimension(64);
    final largeIconSize = _getResponsiveDimension(80);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: SecondaryAppbarWidget(title: 'Mis Inscripciones'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(JenixColorsApp.accentColor),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: JenixColorsApp.errorColor, size: iconSize),
                      SizedBox(height: _getResponsiveDimension(16)),
                      Text(
                        'Error al cargar inscripciones',
                        style: TextStyle(color: isDark ? Colors.white : JenixColorsApp.darkColorText, fontSize: bodyFontSize),
                      ),
                      SizedBox(height: _getResponsiveDimension(8)),
                      Text(
                        _error ?? '',
                        style: TextStyle(color: isDark ? Colors.white70 : JenixColorsApp.subtitleColor, fontSize: smallFontSize),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: _getResponsiveDimension(24)),
                      ElevatedButton(
                        onPressed: _loadEnrollments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JenixColorsApp.accentColor,
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
                            color: isDark ? Colors.white30 : JenixColorsApp.lightGray,
                            size: largeIconSize,
                          ),
                          SizedBox(height: _getResponsiveDimension(24)),
                          Text(
                            'Sin inscripciones',
                            style: TextStyle(color: isDark ? Colors.white70 : JenixColorsApp.subtitleColor, fontSize: subtitleFontSize),
                          ),
                          SizedBox(height: _getResponsiveDimension(8)),
                          Text(
                            'Aún no te has inscrito en ningún evento',
                            style: TextStyle(color: isDark ? Colors.white54 : JenixColorsApp.lightGray, fontSize: bodyFontSize),
                          ),
                        ],
                      ),
                    )
                  : _buildEnrollmentsList()
    );
  }

  Widget _buildEnrollmentsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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

    final paddingMain = _getResponsiveDimension(16);
    final sectionTitleFontSize = _getResponsiveFontSize(16);
    final spacingBetweenSections = _getResponsiveDimension(24);
    final sectionPaddingBottom = _getResponsiveDimension(12);

    return ListView(
      padding: EdgeInsets.all(paddingMain),
      children: [
        // Sección de inscripciones activas
        if (activeEnrollments.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: sectionPaddingBottom),
            child: Text(
              'Activas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: sectionTitleFontSize,
              ),
            ),
          ),
          ...activeEnrollments.map(
            (enrollment) => _buildEnrollmentCard(enrollment),
          ),
        ],
        // Sección de inscripciones inactivas
        if (inactiveEnrollments.isNotEmpty) ...[
          SizedBox(height: spacingBetweenSections),
          Padding(
            padding: EdgeInsets.only(bottom: sectionPaddingBottom),
            child: Text(
              'Canceladas/Rechazadas',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: sectionTitleFontSize,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(enrollment.status.value);
    final statusLabel = _getStatusLabel(enrollment.status.value);
    final eventInfo = enrollment.event;

    final cardMargin = _getResponsiveDimension(16);
    final cardPadding = _getResponsiveDimension(16);
    final borderRadius = _getResponsiveDimension(16);
    final borderWidth = _getResponsiveDimension(2);
    final badgePaddingH = _getResponsiveDimension(12);
    final badgePaddingV = _getResponsiveDimension(6);
    final spacingAfterBadge = _getResponsiveDimension(16);
    final infoPadding = _getResponsiveDimension(12);
    final badgeIconSize = _getResponsiveDimension(16);
    final badgeSpacing = _getResponsiveDimension(6);
    final eventNameFontSize = _getResponsiveFontSize(18);
    final infoBg = _getResponsiveDimension(12);
    final infoRowSpacing = _getResponsiveDimension(12);
    final enrollmentDateFontSize = _getResponsiveFontSize(12);
    final enrollmentDateSpacing = _getResponsiveDimension(8);
    final cancelledSectionSpacing = _getResponsiveDimension(12);
    final badgeFontSize = _getResponsiveFontSize(12);

    final cardColor = isDark 
        ? (inactive ? JenixColorsApp.backgroundColor.withOpacity(0.5) : JenixColorsApp.surfaceColor)
        : (inactive ? JenixColorsApp.backgroundLightGray.withOpacity(0.6) : JenixColorsApp.backgroundWhite);
    final borderColor = isDark ? statusColor.withOpacity(0.3) : statusColor.withOpacity(0.2);

    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
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
                    size: badgeIconSize,
                  ),
                  SizedBox(width: badgeSpacing),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacingAfterBadge),
            // Event Name - Grande y destacado
            if (eventInfo != null)
              Text(
                eventInfo.name,
                style: TextStyle(
                  color: isDark 
                    ? (inactive ? Colors.white54 : Colors.white)
                    : (inactive ? JenixColorsApp.subtitleColor : JenixColorsApp.darkColorText),
                  fontSize: eventNameFontSize,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: spacingAfterBadge),
            // Evento Info - Mejor organizados
            if (eventInfo != null) ...[
              Container(
                padding: EdgeInsets.all(infoPadding),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : JenixColorsApp.backgroundLightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(infoBg),
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
                    SizedBox(height: infoRowSpacing),
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
              SizedBox(height: spacingAfterBadge),
            ],
            // Enrollment Date minimalista
            Padding(
              padding: EdgeInsets.only(top: enrollmentDateSpacing),
              child: Text(
                'Inscripción: ${dateFormat.format(enrollment.enrollmentDate)}',
                style: TextStyle(
                  color: isDark
                    ? (inactive ? Colors.white38 : Colors.white54)
                    : (inactive ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor),
                  fontSize: enrollmentDateFontSize,
                ),
              ),
            ),
            // Cancelled Date (si existe)
            if (enrollment.cancelledAt != null && inactive) ...[
              SizedBox(height: cancelledSectionSpacing),
              Container(
                padding: EdgeInsets.all(infoPadding),
                decoration: BoxDecoration(
                  color: JenixColorsApp.errorColor.withOpacity(isDark ? 0.1 : 0.08),
                  borderRadius: BorderRadius.circular(infoBg),
                  border: Border.all(color: JenixColorsApp.errorColor.withOpacity(isDark ? 0.3 : 0.2), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.close, color: JenixColorsApp.errorColor, size: badgeIconSize),
                    SizedBox(width: _getResponsiveDimension(8)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancelada',
                            style: TextStyle(
                              color: JenixColorsApp.errorColor.withOpacity(isDark ? 0.7 : 0.8),
                              fontSize: _getResponsiveFontSize(11),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dateFormat.format(enrollment.cancelledAt!),
                            style: TextStyle(
                              color: JenixColorsApp.errorColor,
                              fontSize: enrollmentDateFontSize,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconSize = _getResponsiveDimension(18);
    final spacingH = _getResponsiveDimension(8);
    final spacingV = _getResponsiveDimension(2);
    final labelFontSize = _getResponsiveFontSize(11);
    final valueFontSize = _getResponsiveFontSize(13);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isGreen 
            ? JenixColorsApp.successColor
            : (isDark
              ? (inactive ? Colors.white38 : Colors.white54)
              : (inactive ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor)),
          size: iconSize,
        ),
        SizedBox(width: spacingH),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isGreen
                    ? JenixColorsApp.successColor.withOpacity(0.8)
                    : (isDark
                      ? (inactive ? Colors.white38 : Colors.white54)
                      : (inactive ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor)),
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacingV),
              Text(
                value,
                style: TextStyle(
                  color: isGreen
                    ? JenixColorsApp.successColor
                    : (isDark
                      ? (inactive ? Colors.white38 : Colors.white)
                      : (inactive ? JenixColorsApp.lightGray : JenixColorsApp.darkColorText)),
                  fontSize: valueFontSize,
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
        return JenixColorsApp.successColor;
      case 'WAITLISTED':
        return JenixColorsApp.warningColor;
      case 'ATTENDED':
        return JenixColorsApp.infoColor;
      case 'CANCELLED':
        return JenixColorsApp.errorColor;
      case 'REJECTED':
        return JenixColorsApp.errorColor;
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

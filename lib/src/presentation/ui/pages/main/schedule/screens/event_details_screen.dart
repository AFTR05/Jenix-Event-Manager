import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enrollment_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/enrollment_status_enum.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final EventEntity event;

  const EventDetailsScreen({required this.event, super.key});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool isRegistered = false;
  bool isLoading = false;
  bool isEventFull = false;
  bool isEventPassed = false;
  int currentEnrollments = 0;
  String? userEnrollmentId; // ID de la inscripción del usuario

  // Responsive sizing methods
  double _getResponsiveFontSize(double baseFontSize, double screenWidth) {
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension, double screenWidth) {
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  void initState() {
    super.initState();
    _checkEventStatus();
    _checkUserEnrollment();
  }

  Future<void> _checkEventStatus() {
    // Verificar si el evento ya pasó
    final now = DateTime.now();
    final eventEndDateTime = _combineDateTime(
      widget.event.finalDate,
      widget.event.endHour,
    );

    final isPassed = now.isAfter(eventEndDateTime);
    setState(() => isEventPassed = isPassed);
    
    return Future.value();
  }

  DateTime _combineDateTime(DateTime date, String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return date;
    }

    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return date;
    }
  }

  Future<void> _checkUserEnrollment() async {
    final user = ref.read(loginProviderProvider);
    if (user == null || user.accessToken == null) {
      return;
    }

    final enrollmentController = ref.read(enrollmentControllerProvider);
    final result = await enrollmentController.getEnrollmentsByEvent(
      widget.event.id,
      user.accessToken!,
    );

    result.fold(
      (failure) {
        // Error al obtener inscripciones, no hacer nada silenciosamente
      },
      (enrollments) {
        // Contar inscripciones válidas (excluir canceladas, rechazadas, no_show)
        final validEnrollments = enrollments
            .where(
              (e) =>
                  e.status != EnrollmentStatus.cancelled &&
                  e.status != EnrollmentStatus.rejected &&
                  e.status != EnrollmentStatus.noShow,
            )
            .toList();

        final currentCount = validEnrollments.length;
        final isFull = currentCount >= widget.event.maxAttendees;

        // Buscar la inscripción del usuario actual
        EnrollmentEntity? userEnrollment;
        try {
          userEnrollment = validEnrollments.firstWhere(
            (enrollment) => enrollment.userId == user.id,
          );
        } catch (e) {
          userEnrollment = null;
        }

        final userEnrolled = userEnrollment != null;

        setState(() {
          isRegistered = userEnrolled;
          currentEnrollments = currentCount;
          isEventFull =
              isFull && !userEnrolled; // Solo bloquear si NO está inscrito
          // Guardar el ID de la inscripción del usuario
          userEnrollmentId = userEnrollment?.id;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final backgroundColor = isDark
        ? JenixColorsApp.darkBackground
        : JenixColorsApp.backgroundLightGray;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isDark, screenWidth),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveDimension(16, screenWidth)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventHeader(isDark, screenWidth),
                    SizedBox(height: _getResponsiveDimension(24, screenWidth)),
                    _buildEventInfo(isDark, screenWidth),
                    SizedBox(height: _getResponsiveDimension(24, screenWidth)),
                    _buildDescription(isDark, screenWidth),
                    SizedBox(height: _getResponsiveDimension(24, screenWidth)),
                    _buildLocationAndTime(isDark, screenWidth),
                    SizedBox(height: _getResponsiveDimension(24, screenWidth)),
                    _buildCapacity(isDark, screenWidth),
                    SizedBox(height: _getResponsiveDimension(32, screenWidth)),
                    _buildActionButton(screenWidth),
                    SizedBox(height: _getResponsiveDimension(16, screenWidth)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, double screenWidth) {
    final appBarHeight = _getResponsiveDimension(200, screenWidth);
    final iconSize = _getResponsiveDimension(80, screenWidth);
    
    return SliverAppBar(
      expandedHeight: appBarHeight,
      pinned: true,
      backgroundColor: JenixColorsApp.primaryBlue,
      leading: Padding(
        padding: EdgeInsets.all(_getResponsiveDimension(8, screenWidth)),
        child: CircleAvatar(
          backgroundColor: JenixColorsApp.backgroundWhite.withOpacity(0.2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                JenixColorsApp.primaryBlue,
                JenixColorsApp.primaryBlueLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.event.urlImage != null &&
                  widget.event.urlImage!.isNotEmpty &&
                  !widget.event.urlImage!.toLowerCase().contains('por defecto'))
                _buildImageWidget(widget.event.urlImage!)
              else
                Container(
                  color: JenixColorsApp.primaryBlue,
                  child: Center(
                    child: Icon(
                      Icons.event_rounded,
                      size: iconSize,
                      color: JenixColorsApp.backgroundWhite.withOpacity(0.3),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventHeader(bool isDark, double screenWidth) {
    final titleFontSize = _getResponsiveFontSize(28, screenWidth);
    final orgFontSize = _getResponsiveFontSize(14, screenWidth);
    final stateFontSize = _getResponsiveFontSize(12, screenWidth);
    final headerPadding = _getResponsiveDimension(12, screenWidth);
    final stateHPadding = _getResponsiveDimension(12, screenWidth);
    final stateVPadding = _getResponsiveDimension(6, screenWidth);
    final stateRadius = _getResponsiveDimension(20, screenWidth);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: stateHPadding, vertical: stateVPadding),
          decoration: BoxDecoration(
            color: JenixColorsApp.primaryBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(stateRadius),
          ),
          child: Text(
            widget.event.state,
            style: TextStyle(
              color: JenixColorsApp.primaryBlue,
              fontSize: stateFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: headerPadding),
        Text(
          widget.event.name,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: isDark
                ? JenixColorsApp.backgroundWhite
                : JenixColorsApp.darkColorText,
          ),
        ),
        SizedBox(height: _getResponsiveDimension(8, screenWidth)),
        Text(
          widget.event.organizationArea,
          style: TextStyle(
            fontSize: orgFontSize,
            color: isDark
                ? JenixColorsApp.lightGray
                : JenixColorsApp.subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(bool isDark, double screenWidth) {
    final spacingH = _getResponsiveDimension(12, screenWidth);
    
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.access_time_rounded,
            label: 'Hora',
            value:
                '${widget.event.beginHour ?? '--:--'} - ${widget.event.endHour ?? '--:--'}',
            isDark: isDark,
            screenWidth: screenWidth,
          ),
        ),
        SizedBox(width: spacingH),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_rounded,
            label: 'Ubicación',
            value: widget.event.room.type,
            isDark: isDark,
            screenWidth: screenWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required double screenWidth,
  }) {
    final cardPadding = _getResponsiveDimension(12, screenWidth);
    final cardRadius = _getResponsiveDimension(14, screenWidth);
    final iconSize = _getResponsiveDimension(24, screenWidth);
    final labelFontSize = _getResponsiveFontSize(12, screenWidth);
    final valueFontSize = _getResponsiveFontSize(14, screenWidth);
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.backgroundWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: JenixColorsApp.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: iconSize, color: JenixColorsApp.primaryBlue),
              SizedBox(width: _getResponsiveDimension(6, screenWidth)),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: isDark
                      ? JenixColorsApp.lightGray
                      : JenixColorsApp.subtitleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveDimension(6, screenWidth)),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? JenixColorsApp.backgroundWhite
                  : JenixColorsApp.darkColorText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDark, double screenWidth) {
    final titleFontSize = _getResponsiveFontSize(16, screenWidth);
    final descFontSize = _getResponsiveFontSize(14, screenWidth);
    final spacing = _getResponsiveDimension(8, screenWidth);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: isDark
                ? JenixColorsApp.backgroundWhite
                : JenixColorsApp.darkColorText,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          widget.event.description,
          style: TextStyle(
            fontSize: descFontSize,
            color: isDark
                ? JenixColorsApp.lightGray
                : JenixColorsApp.secondaryTextColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndTime(bool isDark, double screenWidth) {
    final containerPadding = _getResponsiveDimension(14, screenWidth);
    final containerRadius = _getResponsiveDimension(16, screenWidth);
    final spacing = _getResponsiveDimension(12, screenWidth);
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isDark
            ? JenixColorsApp.darkGray.withOpacity(0.3)
            : JenixColorsApp.backgroundWhite,
        borderRadius: BorderRadius.circular(containerRadius),
        border: Border.all(
          color: isDark
              ? JenixColorsApp.darkGray.withOpacity(0.5)
              : JenixColorsApp.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Inicio',
            value:
                '${widget.event.initialDate.day}/${widget.event.initialDate.month}/${widget.event.initialDate.year}',
            isDark: isDark,
            screenWidth: screenWidth,
          ),
          SizedBox(height: spacing),
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Fin',
            value:
                '${widget.event.finalDate.day}/${widget.event.finalDate.month}/${widget.event.finalDate.year}',
            isDark: isDark,
            screenWidth: screenWidth,
          ),
          if (widget.event.responsablePerson != null) ...[
            SizedBox(height: spacing),
            _buildDetailRow(
            icon: Icons.person_rounded,
            label: 'Responsable',
              value: widget.event.responsablePerson?.name ?? 'N/A',
              isDark: isDark,
              screenWidth: screenWidth,
            ),
          ],
        ],
      ),
    );
  }  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required double screenWidth,
  }) {
    final iconSize = _getResponsiveDimension(18, screenWidth);
    final labelFontSize = _getResponsiveFontSize(12, screenWidth);
    final valueFontSize = _getResponsiveFontSize(14, screenWidth);
    final spacing = _getResponsiveDimension(12, screenWidth);
    
    return Row(
      children: [
        Icon(icon, size: iconSize, color: JenixColorsApp.primaryBlue),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: isDark
                      ? JenixColorsApp.lightGray
                      : JenixColorsApp.subtitleColor,
                ),
              ),
              SizedBox(height: _getResponsiveDimension(2, screenWidth)),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? JenixColorsApp.backgroundWhite
                      : JenixColorsApp.darkColorText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapacity(bool isDark, double screenWidth) {
    final spotsAvailable = widget.event.maxAttendees - currentEnrollments;
    final isFull = spotsAvailable <= 0;
    
    final containerPadding = _getResponsiveDimension(14, screenWidth);
    final containerRadius = _getResponsiveDimension(16, screenWidth);
    final iconSize = _getResponsiveDimension(24, screenWidth);
    final labelFontSize = _getResponsiveFontSize(12, screenWidth);
    final valueFontSize = _getResponsiveFontSize(14, screenWidth);
    final spacing = _getResponsiveDimension(12, screenWidth);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.red.withOpacity(0.12)
            : JenixColorsApp.primaryBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(containerRadius),
        border: Border.all(
          color: isFull
              ? Colors.red.withOpacity(0.2)
              : JenixColorsApp.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.group_rounded,
            size: iconSize,
            color: isFull ? Colors.red : JenixColorsApp.primaryBlue,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacidad',
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: isDark
                        ? JenixColorsApp.lightGray
                        : JenixColorsApp.subtitleColor,
                  ),
                ),
                SizedBox(height: _getResponsiveDimension(4, screenWidth)),
                Text(
                  isFull
                      ? 'Evento lleno'
                      : 'Máximo ${widget.event.maxAttendees} participantes',
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: isFull ? Colors.red : JenixColorsApp.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFull
                  ? Colors.red.withOpacity(0.2)
                  : JenixColorsApp.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$currentEnrollments/${widget.event.maxAttendees}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isFull ? Colors.red : JenixColorsApp.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(double screenWidth) {
    final isButtonDisabled = isLoading || 
        (isEventFull && !isRegistered) || 
        (isEventPassed && !isRegistered);

    String buttonText;
    Color buttonColor;
    Color textColor;

    if (isEventPassed && !isRegistered) {
      buttonText = 'Evento finalizado';
      buttonColor = Colors.grey.withOpacity(0.3);
      textColor = Colors.grey;
    } else if (isEventPassed && isRegistered) {
      buttonText = 'Evento finalizado';
      buttonColor = Colors.grey.withOpacity(0.3);
      textColor = Colors.grey;
    } else if (isRegistered) {
      buttonText = 'Cancelar inscripción';
      buttonColor = Colors.red.withOpacity(0.3);
      textColor = Colors.red;
    } else if (isEventFull) {
      buttonText = 'Evento lleno';
      buttonColor = Colors.red.withOpacity(0.3);
      textColor = Colors.red;
    } else {
      buttonText = 'Inscribirse al evento';
      buttonColor = JenixColorsApp.primaryBlue;
      textColor = JenixColorsApp.backgroundWhite;
    }

    final buttonHeight = _getResponsiveDimension(56, screenWidth);
    final buttonFontSize = _getResponsiveFontSize(16, screenWidth);

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: (isButtonDisabled || (isEventPassed && isRegistered)) ? null : _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: Colors.grey.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getResponsiveDimension(14, screenWidth)),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: JenixColorsApp.backgroundWhite,
                  strokeWidth: 2,
                ),
              )
            : Text(
                buttonText,
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    final user = ref.read(loginProviderProvider);
    if (user == null || user.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión primero'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final enrollmentController = ref.read(enrollmentControllerProvider);
      final token = user.accessToken!;

      if (isRegistered && userEnrollmentId != null) {
        // Cancelar inscripción usando el ID guardado
        final result = await enrollmentController.cancelEnrollmentAndCache(
          userEnrollmentId!,
          token,
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cancelar: ${failure.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          (success) {
            setState(() {
              isRegistered = false;
              userEnrollmentId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inscripción cancelada'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      } else {
        // Inscribirse al evento
        final result = await enrollmentController.enrollInEventAndCache(
          widget.event.id,
          token,
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al inscribirse: ${failure.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          (enrollment) {
            setState(() {
              isRegistered = true;
              userEnrollmentId = enrollment.id;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Inscripción exitosa! Estado: ${enrollment.status.name}',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    // Detectar si es una URL de red o ruta local
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Es una URL de red
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else if (imageUrl.startsWith('file://')) {
      // Es una ruta local con prefijo file://
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Ruta local sin prefijo
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: JenixColorsApp.primaryBlue,
      child: const Icon(Icons.image_not_supported, color: Colors.white),
    );
  }
}

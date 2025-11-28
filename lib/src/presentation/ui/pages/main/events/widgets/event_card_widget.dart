import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/event_entity.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/utils/events_utils.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/events/widgets/event_card_components.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/schedule/screens/event_details_screen.dart';

class EventCardWidget extends ConsumerWidget {
  final EventEntity event;
  final bool isDark;
  final Size size;

  const EventCardWidget({
    required this.event,
    required this.isDark,
    required this.size,
    super.key,
  });

  double _getResponsiveFontSize(double baseFontSize, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: JenixColorsApp.primaryBlue.withOpacity(0.35),
          width: 2,
        ),
      ),
      color: isDark ? JenixColorsApp.backgroundDark : Colors.white,
      margin: EdgeInsets.only(bottom: _getResponsiveDimension(12, context)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del evento
            if (event.urlImage != null &&
                event.urlImage!.isNotEmpty &&
                !event.urlImage!.toLowerCase().contains('por defecto'))
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildEventImage(event.urlImage!, context),
                  ),
                  // Badge con fecha
                  _buildDateBadge(context),
                ],
              )
            else
              _buildImagePlaceholder(context),

            // Contenido
            Padding(
              padding: EdgeInsets.all(_getResponsiveDimension(16, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del evento
                  Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(18, context),
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  SizedBox(height: _getResponsiveDimension(12, context)),

                  // Información en fila
                  Row(
                    children: [
                      Expanded(
                        child: InfoChip(
                          icon: Icons.access_time_outlined,
                          label: event.beginHour ?? 'Por definir',
                          isDark: isDark,
                          context: context,
                        ),
                      ),
                      SizedBox(width: _getResponsiveDimension(8, context)),
                      Expanded(
                        child: InfoChip(
                          icon: Icons.location_on_outlined,
                          label: event.room.type,
                          isDark: isDark,
                          context: context,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: _getResponsiveDimension(12, context)),

                  // Descripción
                  if (event.description.isNotEmpty)
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(13, context),
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),

                  SizedBox(height: _getResponsiveDimension(12, context)),

                  // Información adicional
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: MiniInfo(
                          icon: Icons.group_outlined,
                          text: '${event.maxAttendees} lugares',
                          isDark: isDark,
                          context: context,
                        ),
                      ),
                      Flexible(
                        child: MiniInfo(
                          icon: Icons.videocam_outlined,
                          text: event.modality.label,
                          isDark: isDark,
                          context: context,
                        ),
                      ),
                      // Botón de ver detalles
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getResponsiveDimension(12, context),
                          vertical: _getResponsiveDimension(8, context),
                        ),
                        decoration: BoxDecoration(
                          color: JenixColorsApp.primaryBlue,
                          borderRadius: BorderRadius.circular(_getResponsiveDimension(8, context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(12, context),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: _getResponsiveDimension(4, context)),
                            Icon(
                              Icons.arrow_forward,
                              size: _getResponsiveDimension(12, context),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final imageHeight = _getResponsiveDimension(200, context);
    final iconSize = _getResponsiveDimension(80, context);

    return Container(
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_getResponsiveDimension(16, context)),
          topRight: Radius.circular(_getResponsiveDimension(16, context)),
        ),
        gradient: LinearGradient(
          colors: [
            JenixColorsApp.primaryBlue.withOpacity(0.25),
            JenixColorsApp.primaryBlue.withOpacity(0.12),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_note_outlined,
          size: iconSize,
          color: JenixColorsApp.primaryBlue.withOpacity(0.65),
        ),
      ),
    );
  }

  Widget _buildEventImage(String imageUrl, BuildContext context) {
    final imageHeight = _getResponsiveDimension(200, context);
    final imageProvider = NetworkImage(imageUrl);

    // Precache la imagen y captura errores silenciosamente
    imageProvider
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener(
            (image, synchronousCall) {},
            onError: (error, stackTrace) {
              // Ignora errores silenciosamente, el errorBuilder se encargará
            },
          ),
        );

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(context);
        },
      ),
    );
  }

  Widget _buildDateBadge(BuildContext context) {
    final badgePaddingH = _getResponsiveDimension(12, context);
    final badgePaddingV = _getResponsiveDimension(8, context);
    final badgeTop = _getResponsiveDimension(12, context);
    final badgeLeft = _getResponsiveDimension(12, context);
    final badgeBorderRadius = _getResponsiveDimension(12, context);
    final dayFontSize = _getResponsiveFontSize(16, context);
    final monthFontSize = _getResponsiveFontSize(11, context);

    return Positioned(
      top: badgeTop,
      left: badgeLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(badgeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${event.initialDate.day}',
              style: TextStyle(
                fontSize: dayFontSize,
                fontWeight: FontWeight.w900,
                color: JenixColorsApp.primaryBlue,
              ),
            ),
            Text(
              EventsUtils.formatMonthAbbr(event.initialDate.month),
              style: TextStyle(
                fontSize: monthFontSize,
                fontWeight: FontWeight.w700,
                color: JenixColorsApp.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: JenixColorsApp.primaryBlue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      color: isDark ? JenixColorsApp.backgroundDark : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
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
                    child: _buildEventImage(event.urlImage!),
                  ),
                  // Badge con fecha
                  _buildDateBadge(),
                ],
              )
            else
              _buildImagePlaceholder(),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del evento
                  Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Información en fila
                  Row(
                    children: [
                      Expanded(
                        child: InfoChip(
                          icon: Icons.access_time_outlined,
                          label: event.beginHour ?? 'Por definir',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoChip(
                          icon: Icons.location_on_outlined,
                          label: event.room.type,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Descripción
                  if (event.description.isNotEmpty)
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Información adicional
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: MiniInfo(
                          icon: Icons.group_outlined,
                          text: '${event.maxAttendees} lugares',
                          isDark: isDark,
                        ),
                      ),
                      Flexible(
                        child: MiniInfo(
                          icon: Icons.videocam_outlined,
                          text: event.modality.label,
                          isDark: isDark,
                        ),
                      ),
                      // Botón de ver detalles
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: JenixColorsApp.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 12,
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

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          colors: [
            JenixColorsApp.primaryBlue.withOpacity(0.2),
            JenixColorsApp.primaryBlue.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_note_outlined,
          size: 80,
          color: JenixColorsApp.primaryBlue.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildEventImage(String imageUrl) {
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
      height: 200,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      ),
    );
  }

  Widget _buildDateBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${event.initialDate.day}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: JenixColorsApp.primaryBlue,
              ),
            ),
            Text(
              EventsUtils.formatMonthAbbr(event.initialDate.month),
              style: const TextStyle(
                fontSize: 11,
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

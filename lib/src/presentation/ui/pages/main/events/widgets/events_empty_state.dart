import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class EventsEmptyState extends StatelessWidget {
  final bool isDark;

  const EventsEmptyState({
    required this.isDark,
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
  Widget build(BuildContext context) {
    final iconSize = _getResponsiveDimension(80, context);
    final titleFontSize = _getResponsiveFontSize(18, context);
    final messageFontSize = _getResponsiveFontSize(14, context);
    final verticalPadding = _getResponsiveDimension(60, context);
    final horizontalPadding = _getResponsiveDimension(20, context);
    final spacingAfterIcon = _getResponsiveDimension(16, context);
    final spacingAfterTitle = _getResponsiveDimension(8, context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: iconSize,
            color: JenixColorsApp.primaryBlue.withOpacity(0.6),
          ),
          SizedBox(height: spacingAfterIcon),
          Text(
            'No hay eventos próximos',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: spacingAfterTitle),
          Text(
            'Los eventos aparecerán aquí cuando estén disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: messageFontSize,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

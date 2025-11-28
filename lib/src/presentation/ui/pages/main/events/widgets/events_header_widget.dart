import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class EventsHeaderWidget extends StatelessWidget {
  final int eventCount;
  final bool isDark;

  const EventsHeaderWidget({
    required this.eventCount,
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
    final titleFontSize = _getResponsiveFontSize(24, context);
    final subtitleFontSize = _getResponsiveFontSize(14, context);
    final titlePadding = _getResponsiveDimension(20, context);
    final titleBottomPadding = _getResponsiveDimension(16, context);
    final expandedHeight = _getResponsiveDimension(140, context);

    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight,
      elevation: 0,
      backgroundColor: isDark ? JenixColorsApp.backgroundDark : JenixColorsApp.backgroundWhite,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: titlePadding, bottom: titleBottomPadding),
        title: Text(
          'Eventos Disponibles',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : JenixColorsApp.primaryBlue,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                JenixColorsApp.primaryBlue.withOpacity(0.25),
                JenixColorsApp.primaryBlue.withOpacity(0.10),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: titlePadding),
                child: Text(
                  '$eventCount eventos próximos',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: JenixColorsApp.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

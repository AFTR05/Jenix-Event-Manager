import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final BuildContext context;

  const InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.context,
    super.key,
  });

  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final chipPaddingH = _getResponsiveDimension(10);
    final chipPaddingV = _getResponsiveDimension(6);
    final borderRadius = _getResponsiveDimension(8);
    final iconSize = _getResponsiveDimension(14);
    final spacing = _getResponsiveDimension(6);
    final labelFontSize = _getResponsiveFontSize(12);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: chipPaddingH, vertical: chipPaddingV),
      decoration: BoxDecoration(
        color: JenixColorsApp.primaryBlue.withOpacity(0.18),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: JenixColorsApp.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: JenixColorsApp.primaryBlue.withOpacity(0.95),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final BuildContext context;

  const MiniInfo({
    required this.icon,
    required this.text,
    required this.isDark,
    required this.context,
    super.key,
  });

  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = _getResponsiveDimension(12);
    final spacing = _getResponsiveDimension(4);
    final textFontSize = _getResponsiveFontSize(11);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: JenixColorsApp.primaryBlue.withOpacity(0.9),
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: textFontSize,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

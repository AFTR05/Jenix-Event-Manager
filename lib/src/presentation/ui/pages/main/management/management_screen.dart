import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/routes_app.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.backgroundWhite;
    final gradientStart = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.infoLight;
    final gradientEnd = isDark ? JenixColorsApp.backgroundColor : JenixColorsApp.infoLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Centro de Administración',
                style: TextStyle(
                  color: isDark ? Colors.white : JenixColorsApp.primaryBlue,
                  fontSize: _getResponsiveFontSize(26, context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: _getResponsiveDimension(8, context)),
              Text(
                'Selecciona una opción para gestionar',
                style: TextStyle(
                  color: isDark ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor,
                  fontSize: _getResponsiveFontSize(14, context),
                ),
              ),
              SizedBox(height: _getResponsiveDimension(24, context)),
              _buildAdminOption(
                context: context,
                icon: Icons.people_rounded,
                title: 'Usuarios',
                subtitle: 'Gestiona usuarios y organizadores',
                route: RoutesApp.users,
                isDark: isDark,
              ),
              SizedBox(height: _getResponsiveDimension(12, context)),
              _buildAdminOption(
                context: context,
                icon: Icons.meeting_room_rounded,
                title: 'Salones',
                subtitle: 'Gestiona salones y espacios disponibles',
                route: RoutesApp.rooms,
                isDark: isDark,
              ),
              SizedBox(height: _getResponsiveDimension(12, context)),
              _buildAdminOption(
                context: context,
                icon: Icons.location_city_rounded,
                title: 'Campus',
                subtitle: 'Gestiona campus y localidades',
                route: RoutesApp.campus,
                isDark: isDark,
              ),
              SizedBox(height: _getResponsiveDimension(12, context)),
              _buildAdminOption(
                context: context,
                icon: Icons.bar_chart_rounded,
                title: 'Reportes',
                subtitle: 'Ver reportes y estadísticas',
                route: RoutesApp.reports,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required bool isDark,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(_getResponsiveDimension(14, context)),
          decoration: BoxDecoration(
            color: isDark ? JenixColorsApp.surfaceColor.withOpacity(0.7) : JenixColorsApp.backgroundWhite,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : JenixColorsApp.lightGrayBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(_getResponsiveDimension(10, context)),
                decoration: BoxDecoration(
                  color: isDark ? JenixColorsApp.accentColor.withOpacity(0.15) : JenixColorsApp.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: JenixColorsApp.accentColor,
                  size: _getResponsiveDimension(24, context),
                ),
              ),
              SizedBox(width: _getResponsiveDimension(12, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : JenixColorsApp.darkColorText,
                        fontSize: _getResponsiveFontSize(16, context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: _getResponsiveDimension(4, context)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? JenixColorsApp.lightGray : JenixColorsApp.subtitleColor,
                        fontSize: _getResponsiveFontSize(12, context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                size: _getResponsiveDimension(24, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
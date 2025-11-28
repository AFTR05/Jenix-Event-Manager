import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2647),
        title: const Text('Administración'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2647), Color(0xFF09131E)],
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
                  color: Colors.white,
                  fontSize: isMobile ? 20 : 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona una opción para gestionar',
                style: TextStyle(
                  color: Color(0xFF9DA9B9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: isMobile ? 20 : 28),
              _buildAdminOption(
                context: context,
                icon: Icons.people_rounded,
                title: 'Usuarios',
                subtitle: 'Gestiona usuarios y organizadores',
                route: RoutesApp.users,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildAdminOption(
                context: context,
                icon: Icons.meeting_room_rounded,
                title: 'Salones',
                subtitle: 'Gestiona salones y espacios disponibles',
                route: RoutesApp.rooms,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildAdminOption(
                context: context,
                icon: Icons.location_city_rounded,
                title: 'Campus',
                subtitle: 'Gestiona campus y localidades',
                route: RoutesApp.campus,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildAdminOption(
                context: context,
                icon: Icons.bar_chart_rounded,
                title: 'Reportes',
                subtitle: 'Ver reportes y estadísticas',
                route: RoutesApp.reports,
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
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFF12263F).withOpacity(0.7),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE1723).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFBE1723),
                  size: isMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9DA9B9),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
                size: isMobile ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
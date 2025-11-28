import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const Color accentRed = JenixColorsApp.accentColor;
  static const Color bgDark = JenixColorsApp.backgroundColor;

  static const String _logoAsset = 'assets/images/eventum_logo.png';
  static const String _bannerAsset = 'assets/images/universidad_banner.gif';

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1000;
    final bannerHeight = isWide ? 620.0 : 420.0;

    return Scaffold(
      backgroundColor: bgDark,
      body: CustomScrollView(
        slivers: [
          // ===== HEADER =====
          SliverAppBar(
            pinned: true,
            elevation: 10,
            backgroundColor: Colors.black.withOpacity(0.75),
            toolbarHeight: 78,
            title: Row(
              children: [
                Image.asset(_logoAsset, height: 42),
                const SizedBox(width: 12),
                Text(
                  'Eventum',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              _HeaderButton(label: "Inicio", onTap: () {}),
              _HeaderButton(label: "Eventos", onTap: () {}),
              _HeaderButton(label: "Nosotros", onTap: () {}),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Ingresar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ===== HERO / BANNER (más oscuro para resaltar texto) =====
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SizedBox(
                height: bannerHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // GIF / imagen (cubre todo)
                    Image.asset(_bannerAsset, fit: BoxFit.cover),

                    // Overlay oscuro más fuerte para mejor contraste del texto
                    Container(color: Colors.black.withOpacity(0.68)),

                    // contenido central sobre banner
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(_logoAsset, height: isWide ? 140 : 96),
                          const SizedBox(height: 18),
                          Text(
                            'La excelencia en gestión de eventos académicos',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              fontSize: isWide ? 30 : 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/about'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentRed,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Conoce más',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white24),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Contacto',
                                  style: GoogleFonts.poppins(fontSize: 15),
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
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 36)),

          // ===== INFORMACIÓN / SUBTÍTULO =====
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 24),
              child: Column(
                children: [
                  Text(
                    'Una experiencia organizada. Diseño, control y trazabilidad en cada evento.',
                    style: GoogleFonts.poppins(
                      fontSize: isWide ? 24 : 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Eventum centraliza la planificación, las reservas y las inscripciones de eventos, garantizando visibilidad y control para organizadores y asistentes.',
                    style: GoogleFonts.poppins(
                      fontSize: isWide ? 16 : 14,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ===== FUNCIONALIDADES (tarjetas uniformes) =====
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 28,
                runSpacing: 22,
                children: [
                  _UniformFeatureCard(
                    icon: Icons.event_available_rounded,
                    title: 'Gestión de eventos',
                    description:
                        'Planificación, inscripción y seguimiento centralizado.',
                    accent: accentRed,
                  ),
                  _UniformFeatureCard(
                    icon: Icons.meeting_room_rounded,
                    title: 'Gestión de espacios',
                    description:
                        'Reservas inteligentes que evitan solapamientos.',
                    accent: accentRed,
                  ),
                  _UniformFeatureCard(
                    icon: Icons.how_to_reg_rounded,
                    title: 'Control de asistencia',
                    description:
                        'Check-in y reportes de participación en tiempo real.',
                    accent: accentRed,
                  ),
                  _UniformFeatureCard(
                    icon: Icons.insert_chart_rounded,
                    title: 'Reportes & estadísticas',
                    description: 'Exportación a Excel/PDF y dashboards claros.',
                    accent: accentRed,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 64)),

          // ===== FOOTER =====
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF06070A),
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Column(
                children: [
                  Text(
                    'Universidad Alexander von Humboldt • Armenia, Quindío',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Creado por Jenix © 2025',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
        ],
      ),
    );
  }
}

/// Header text button (simple)
class _HeaderButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HeaderButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextButton(
          onPressed: onTap,
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de funcionalidad UNIFORME: ancho y alto fijos para todas
class _UniformFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  const _UniformFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  @override
  State<_UniformFeatureCard> createState() => _UniformFeatureCardState();
}

class _UniformFeatureCardState extends State<_UniformFeatureCard> {
  bool _hover = false;

  // tamaño fijo (mismo para todas)
  static const double cardWidth = 320;
  static const double cardHeight = 220;

  @override
  Widget build(BuildContext context) {
    final double scale = _hover ? 1.03 : 1.0;
    final double lift = _hover ? -8 : 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Transform.translate(
          offset: Offset(0, lift),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1620),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.32 : 0.18),
                  blurRadius: _hover ? 26 : 12,
                  offset: Offset(0, _hover ? 12 : 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(widget.icon, size: 34, color: widget.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    widget.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[300],
                      height: 1.45,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

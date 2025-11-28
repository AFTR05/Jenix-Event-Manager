import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';
import 'package:jenix_event_manager/src/presentation/controllers/auth/authentication_controller.dart';
import 'package:jenix_event_manager/src/routes_app.dart';

/// SplashScreen - Alexander von Humboldt Event Manager
/// Pantalla inicial que verifica si hay una sesión activa guardada
/// y redirige automáticamente al usuario a Home o Login
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Iniciar animación
    _animationController.forward();

    // Verificar sesión después de un delay
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Esperar a que termine la animación inicial
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    try {
      // Verificar si hay una sesión guardada
      final authController = ref.read(authenticationControllerProvider);
      final isLogged = await authController.isLoggedUser();

      if (!mounted) return;

      // Navegar según el resultado
      if (isLogged) {
        // Usuario tiene sesión activa, ir a Home
        Navigator.pushReplacementNamed(context, RoutesApp.main);
      } else {
        // No hay sesión, ir a Login
        Navigator.pushReplacementNamed(context, RoutesApp.main);
      }
    } catch (e) {
      // En caso de error, ir a Login por seguridad
      if (mounted) {
        Navigator.pushReplacementNamed(context, RoutesApp.main);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    JenixColorsApp.darkBackground,
                    JenixColorsApp.primaryBlueDark,
                  ]
                : [
                    JenixColorsApp.primaryBlue,
                    JenixColorsApp.primaryBlueLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo de la Universidad Alexander von Humboldt
                        Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: JenixColorsApp.backgroundWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/images/humboldt_logo.svg',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Nombre de la App
                        const Text(
                          'Alexander von Humboldt',
                          style: TextStyle(
                            fontFamily: 'OpenSansHebrew',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: JenixColorsApp.backgroundWhite,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Event Manager',
                          style: TextStyle(
                            fontFamily: 'OpenSansHebrew',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: JenixColorsApp.backgroundWhite,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 48),

                        // Loading Indicator
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              JenixColorsApp.backgroundWhite,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Cargando...',
                          style: TextStyle(
                            fontFamily: 'OpenSansHebrew',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: JenixColorsApp.backgroundWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
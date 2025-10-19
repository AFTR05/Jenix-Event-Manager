import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/auth/login_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/auth/register_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/main_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/splash/splash_screen.dart';

/// RoutesApp - Alexander von Humboldt Event Manager
/// Gestión centralizada de rutas de la aplicación
class RoutesApp {
  // Rutas principales
  static const String index = "/";
  static const String splash = "/splash";
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";
  
  // Rutas de perfil y configuración
  static const String editProfile = "/edit-profile";
  static const String myEvents = "/my-events";
  static const String notifications = "/notifications";
  static const String share = "/share";
  static const String help = "/help";
  static const String appSettings = "/settings";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case index:
        // La ruta inicial ahora es el SplashScreen
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      
      // Rutas de perfil (placeholder por ahora)
      case editProfile:
      case myEvents:
      case notifications:
      case share:
      case help:
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(_getRouteTitle(settings.name ?? '')),
            ),
            body: Center(
              child: Text(
                'Pantalla en desarrollo:\n${_getRouteTitle(settings.name ?? '')}',
                style: const TextStyle(
                  fontFamily: 'OpenSansHebrew',
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Ruta no encontrada: ${settings.name}',
                style: const TextStyle(
                  fontFamily: 'OpenSansHebrew',
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
    }
  }

  /// Obtiene el título de la ruta
  static String _getRouteTitle(String route) {
    switch (route) {
      case editProfile:
        return 'Editar Perfil';
      case myEvents:
        return 'Mis Eventos';
      case notifications:
        return 'Notificaciones';
      case share:
        return 'Compartir App';
      case help:
        return 'Ayuda y Soporte';
      case appSettings:
        return 'Configuración';
      default:
        return 'Jenix Event Manager';
    }
  }
}

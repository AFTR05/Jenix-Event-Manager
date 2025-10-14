import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/auth/login_screen.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/auth/register_screen.dart';

class RoutesApp {
  static const String index = "/";
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case index:
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      default:
        return MaterialPageRoute(builder: (_) => Container());
    }
  }
}

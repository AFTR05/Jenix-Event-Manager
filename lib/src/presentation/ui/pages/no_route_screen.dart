
import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class NoRouteScreen extends StatelessWidget {
  const NoRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página no encontrada"),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "Oops! No encontramos esta ruta",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "OpenSansHebrew",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "La página a la que intentas acceder no existe o fue movida.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: "OpenSansHebrew",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back, color: JenixColorsApp.jenixAppColor),
                label: Text(
                  "Volver",
                  style: const TextStyle(
                    fontFamily: "OpenSansHebrew",
                  ).copyWith(color: JenixColorsApp.jenixAppColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: JenixColorsApp.jenixAppColor,
                  shadowColor: JenixColorsApp.jenixAppColor.withValues(alpha: .2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: JenixColorsApp.jenixAppColor, width: 1.2),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

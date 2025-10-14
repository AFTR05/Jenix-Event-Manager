import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jenix_event_manager/src/core/helpers/language_app.dart';
import 'package:jenix_event_manager/translations/codegen_loader.g.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: LanguagesApp.availableLanguages,
      assetLoader: const CodegenLoader(),
      fallbackLocale: LanguagesApp.availableLanguages.first,
      path: 'assets/translations',
      saveLocale: true,
      child: const ProviderScope(
        child: JenixEventManagerApp(),
      ),
    ),
  );
}

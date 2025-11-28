import 'dart:ui';
import 'package:bmprogresshud/progresshud.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jenix_event_manager/environment_config.dart';
import 'package:jenix_event_manager/src/inject/states_providers/app_states/theme_provider.dart';
import 'package:jenix_event_manager/src/routes_app.dart';
import 'package:jenix_event_manager/src/utils/navigation_service.dart';
import 'package:jenix_event_manager/src/utils/theme/app_theme.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class JenixEventManagerApp extends ConsumerStatefulWidget {
  const JenixEventManagerApp({super.key});

  @override
  ConsumerState<JenixEventManagerApp> createState() =>
      _JenixEventManagerAppState();
}

class _JenixEventManagerAppState extends ConsumerState<JenixEventManagerApp> {
  @override
  Widget build(BuildContext context) {
    // Aquí lees el ThemeMode desde Riverpod
    final themeMode = ref.watch(themeAppProvider);

    return ProgressHud(
      isGlobalHud: true,
      child: AbsorbPointer(
        absorbing: false,
        child: Listener(
          child: OverlaySupport.global(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              scrollBehavior: CustomScrollBehavior(),
              navigatorKey: NavigationService.navigationKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              title: EnvironmentConfig.nameApp,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              navigatorObservers: [NavigationService.myTransitionObserver],
              initialRoute: RoutesApp.index,
              onGenerateRoute: RoutesApp.generateRoute,
            ),
          ),
        ),
      ),
    );
  }
}

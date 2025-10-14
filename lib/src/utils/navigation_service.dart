
import 'package:flutter/material.dart';
import 'package:jenix_event_manager/src/utils/my_transition_observer.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
  static String? currentRouteName;
  static JenixTransitionObserver myTransitionObserver = JenixTransitionObserver();

  static BuildContext? contextReal({
    required BuildContext context,
  }) {
    final contextReal = context.mounted
        ? context
        : NavigationService.navigationKey.currentContext;
    return contextReal;
  }
}

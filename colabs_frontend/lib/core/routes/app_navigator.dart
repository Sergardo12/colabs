import 'package:flutter/material.dart';

/// Navegador global de la app.
///
/// Permite navegar desde widgets que están por encima del [Navigator]
/// (p. ej. el manejo de deep links en [DeepLinkGate]).
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static final RootNavigatorObserver observer = RootNavigatorObserver();
}

/// Observa la navegación y expone el nombre de la ruta actual del top.
///
/// Permite que el manejo de deep links espere a que la app se asiente en su
/// ruta raíz (`home`) antes de empujar el perfil, evitando que el splash o el
/// login pisen la navegación con su `pushReplacementNamed`.
class RootNavigatorObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>(null);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName.value = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName.value = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRouteName.value = newRoute?.settings.name;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName.value = previousRoute?.settings.name;
  }
}

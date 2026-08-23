import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes/app_navigator.dart';
import '../routes/app_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import 'deep_link_bloc.dart';
import 'deep_link_event.dart';
import 'deep_link_service.dart';
import 'deep_link_target.dart';

/// Orquesta los deep links de la app.
///
/// - Se suscribe una sola vez al stream de `app_links` (evita links duplicados).
/// - Parsea y navega si hay sesión; si no, encola el destino y lo consume
///   cuando el usuario inicia sesión (o cuando el splash resuelve la sesión).
class DeepLinkGate extends StatefulWidget {
  const DeepLinkGate({super.key, required this.child});

  final Widget child;

  @override
  State<DeepLinkGate> createState() => _DeepLinkGateState();
}

class _DeepLinkGateState extends State<DeepLinkGate> {
  static const Duration _retryInterval = Duration(milliseconds: 500);
  static const int _maxRetries = 16;

  StreamSubscription<Uri>? _linkSubscription;
  Timer? _pendingRetry;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _linkSubscription = _service.uriLinkStream.listen(_handleUri);
    final initialLink = await _service.getInitialLink();
    if (initialLink != null) _handleUri(initialLink);
  }

  DeepLinkService get _service => context.read<DeepLinkBloc>().deepLinkService;

  void _handleUri(Uri uri) {
    if (!mounted) return;
    final target = _service.parse(uri);
    if (target == null) return;
    _handleTarget(target);
  }

  Future<void> _handleTarget(DeepLinkTarget target) async {
    final authRepository = context.read<AuthBloc>().authRepository;
    final hasSession = await authRepository.isSessionValid();
    if (!mounted) return;

    context.read<DeepLinkBloc>().add(DeepLinkReceived(target));
    _startPendingRetry();

    if (hasSession && _isAppSettledOnHome()) {
      _navigateToProfile(target.userId);
      context.read<DeepLinkBloc>().add(DeepLinkConsumed());
      _pendingRetry?.cancel();
    }
  }

  void _startPendingRetry() {
    _pendingRetry?.cancel();
    var attempts = 0;
    _pendingRetry = Timer.periodic(_retryInterval, (timer) {
      attempts++;
      final bloc = context.read<DeepLinkBloc>();
      final target = bloc.state.pendingTarget;
      if (target == null) {
        timer.cancel();
        return;
      }
      if (attempts >= _maxRetries) {
        timer.cancel();
        return;
      }
      _checkPendingSession(target);
    });
  }

  Future<void> _checkPendingSession(DeepLinkTarget target) async {
    final bloc = context.read<DeepLinkBloc>();
    final authRepository = context.read<AuthBloc>().authRepository;
    final hasSession = await authRepository.isSessionValid();
    if (!mounted) return;
    if (!hasSession) return;
    if (bloc.state.pendingTarget != target) return;
    if (!_isAppSettledOnHome()) return;

    _navigateToProfile(target.userId);
    bloc.add(DeepLinkConsumed());
    _pendingRetry?.cancel();
  }

  /// La app está asentada en su raíz cuando el top del stack es `home`.
  ///
  /// Evita empujar el perfil sobre el splash o el login, cuyas rutas serían
  /// reemplazadas (y el perfil descartado) por su `pushReplacementNamed`.
  bool _isAppSettledOnHome() {
    if (AppNavigator.key.currentState == null) return false;
    return AppNavigator.observer.currentRouteName.value == AppRouter.home;
  }

  void _onAuthChange(BuildContext context, AuthState state) {
    if (state is! AuthSuccess) return;
    final bloc = context.read<DeepLinkBloc>();
    if (!bloc.state.hasPendingTarget) return;
    // Re-arma el retry: navegará cuando la app se asiente en home tras el
    // pushReplacementNamed(home) del login/register.
    _startPendingRetry();
  }

  void _navigateToProfile(String userId) {
    AppNavigator.key.currentState?.pushNamed(
      AppRouter.publicProfile,
      arguments: userId,
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _pendingRetry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _onAuthChange,
      child: widget.child,
    );
  }
}

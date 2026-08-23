import 'package:flutter_bloc/flutter_bloc.dart';
import 'deep_link_event.dart';
import 'deep_link_service.dart';
import 'deep_link_state.dart';

class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
  DeepLinkBloc({required this.deepLinkService})
      : super(const DeepLinkState()) {
    on<DeepLinkReceived>(_onDeepLinkReceived);
    on<DeepLinkConsumed>(_onDeepLinkConsumed);
  }

  final DeepLinkService deepLinkService;

  void _onDeepLinkReceived(
    DeepLinkReceived event,
    Emitter<DeepLinkState> emit,
  ) {
    emit(DeepLinkState(pendingTarget: event.target));
  }

  void _onDeepLinkConsumed(
    DeepLinkConsumed event,
    Emitter<DeepLinkState> emit,
  ) {
    emit(const DeepLinkState());
  }
}

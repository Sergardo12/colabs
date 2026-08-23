import 'package:equatable/equatable.dart';

abstract class RequestMapEvent extends Equatable {
  const RequestMapEvent();

  @override
  List<Object?> get props => [];
}

/// Carga el catálogo de ocupaciones al entrar a la página del mapa
class OccupationsLoadRequested extends RequestMapEvent {
  const OccupationsLoadRequested();
}

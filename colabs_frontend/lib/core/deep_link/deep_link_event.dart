import 'package:equatable/equatable.dart';
import 'deep_link_target.dart';

abstract class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();

  @override
  List<Object?> get props => [];
}

class DeepLinkReceived extends DeepLinkEvent {
  const DeepLinkReceived(this.target);

  final DeepLinkTarget target;

  @override
  List<Object?> get props => [target];
}

class DeepLinkConsumed extends DeepLinkEvent {
  const DeepLinkConsumed();
}

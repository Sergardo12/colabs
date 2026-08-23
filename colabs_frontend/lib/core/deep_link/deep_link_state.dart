import 'package:equatable/equatable.dart';
import 'deep_link_target.dart';

class DeepLinkState extends Equatable {
  const DeepLinkState({this.pendingTarget});

  final DeepLinkTarget? pendingTarget;

  bool get hasPendingTarget => pendingTarget != null;

  @override
  List<Object?> get props => [pendingTarget];
}

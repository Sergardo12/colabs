import 'package:equatable/equatable.dart';

enum DeepLinkType { publicProfile }

class DeepLinkTarget extends Equatable {
  const DeepLinkTarget({required this.type, required this.userId});

  final DeepLinkType type;
  final String userId;

  @override
  List<Object?> get props => [type, userId];
}

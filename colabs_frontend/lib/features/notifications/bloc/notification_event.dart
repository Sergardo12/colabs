import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkRead extends NotificationEvent {
  final String id;

  const NotificationMarkRead(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationsMarkAllRead extends NotificationEvent {
  const NotificationsMarkAllRead();
}

class NotificationDeleted extends NotificationEvent {
  final String id;

  const NotificationDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

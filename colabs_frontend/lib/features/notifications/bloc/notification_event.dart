import 'package:equatable/equatable.dart';
import '../models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationPushReceived extends NotificationEvent {
  final NotificationModel notification;

  const NotificationPushReceived(this.notification);

  @override
  List<Object?> get props => [notification];
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

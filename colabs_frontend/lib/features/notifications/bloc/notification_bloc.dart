import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/notification_repository.dart';
import '../models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationMarkRead>(_onMarkRead);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
    on<NotificationDeleted>(_onDeleted);
  }

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationRepository.getEnriched();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(const NotificationError(message: 'Error al cargar notificaciones'));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    // Optimista — marca como leída al instante
    final updated = current.notifications
        .map((n) => n.id == event.id ? _copyWithRead(n, true) : n)
        .toList();
    emit(NotificationLoaded(notifications: updated));

    try {
      await _notificationRepository.markAsRead(event.id);
    } catch (e) {
      // Revertir si falla
      final reverted = current.notifications;
      emit(NotificationLoaded(notifications: reverted));
    }
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updated = current.notifications
        .map((n) => _copyWithRead(n, true))
        .toList();
    emit(NotificationLoaded(notifications: updated));

    try {
      await _notificationRepository.markAllAsRead();
    } catch (e) {
      final reverted = current.notifications;
      emit(NotificationLoaded(notifications: reverted));
    }
  }

  Future<void> _onDeleted(
    NotificationDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updated =
        current.notifications.where((n) => n.id != event.id).toList();
    emit(NotificationLoaded(notifications: updated));

    try {
      await _notificationRepository.delete(event.id);
    } catch (e) {
      emit(current);
    }
  }

  NotificationModel _copyWithRead(NotificationModel n, bool read) {
    return NotificationModel(
      id:            n.id,
      userId:        n.userId,
      type:          n.type,
      title:         n.title,
      body:          n.body,
      entityType:    n.entityType,
      entityId:      n.entityId,
      isRead:        read,
      creationDate:  n.creationDate,
      serviceRequest: n.serviceRequest,
      requester:     n.requester,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_router.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../models/notification_model.dart';
import 'widgets/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color:      context.colors.textPrimary,
            fontSize:   AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Marcar todas como leídas',
            onPressed: () => context
                .read<NotificationBloc>()
                .add(const NotificationsMarkAllRead()),
            icon: Icon(
              Icons.done_all,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: context.colors.error,
                    size: 48,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    state.message,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  ElevatedButton(
                    onPressed: () => context
                        .read<NotificationBloc>()
                        .add(const NotificationsLoadRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: context.colors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<NotificationBloc>()
                    .add(const NotificationsLoadRequested());
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.paddingL),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.paddingM),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () => _openDetail(context, notification),
                    onDelete: () => context
                        .read<NotificationBloc>()
                        .add(NotificationDeleted(notification.id)),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openDetail(BuildContext context, NotificationModel notification) {
    // Marcar como leída
    context
        .read<NotificationBloc>()
        .add(NotificationMarkRead(notification.id));

    final entityId = notification.entityId;
    if (entityId == null) return;

    Navigator.pushNamed(
      context,
      AppRouter.serviceRequestDetail,
      arguments: notification,
    );
  }
}

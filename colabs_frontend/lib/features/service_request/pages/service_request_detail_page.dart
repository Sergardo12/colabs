import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../notifications/models/notification_model.dart';

class ServiceRequestDetailPage extends StatelessWidget {
  final NotificationModel notification;

  const ServiceRequestDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final sr = notification.serviceRequest;
    final requester = notification.requester;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation:       0,
        title: Text(
          'Solicitud',
          style: TextStyle(
            color:      context.colors.textPrimary,
            fontSize:   AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        children: [
          // Solicitante
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color:        context.colors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.colors.primary.withOpacity(0.1),
                  backgroundImage: requester?.imageProfile != null
                      ? NetworkImage(requester!.imageProfile!)
                      : null,
                  child: requester?.imageProfile == null
                      ? Icon(Icons.person,
                          color: context.colors.primary, size: 28)
                      : null,
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requester?.fullName.isNotEmpty == true
                            ? requester!.fullName
                            : 'Solicitante',
                        style: TextStyle(
                          color:      context.colors.textPrimary,
                          fontSize:   AppSizes.fontL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (sr?.occupationName != null)
                        Text(
                          sr!.occupationName!,
                          style: TextStyle(
                            color:    context.colors.primary,
                            fontSize: AppSizes.fontM,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Descripción
          _InfoCard(
            icon: Icons.description_outlined,
            title: 'Descripción',
            child: Text(
              sr?.description ?? 'Sin descripción',
              style: TextStyle(
                color:    context.colors.textPrimary,
                fontSize: AppSizes.fontM,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Dirección
          _InfoCard(
            icon: Icons.location_on_outlined,
            title: 'Dirección',
            child: Text(
              sr?.direction ?? 'Sin dirección',
              style: TextStyle(
                color:    context.colors.textPrimary,
                fontSize: AppSizes.fontM,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primary, size: 18),
              const SizedBox(width: AppSizes.paddingXS),
              Text(
                title,
                style: TextStyle(
                  color:      context.colors.textPrimary,
                  fontSize:   AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          child,
        ],
      ),
    );
  }
}

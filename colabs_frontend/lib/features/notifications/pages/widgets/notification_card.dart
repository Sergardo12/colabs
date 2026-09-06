import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color:      context.colors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto del colaborador que cotiza (proposal_received)
            // o del solicitante en el resto de notificaciones
            CircleAvatar(
              radius: 22,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              backgroundImage:
                  (notification.proposal?.colab?.imageProfile ??
                      notification.requester?.imageProfile) != null
                  ? NetworkImage(notification.proposal?.colab?.imageProfile ??
                      notification.requester!.imageProfile!)
                  : null,
              child: (notification.proposal?.colab?.imageProfile ??
                          notification.requester?.imageProfile) ==
                      null
                  ? Icon(
                      Icons.person,
                      color: context.colors.primary,
                      size:  22,
                    )
                  : null,
            ),
            const SizedBox(width: AppSizes.paddingM),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge no leída
                  Row(
                    children: [
                      if (!notification.isRead) ...[
                        Container(
                          width:  8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:     context.colors.primary,
                            shape:     BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingXS),
                      ],
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color:      context.colors.textPrimary,
                            fontSize:   AppSizes.fontM,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Descripción del servicio
                  if (notification.serviceRequest?.description != null) ...[
                    Text(
                      notification.serviceRequest!.description!,
                      style: TextStyle(
                        color:    context.colors.textPrimary,
                        fontSize: AppSizes.fontM,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Dirección
                  if (notification.serviceRequest?.direction != null) ...[
                    const SizedBox(height: AppSizes.paddingXS),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: context.colors.textSecondary,
                          size:  14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notification.serviceRequest!.direction!,
                            style: TextStyle(
                              color:    context.colors.textSecondary,
                              fontSize: AppSizes.fontS,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Ocupación (chip)
                  if (notification.serviceRequest?.occupationName != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical:   AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color:        context.colors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      ),
                      child: Text(
                        notification.serviceRequest!.occupationName!,
                        style: TextStyle(
                          color:    context.colors.primary,
                          fontSize: AppSizes.fontS,
                        ),
                      ),
                    ),
                  ],

                  // Propuesta de precio (solo proposal_received)
                  if (notification.proposal != null) ...[
                    const SizedBox(height: AppSizes.paddingS),
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: context.colors.primary,
                          size:  16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'S/. ${notification.proposal!.amount?.toStringAsFixed(2)}',
                          style: TextStyle(
                            color:      context.colors.textPrimary,
                            fontSize:   AppSizes.fontM,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (notification.proposal!.distanceKm != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'a ${notification.proposal!.distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color:    context.colors.textSecondary,
                          fontSize: AppSizes.fontS,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // Botón eliminar
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.close,
                color: context.colors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

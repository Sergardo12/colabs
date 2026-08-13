import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback      onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colab = conversation.profileColab.user;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius:          24,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: colab.imageProfile != null
            ? NetworkImage(colab.imageProfile!)
            : null,
        child: colab.imageProfile == null
            ? const Icon(Icons.person, color: AppColors.primary, size: 24)
            : null,
      ),
      title: Text(
        '${colab.name} ${colab.lastName}',
        style: const TextStyle(
          color:      AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize:   AppSizes.fontL,
        ),
      ),
      subtitle: Text(
        _statusLabel(conversation.status),
        style: TextStyle(
          color:    _statusColor(conversation.status),
          fontSize: AppSizes.fontS,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':       return 'Conversación abierta';
      case 'offer_sent': return 'Oferta enviada';
      case 'accepted':   return 'Oferta aceptada';
      case 'closed':     return 'Cerrada';
      case 'expired':    return 'Expirada';
      default:           return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':       return AppColors.primary;
      case 'offer_sent': return Colors.orange;
      case 'accepted':   return Colors.green;
      case 'closed':
      case 'expired':    return AppColors.textSecondary;
      default:           return AppColors.textSecondary;
    }
  }
}

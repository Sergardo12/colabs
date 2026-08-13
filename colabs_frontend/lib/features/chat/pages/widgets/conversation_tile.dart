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
        backgroundColor: context.colors.primary.withOpacity(0.1),
        backgroundImage: colab.imageProfile != null
            ? NetworkImage(colab.imageProfile!)
            : null,
        child: colab.imageProfile == null
            ? Icon(Icons.person, color: context.colors.primary, size: 24)
            : null,
      ),
      title: Text(
        '${colab.name} ${colab.lastName}',
        style: TextStyle(
          color:      context.colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize:   AppSizes.fontL,
        ),
      ),
      subtitle: Text(
        _statusLabel(conversation.status),
        style: TextStyle(
          color:    _statusColor(conversation.status, context),
          fontSize: AppSizes.fontS,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.colors.textSecondary,
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

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'open':       return context.colors.primary;
      case 'offer_sent': return Colors.orange;
      case 'accepted':   return Colors.green;
      case 'closed':
      case 'expired':    return context.colors.textSecondary;
      default:           return context.colors.textSecondary;
    }
  }
}

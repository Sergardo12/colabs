import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String            currentUserId;
  final VoidCallback      onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Si soy el colaborador → muestro al demandante (user)
    // Si soy el demandante → muestro al colaborador (profileColab.user)
    final bool isColab = currentUserId ==
        conversation.profileColab.user.id;

    final String name;
    final String? imageProfile;

    if (isColab && conversation.user != null) {
      name         = '${conversation.user!.name} ${conversation.user!.lastName}';
      imageProfile = conversation.user!.imageProfile;
    } else {
      name         = '${conversation.profileColab.user.name} ${conversation.profileColab.user.lastName}';
      imageProfile = conversation.profileColab.user.imageProfile;
    }

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius:          24,
        backgroundColor: context.colors.primary.withOpacity(0.1),
        backgroundImage: imageProfile != null
            ? NetworkImage(imageProfile)
            : null,
        child: imageProfile == null
            ? Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 24)
            : null,
      ),
      title: Text(
        name,
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
      trailing: Text(
        _formatTime(conversation.createdAt),
        style: TextStyle(
          color:    context.colors.textSecondary,
          fontSize: AppSizes.fontS,
        ),
      ),
    );
  }

  String _formatTime(String createdAt) {
    final date = DateTime.parse(
      createdAt.endsWith('Z') ? createdAt : '${createdAt}Z',
    ).toLocal();
    final now  = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
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
      case 'accepted':   return const Color(0xFF4CAF50);
      case 'closed':
      case 'expired':    return context.colors.textSecondary;
      default:           return context.colors.textSecondary;
    }
  }
}

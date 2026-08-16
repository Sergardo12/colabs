import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool         isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left:   isMe ? 60 : AppSizes.paddingM,
          right:  isMe ? AppSizes.paddingM : 60,
          bottom: AppSizes.paddingS,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical:   AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isMe ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(AppSizes.radiusM),
            topRight:    const Radius.circular(AppSizes.radiusM),
            bottomLeft:  Radius.circular(isMe ? AppSizes.radiusM : 4),
            bottomRight: Radius.circular(isMe ? 4 : AppSizes.radiusM),
          ),
          boxShadow: [
            BoxShadow(
              color:      context.colors.textSecondary.withOpacity(0.08),
              blurRadius: 4,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == 'offer' && message.amount != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical:   AppSizes.paddingXS,
                ),
                margin: const EdgeInsets.only(bottom: AppSizes.paddingXS),
                decoration: BoxDecoration(
                  color:        context.colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  'Oferta: S/ ${message.amount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color:      isMe ? context.colors.white : context.colors.primary,
                    fontSize:   AppSizes.fontS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color:    isMe ? context.colors.white : context.colors.textPrimary,
                fontSize: AppSizes.fontM,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color:    isMe
                    ? context.colors.white.withOpacity(0.7)
                    : context.colors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String createdAt) {
    final date = DateTime.parse(createdAt).toLocal();
    final h    = date.hour.toString().padLeft(2, '0');
    final m    = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

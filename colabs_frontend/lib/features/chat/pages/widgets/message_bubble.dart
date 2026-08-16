import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel  message;
  final bool          isMe;
  final VoidCallback? onAcceptOffer;
  final bool          isOfferAccepted;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onAcceptOffer,
    this.isOfferAccepted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left:   isMe ? 80 : AppSizes.paddingM,
          right:  isMe ? AppSizes.paddingM : 80,
          bottom: AppSizes.paddingM,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical:   AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isMe ? context.colors.primary : context.colors.surface,
          borderRadius: isMe
              ? const BorderRadius.only(
                  topLeft:     Radius.circular(18),
                  topRight:    Radius.circular(18),
                  bottomLeft:  Radius.circular(18),
                  bottomRight: Radius.circular(4),
                )
              : const BorderRadius.only(
                  topLeft:     Radius.circular(4),
                  topRight:    Radius.circular(18),
                  bottomLeft:  Radius.circular(18),
                  bottomRight: Radius.circular(18),
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
            if (message.type == 'offer' && message.amount != null) ...[
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oferta: S/ ${message.amount!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:      isMe ? context.colors.white : context.colors.primary,
                        fontSize:   AppSizes.fontS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isMe) ...[
                      const SizedBox(height: AppSizes.paddingXS),
                      GestureDetector(
                        onTap: isOfferAccepted ? null : onAcceptOffer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical:   AppSizes.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: isOfferAccepted
                                ? const Color(0xFF4CAF50)
                                : context.colors.primary,
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Text(
                            isOfferAccepted
                                ? 'Oferta aceptada ✓'
                                : 'Aceptar oferta',
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   AppSizes.fontS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            Text(
              message.content,
              style: TextStyle(
                color:    isMe ? context.colors.white : context.colors.textPrimary,
                fontSize: AppSizes.fontM,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color:    isMe
                        ? context.colors.white.withOpacity(0.7)
                        : context.colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  Icon(
                    message.isRead
                        ? Icons.done_all
                        : Icons.done,
                    size:  12,
                    color: message.isRead
                        ? Colors.lightBlueAccent
                        : context.colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String createdAt) {
    final date = DateTime.parse(
      createdAt.endsWith('Z') ? createdAt : '${createdAt}Z',
    ).toLocal();
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

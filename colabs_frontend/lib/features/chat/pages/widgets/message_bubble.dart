import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel  message;
  final bool          isMe;
  final bool          isFlowA;
  final String        quoteStatus;
  final bool          isLatestQuote;
  final VoidCallback? onAcceptOffer;
  final VoidCallback? onAcceptQuote;
  final VoidCallback? onRejectQuote;
  final bool          isOfferAccepted;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isFlowA = false,
    this.quoteStatus = 'none',
    this.isLatestQuote = false,
    this.onAcceptOffer,
    this.onAcceptQuote,
    this.onRejectQuote,
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
            if (message.type == 'offer' && message.amount != null)
              if (isFlowA)
                _QuoteCard(
                  amount:   message.amount!,
                  isMe:     isMe,
                  status:   isLatestQuote ? quoteStatus : 'replaced',
                  onAccept: onAcceptQuote,
                  onReject: onRejectQuote,
                )
              else ...[
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

class _QuoteCard extends StatelessWidget {
  final double        amount;
  final bool          isMe;
  final String        status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _QuoteCard({
    required this.amount,
    required this.isMe,
    required this.status,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final accepted    = status == 'accepted';
    final rejected    = status == 'rejected';
    final replaced    = status == 'replaced';
    final pending     = status == 'pending';
    final showActions = !isMe && pending && onAccept != null && onReject != null;

    return Container(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.request_quote_outlined,
                size:  14,
                color: isMe ? context.colors.white : context.colors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Cotización: S/ ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color:      isMe ? context.colors.white : context.colors.primary,
                  fontSize:   AppSizes.fontS,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: AppSizes.paddingXS),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quoteActionButton(
                  context,
                  label: 'Aceptar',
                  color: const Color(0xFF4CAF50),
                  onTap: onAccept,
                ),
                const SizedBox(width: AppSizes.paddingXS),
                _quoteActionButton(
                  context,
                  label: 'Rechazar',
                  color: context.colors.error,
                  onTap: onReject,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'La solicitud pasará a "En proceso" al aceptar.',
              style: TextStyle(
                color:    isMe
                    ? context.colors.white.withOpacity(0.7)
                    : context.colors.textSecondary,
                fontSize: 10,
              ),
            ),
          ] else if (accepted || rejected || replaced)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                accepted
                    ? 'Cotización aceptada ✓'
                    : rejected
                        ? 'Cotización rechazada'
                        : 'Cotización reemplazada',
                style: TextStyle(
                  color:    accepted
                      ? const Color(0xFF4CAF50)
                      : context.colors.textSecondary,
                  fontSize: AppSizes.fontS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _quoteActionButton(
  BuildContext context, {
  required String        label,
  required Color         color,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical:   AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   AppSizes.fontS,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

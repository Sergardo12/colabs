import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_state.dart';
import '../../service_request/bloc/service_request_bloc.dart';
import '../../service_request/bloc/service_request_event.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../models/conversation_model.dart';
import '../../home/models/post_model.dart';
import 'widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;
  final String            currentUserId;
  final PostModel?        post;

  const ChatPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.post,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageCtrl   = TextEditingController();
  final ScrollController      _scrollCtrl    = ScrollController();
  Timer?                      _noticeTimer;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatOpened(
      conversationId: widget.conversation.id,
      currentUserId:  widget.currentUserId,
    ));
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scheduleNoticeDismiss(String? message) {
    if (message == null) return;
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.read<ChatBloc>().add(const ChatNoticeDismissed());
      }
    });
  }

  void _sendMessage() {
    final content = _messageCtrl.text.trim();
    if (content.isEmpty) return;
    context.read<ChatBloc>().add(MessageSendRequested(
      conversationId: widget.conversation.id,
      content:        content,
    ));
    _messageCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  void _showAcceptOfferDialog() {
    final directionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aceptar oferta'),
        content: TextField(
          controller: directionCtrl,
          decoration: const InputDecoration(
            hintText: 'Ingresa la dirección del servicio',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (directionCtrl.text.isEmpty) return;
              context.read<ChatBloc>().add(
                AcceptOfferRequested(
                  conversationId: widget.conversation.id,
                  direction:      directionCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showOfferBottomSheet() {
    final contentCtrl = TextEditingController();
    final amountCtrl  = TextEditingController();

    showModalBottomSheet(
      context:       context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left:    24,
          right:   24,
          top:     24,
          bottom:  MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        context.colors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Enviar oferta',
              style: TextStyle(
                color:      context.colors.textPrimary,
                fontSize:   AppSizes.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Descripción
            TextField(
              controller: contentCtrl,
              maxLines:   3,
              decoration: InputDecoration(
                hintText:    'Describe el servicio acordado...',
                filled:      true,
                fillColor:   context.colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide:   BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Monto
            TextField(
              controller:   amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText:    'Monto acordado',
                prefixText:  'S/. ',
                filled:      true,
                fillColor:   context.colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide:   BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text);
                  if (contentCtrl.text.isEmpty || amount == null) return;
                  context.read<ChatBloc>().add(
                    SendOfferRequested(
                      conversationId: widget.conversation.id,
                      content:        contentCtrl.text.trim(),
                      amount:         amount,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Enviar oferta',
                  style: TextStyle(
                    color:      context.colors.white,
                    fontSize:   AppSizes.fontL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuoteBottomSheet() {
    final amountCtrl = TextEditingController();
    final formKey    = GlobalKey<FormState>();

    showModalBottomSheet(
      context:       context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left:    24,
          right:   24,
          top:     24,
          bottom:  MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enviar cotización',
                style: TextStyle(
                  color:      context.colors.textPrimary,
                  fontSize:   AppSizes.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa el precio negociado con el solicitante. El demandante podrá aceptarlo o rechazarlo.',
                style: TextStyle(
                  color:    context.colors.textSecondary,
                  fontSize: AppSizes.fontM,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              TextFormField(
                controller:   amountCtrl,
                autofocus:    true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText:    '0.00',
                  prefixText:  'S/. ',
                  filled:      true,
                  fillColor:   context.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide:   BorderSide.none,
                  ),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final amount = double.parse(amountCtrl.text.trim());
                    context.read<ChatBloc>().add(
                      SendQuoteRequested(
                        conversationId: widget.conversation.id,
                        amount:         amount,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize:
                        const Size.fromHeight(AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: const Text('Enviar cotización'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el perfil del interlocutor
    final profileState  = context.read<ProfileBloc>().state;
    final currentUserId = profileState is ProfileSuccess
        ? profileState.user.id
        : widget.currentUserId;

    final bool isColab = currentUserId ==
        widget.conversation.profileColab.user.id;

    // Flujo A: canal vinculado a una solicitud de servicio (no a un post del feed)
    final bool isFlowA =
        widget.conversation.serviceRequestId != null &&
        widget.conversation.post == null &&
        widget.conversation.postId == null;

    final chatState = context.select<ChatBloc, ChatState>((bloc) => bloc.state);
    final serviceStatus = chatState is MessagesLoaded
        ? chatState.serviceStatus
        : '';
    final acceptedAmount = chatState is MessagesLoaded
        ? chatState.acceptedAmount
        : null;

    final String interlocutorName;
    final String? interlocutorImage;

    if (isColab && widget.conversation.user != null) {
      interlocutorName  = '${widget.conversation.user!.name} ${widget.conversation.user!.lastName}';
      interlocutorImage = widget.conversation.user!.imageProfile;
    } else {
      interlocutorName  = '${widget.conversation.profileColab.user.name} ${widget.conversation.profileColab.user.lastName}';
      interlocutorImage = widget.conversation.profileColab.user.imageProfile;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ChatBloc>().add(ChatClosed(
            conversationId: widget.conversation.id,
          ));
        }
      },
      child: Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation:       0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius:          18,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              backgroundImage: interlocutorImage != null
                  ? NetworkImage(interlocutorImage)
                  : null,
              child: interlocutorImage == null
                  ? Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 18)
                  : null,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Text(
                interlocutorName,
                maxLines:  1,
                overflow:  TextOverflow.ellipsis,
                style: TextStyle(
                  color:      context.colors.textPrimary,
                  fontSize:   AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (isFlowA && serviceStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingM),
              child: Center(child: _StatusChip(status: serviceStatus)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.post != null || widget.conversation.post != null)
            _PostReferenceBanner(post: widget.post ?? widget.conversation.post!),
          if (isFlowA && acceptedAmount != null)
            _PriceBanner(amount: acceptedAmount),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  _scrollToBottom();
                  _scheduleNoticeDismiss(state.floatingMessage);
                }
                if (state is OfferAccepted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '¡Oferta aceptada! Servicio creado correctamente 🎉',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
                if (state is QuoteAccepted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Cotización aceptada! El servicio está en proceso 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context
                      .read<ServiceRequestBloc>()
                      .add(const MyRequestsLoadRequested());
                  context
                      .read<ServiceRequestBloc>()
                      .add(const NearbyRequestsLoadRequested());
                  context
                      .read<ChatBloc>()
                      .add(const ConversationsLoadRequested());
                }
                if (state is QuoteRejected && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cotización rechazada')),
                  );
                  context
                      .read<ChatBloc>()
                      .add(const ConversationsLoadRequested());
                }
              },
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: context.colors.primary),
                  );
                }

                if (state is ChatError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: context.colors.error),
                    ),
                  );
                }

                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty &&
                      state.floatingMessage == null) {
                    return Center(
                      child: Text(
                        'Inicia la conversación',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding:    const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    itemCount:  state.messages.length +
                        (state.floatingMessage != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.floatingMessage != null &&
                          index == state.messages.length) {
                        return _FloatingNotice(
                          message: state.floatingMessage!,
                        );
                      }
                      final message  = state.messages[index];
                      final isMe     = message.senderId == state.currentUserId;
                      final isAccepted =
                          state.conversationStatus == 'accepted';
                      final lastQuoteIndex = state.messages
                          .lastIndexWhere((m) => m.type == 'offer');
                      final showQuoteActions =
                          isFlowA &&
                          !isMe &&
                          message.type == 'offer' &&
                          index == lastQuoteIndex &&
                          state.quoteStatus == 'pending';
                      return MessageBubble(
                        message:         message,
                        isMe:            isMe,
                        isFlowA:         isFlowA,
                        quoteStatus:     state.quoteStatus,
                        isLatestQuote:   message.type == 'offer' &&
                                         index == lastQuoteIndex,
                        onAcceptQuote: showQuoteActions
                            ? () => context.read<ChatBloc>().add(
                                  QuoteAcceptRequested(
                                    conversationId: state.conversationId,
                                  ),
                                )
                            : null,
                        onRejectQuote: showQuoteActions
                            ? () => context.read<ChatBloc>().add(
                                  QuoteRejectRequested(
                                    conversationId: state.conversationId,
                                  ),
                                )
                            : null,
                        onAcceptOffer:   isMe ? null : _showAcceptOfferDialog,
                        isOfferAccepted: isAccepted,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input de mensaje — reemplazado por un aviso si la conversación
          // está cerrada (servicio finalizado: solo lectura).
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            color:   context.colors.surface,
            child: SafeArea(
              child: widget.conversation.status == 'closed'
                  ? Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: context.colors.textSecondary,
                          size:  18,
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Expanded(
                          child: Text(
                            'Conversación cerrada — el servicio finalizó',
                            style: TextStyle(
                              color:    context.colors.textSecondary,
                              fontSize: AppSizes.fontM,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                children: [
                  // Botón de oferta/cotización — solo para el colaborador
                  if (widget.currentUserId ==
                      widget.conversation.profileColab.user.id)
                    if (isFlowA)
                      GestureDetector(
                        onTap: _showQuoteBottomSheet,
                        child: Container(
                          width:  44,
                          height: 44,
                          margin: const EdgeInsets.only(right: AppSizes.paddingS),
                          decoration: BoxDecoration(
                            color:        context.colors.primary.withOpacity(0.1),
                            shape:        BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.request_quote_outlined,
                            color: context.colors.primary,
                            size:  22,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _showOfferBottomSheet,
                        child: Container(
                          width:  44,
                          height: 44,
                          margin: const EdgeInsets.only(right: AppSizes.paddingS),
                          decoration: BoxDecoration(
                            color:        context.colors.primary.withOpacity(0.1),
                            shape:        BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.monetization_on_outlined,
                            color: context.colors.primary,
                            size:  22,
                          ),
                        ),
                      ),

                  // Campo de texto
                  Expanded(
                    child: TextField(
                      controller:     _messageCtrl,
                      decoration: InputDecoration(
                        hintText:    'Escribe un mensaje...',
                        filled:      true,
                        fillColor:   context.colors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          borderSide:   BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical:   AppSizes.paddingS,
                        ),
                      ),
                      onSubmitted:    (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),

                  // Botón enviar
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width:  44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:  context.colors.primary,
                        shape:  BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: context.colors.white,
                        size:  20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical:   AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color:        _statusColor(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Text(
        _statusLabel(),
        style: TextStyle(
          color:      _statusColor(context),
          fontSize:   AppSizes.fontS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (status) {
      case 'pending':     return 'Pendiente';
      case 'accepted':    return 'Aceptado';
      case 'in_progress': return 'En progreso';
      case 'completed':   return 'Completado';
      case 'cancelled':   return 'Cancelado';
      default:            return status;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (status) {
      case 'pending':     return Colors.orange;
      case 'accepted':    return Colors.green;
      case 'in_progress': return Colors.deepOrange;
      case 'completed':   return Colors.green;
      case 'cancelled':   return context.colors.error;
      default:            return context.colors.textSecondary;
    }
  }
}

class _PriceBanner extends StatelessWidget {
  final double amount;

  const _PriceBanner({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical:   AppSizes.paddingS,
      ),
      color: context.colors.primary.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 16, color: context.colors.primary),
          const SizedBox(width: AppSizes.paddingS),
          Text.rich(
            TextSpan(
              text:  'El precio final del servicio es de ',
              style: TextStyle(
                color:    context.colors.textSecondary,
                fontSize: AppSizes.fontS,
              ),
              children: [
                TextSpan(
                  text: 'S/. ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color:      context.colors.primary,
                    fontSize:   AppSizes.fontS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNotice extends StatelessWidget {
  final String message;

  const _FloatingNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXL,
        vertical:   AppSizes.paddingS,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical:   AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color:        context.colors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(color: context.colors.error.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size:   16,
                color:  context.colors.error,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:      context.colors.error,
                    fontSize:   AppSizes.fontS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostReferenceBanner extends StatelessWidget {
  final PostModel post;

  const _PostReferenceBanner({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      color:   context.colors.primary.withOpacity(0.05),
      child: Row(
        children: [
          // Imagen del post
          if (post.media.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Image.network(
                post.media.first,
                width:  56,
                height: 56,
                fit:    BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width:  56,
                  height: 56,
                  color:  context.colors.background,
                  child:  Icon(
                    Icons.image_not_supported_outlined,
                    color: context.colors.textSecondary,
                    size:  24,
                  ),
                ),
              ),
            )
          else
            Container(
              width:  56,
              height: 56,
              decoration: BoxDecoration(
                color:        context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.work_outline,
                color: context.colors.primary,
                size:  24,
              ),
            ),
          const SizedBox(width: AppSizes.paddingM),

          // Info del post
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post referenciado',
                  style: TextStyle(
                    color:    context.colors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
                Text(
                  post.description,
                  maxLines:  1,
                  overflow:  TextOverflow.ellipsis,
                  style: TextStyle(
                    color:      context.colors.textPrimary,
                    fontSize:   AppSizes.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'S/ ${post.price}',
                  style: TextStyle(
                    color:    context.colors.primary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_state.dart';
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
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Obtener el perfil del interlocutor
    final profileState  = context.read<ProfileBloc>().state;
    final currentUserId = profileState is ProfileSuccess
        ? profileState.user.id
        : widget.currentUserId;

    final bool isColab = currentUserId ==
        widget.conversation.profileColab.user.id;

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
            Text(
              interlocutorName,
              style: TextStyle(
                color:      context.colors.textPrimary,
                fontSize:   AppSizes.fontL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.post != null || widget.conversation.post != null)
            _PostReferenceBanner(post: widget.post ?? widget.conversation.post!),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) _scrollToBottom();
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
                  if (state.messages.isEmpty) {
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
                    itemCount:  state.messages.length,
                    itemBuilder: (context, index) {
                      final message  = state.messages[index];
                      final isMe     = message.senderId == state.currentUserId;
                      final isAccepted =
                          state.conversationStatus == 'accepted';
                      return MessageBubble(
                        message:         message,
                        isMe:            isMe,
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

          // Input de mensaje
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            color:   context.colors.surface,
            child: SafeArea(
              child: Row(
                children: [
                  // Botón de oferta — solo para el colaborador
                  if (widget.currentUserId ==
                      widget.conversation.profileColab.user.id)
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../models/conversation_model.dart';
import 'widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;
  final String            currentUserId;

  const ChatPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
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
    context.read<ChatBloc>().add(ChatClosed(
      conversationId: widget.conversation.id,
    ));
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

  @override
  Widget build(BuildContext context) {
    final colab = widget.conversation.profileColab.user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius:          18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: colab.imageProfile != null
                  ? NetworkImage(colab.imageProfile!)
                  : null,
              child: colab.imageProfile == null
                  ? const Icon(Icons.person, color: AppColors.primary, size: 18)
                  : null,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Text(
              '${colab.name} ${colab.lastName}',
              style: const TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   AppSizes.fontL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) _scrollToBottom();
              },
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is ChatError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'Inicia la conversación',
                        style: TextStyle(color: AppColors.textSecondary),
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
                      final message = state.messages[index];
                      final isMe    = message.senderId == state.currentUserId;
                      return MessageBubble(message: message, isMe: isMe);
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
            color:   AppColors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      decoration: InputDecoration(
                        hintText:    'Escribe un mensaje...',
                        filled:      true,
                        fillColor:   AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          borderSide:   BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical:   AppSizes.paddingS,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width:  44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:  AppColors.primary,
                        shape:  BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: AppColors.white,
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
    );
  }
}

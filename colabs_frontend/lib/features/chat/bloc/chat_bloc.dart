import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<ConversationsLoadRequested>(_onConversationsLoadRequested);
    on<ChatOpened>(_onChatOpened);
    on<ChatClosed>(_onChatClosed);
    on<MessageSendRequested>(_onMessageSendRequested);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<StartConversationRequested>(_onStartConversationRequested);
  }

  Future<void> _onConversationsLoadRequested(
    ConversationsLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ConversationsLoading());
    try {
      final conversations = await _chatRepository.getConversations();
      emit(ConversationsLoaded(conversations: conversations));
    } catch (e) {
      emit(const ChatError(message: 'Error al cargar conversaciones'));
    }
  }

  Future<void> _onChatOpened(
    ChatOpened event,
    Emitter<ChatState> emit,
  ) async {
    emit(MessagesLoading());
    try {
      await _chatRepository.connectSocket();
      _chatRepository.joinConversation(event.conversationId);
      _chatRepository.onNewMessage((message) {
        add(NewMessageReceived(message: message));
      });
      final messages = await _chatRepository.getMessages(event.conversationId);
      emit(MessagesLoaded(
        messages:       messages,
        conversationId: event.conversationId,
        currentUserId:  event.currentUserId,
      ));
    } catch (e) {
      emit(const ChatError(message: 'Error al abrir el chat'));
    }
  }

  Future<void> _onChatClosed(
    ChatClosed event,
    Emitter<ChatState> emit,
  ) async {
    _chatRepository.leaveConversation(event.conversationId);
    _chatRepository.disconnect();
    emit(ChatInitial());
  }

  Future<void> _onMessageSendRequested(
    MessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! MessagesLoaded) return;
    try {
      final message = await _chatRepository.sendMessage(
        conversationId: event.conversationId,
        content:        event.content,
      );
      emit(MessagesLoaded(
        messages:       [...current.messages, message],
        conversationId: current.conversationId,
        currentUserId:  current.currentUserId,
      ));
    } catch (e) {
      emit(const ChatError(message: 'Error al enviar el mensaje'));
    }
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! MessagesLoaded) return;
    final exists = current.messages.any((m) => m.id == event.message.id);
    if (exists) return;
    emit(MessagesLoaded(
      messages:       [...current.messages, event.message],
      conversationId: current.conversationId,
      currentUserId:  current.currentUserId,
    ));
  }

  Future<void> _onStartConversationRequested(
    StartConversationRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ConversationsLoading());
    try {
      final conversation = await _chatRepository.createConversation(
        profileColabId: event.profileColabId,
        postId:         event.postId,
      );
      emit(ConversationCreated(conversation: conversation));
    } catch (e) {
      if (e.toString().contains('409')) {
        // Ya existe una conversación — buscar y navegar a ella
        try {
          final conversations = await _chatRepository.getConversations();
          final existing = conversations.firstWhere(
            (c) => c.profileColabId == event.profileColabId,
          );
          emit(ConversationCreated(conversation: existing));
        } catch (e2) {
          emit(const ChatError(message: 'Error al abrir la conversación'));
        }
      } else {
        emit(const ChatError(message: 'Error al iniciar la conversación'));
      }
    }
  }
}

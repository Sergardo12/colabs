import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../data/chat_repository.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
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
    on<SendOfferRequested>(_onSendOfferRequested);
    on<AcceptOfferRequested>(_onAcceptOfferRequested);
    on<SendQuoteRequested>(_onSendQuoteRequested);
    on<QuoteStatusLoadRequested>(_onQuoteStatusLoadRequested);
    on<QuoteAcceptRequested>(_onQuoteAcceptRequested);
    on<QuoteRejectRequested>(_onQuoteRejectRequested);
    on<ChatNoticeDismissed>(_onChatNoticeDismissed);
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
      // Conecta solo si no hay socket activo (evita reconexión en cada apertura)
      if (!_chatRepository.isSocketConnected) {
        await _chatRepository.connectSocket();
      }
      _chatRepository.joinConversation(event.conversationId);
      _chatRepository.onNewMessage((message) {
        add(NewMessageReceived(message: message));
      });
      final results = await Future.wait([
        _chatRepository.getMessages(event.conversationId),
        _chatRepository.getConversation(event.conversationId),
        _chatRepository.getQuote(event.conversationId),
      ]);
      final messages     = results[0] as List<MessageModel>;
      final conversation = results[1] as ConversationModel;
      final quote        = results[2] as Map<String, dynamic>;
      emit(MessagesLoaded(
        messages:           messages,
        conversationId:     event.conversationId,
        currentUserId:      event.currentUserId,
        conversationStatus: conversation.status,
        quoteStatus:        quote['status'] as String? ?? 'none',
        serviceStatus:      quote['serviceRequestStatus'] as String? ?? '',
        acceptedAmount:     (quote['acceptedAmount'] as num?)?.toDouble(),
      ));
    } catch (e) {
      emit(const ChatError(message: 'Error al abrir el chat'));
    }
  }

  Future<void> _onChatClosed(
    ChatClosed event,
    Emitter<ChatState> emit,
  ) async {
    // No desconecta el socket global: solo sale de la sala de la conversación
    _chatRepository.leaveConversation(event.conversationId);
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
        messages:           [...current.messages, message],
        conversationId:     current.conversationId,
        currentUserId:      current.currentUserId,
        conversationStatus: current.conversationStatus,
        quoteStatus:        current.quoteStatus,
        serviceStatus:      current.serviceStatus,
        acceptedAmount:     current.acceptedAmount,
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
      messages:           [...current.messages, event.message],
      conversationId:     current.conversationId,
      currentUserId:      current.currentUserId,
      conversationStatus: current.conversationStatus,
      quoteStatus:        current.quoteStatus,
      serviceStatus:      current.serviceStatus,
      acceptedAmount:     current.acceptedAmount,
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
      emit(ConversationCreated(
        conversation: conversation,
        post:         event.post,
      ));
    } catch (e) {
      if (e.toString().contains('409')) {
        // Ya existe una conversación — buscar y navegar a ella
        try {
          final conversations = await _chatRepository.getConversations();
          final existing = conversations.firstWhere(
            (c) =>
                c.profileColabId == event.profileColabId &&
                c.postId == event.postId,
          );
          emit(ConversationCreated(
            conversation: existing,
            post:         event.post,
          ));
        } catch (e2) {
          emit(const ChatError(message: 'Error al abrir la conversación'));
        }
      } else {
        emit(const ChatError(message: 'Error al iniciar la conversación'));
      }
    }
  }

  Future<void> _onSendOfferRequested(
    SendOfferRequested event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! MessagesLoaded) return;
    try {
      final message = await _chatRepository.sendOffer(
        conversationId: event.conversationId,
        content:        event.content,
        amount:         event.amount,
      );
      emit(MessagesLoaded(
        messages:           [...current.messages, message],
        conversationId:     current.conversationId,
        currentUserId:      current.currentUserId,
        conversationStatus: current.conversationStatus,
        quoteStatus:        current.quoteStatus,
        serviceStatus:      current.serviceStatus,
        acceptedAmount:     current.acceptedAmount,
      ));
    } catch (e) {
      emit(const ChatError(message: 'Error al enviar la oferta'));
    }
  }

  Future<void> _onAcceptOfferRequested(
    AcceptOfferRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final result = await _chatRepository.acceptOffer(
        conversationId: event.conversationId,
        direction:      event.direction,
      );
      final serviceRequestId =
          result['serviceRequest']['id'] as String;
      final current = state;
      if (current is MessagesLoaded) {
        emit(MessagesLoaded(
          messages:           current.messages,
          conversationId:     current.conversationId,
          currentUserId:      current.currentUserId,
          conversationStatus: 'accepted',
          quoteStatus:        current.quoteStatus,
          serviceStatus:      current.serviceStatus,
          acceptedAmount:     current.acceptedAmount,
        ));
      }
      emit(OfferAccepted(serviceRequestId: serviceRequestId));
    } catch (e) {
      emit(const ChatError(message: 'Error al aceptar la oferta'));
    }
  }

  Future<void> _onSendQuoteRequested(
    SendQuoteRequested event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! MessagesLoaded) return;
    try {
      final message = await _chatRepository.sendQuote(
        conversationId: event.conversationId,
        amount:         event.amount,
      );
      // La cotización enviada queda como pendiente de decisión del demandante
      emit(MessagesLoaded(
        messages:           [...current.messages, message],
        conversationId:     current.conversationId,
        currentUserId:      current.currentUserId,
        conversationStatus: current.conversationStatus,
        quoteStatus:        'pending',
        serviceStatus:      current.serviceStatus,
        acceptedAmount:     current.acceptedAmount,
      ));
    } catch (e) {
      final message = _sendQuoteError(e);
      if (message == 'Error al enviar la cotización') {
        emit(ChatError(message: message));
      } else {
        // Error de negocio (p. ej. cotización ya aceptada): se muestra como
        // mensaje flotante dentro del chat sin romper la conversación.
        emit(MessagesLoaded(
          messages:           current.messages,
          conversationId:     current.conversationId,
          currentUserId:      current.currentUserId,
          conversationStatus: current.conversationStatus,
          quoteStatus:        current.quoteStatus,
          serviceStatus:      current.serviceStatus,
          acceptedAmount:     current.acceptedAmount,
          floatingMessage:    message,
        ));
      }
    }
  }

  void _onChatNoticeDismissed(
    ChatNoticeDismissed event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! MessagesLoaded) return;
    if (current.floatingMessage == null) return;
    emit(MessagesLoaded(
      messages:           current.messages,
      conversationId:     current.conversationId,
      currentUserId:      current.currentUserId,
      conversationStatus: current.conversationStatus,
      quoteStatus:        current.quoteStatus,
      serviceStatus:      current.serviceStatus,
      acceptedAmount:     current.acceptedAmount,
    ));
  }

  String _sendQuoteError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) return message;
        if (message is List && message.isNotEmpty && message.first is String) {
          return message.first as String;
        }
      }
    }
    return 'Error al enviar la cotización';
  }

  Future<void> _onQuoteStatusLoadRequested(
    QuoteStatusLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! MessagesLoaded) return;
    try {
      final quote = await _chatRepository.getQuote(event.conversationId);
      emit(MessagesLoaded(
        messages:           current.messages,
        conversationId:     current.conversationId,
        currentUserId:      current.currentUserId,
        conversationStatus: current.conversationStatus,
        quoteStatus:        quote['status'] as String? ?? 'none',
        serviceStatus:      quote['serviceRequestStatus'] as String? ?? '',
        acceptedAmount:     (quote['acceptedAmount'] as num?)?.toDouble(),
      ));
    } catch (_) {
      // Si no se puede leer el estado, se mantiene el actual.
    }
  }

  Future<void> _onQuoteAcceptRequested(
    QuoteAcceptRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.acceptQuote(event.conversationId);
      final quote = await _chatRepository.getQuote(event.conversationId);
      final current = state;
      if (current is MessagesLoaded) {
        emit(MessagesLoaded(
          messages:           current.messages,
          conversationId:     current.conversationId,
          currentUserId:      current.currentUserId,
          conversationStatus: 'accepted',
          quoteStatus:        quote['status'] as String? ?? 'accepted',
          serviceStatus:      quote['serviceRequestStatus'] as String? ?? '',
          acceptedAmount:     (quote['acceptedAmount'] as num?)?.toDouble(),
        ));
      }
      emit(QuoteAccepted(conversationId: event.conversationId));
    } catch (e) {
      emit(const ChatError(message: 'Error al aceptar la cotización'));
    }
  }

  Future<void> _onQuoteRejectRequested(
    QuoteRejectRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.rejectQuote(event.conversationId);
      final quote = await _chatRepository.getQuote(event.conversationId);
      final current = state;
      if (current is MessagesLoaded) {
        emit(MessagesLoaded(
          messages:           current.messages,
          conversationId:     current.conversationId,
          currentUserId:      current.currentUserId,
          conversationStatus: current.conversationStatus,
          quoteStatus:        quote['status'] as String? ?? 'rejected',
          serviceStatus:      quote['serviceRequestStatus'] as String? ?? '',
          acceptedAmount:     (quote['acceptedAmount'] as num?)?.toDouble(),
        ));
      }
      emit(QuoteRejected(conversationId: event.conversationId));
    } catch (e) {
      emit(const ChatError(message: 'Error al rechazar la cotización'));
    }
  }
}

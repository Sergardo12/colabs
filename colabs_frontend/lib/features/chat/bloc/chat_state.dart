import 'package:equatable/equatable.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../home/models/post_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ConversationsLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;
  const ConversationsLoaded({required this.conversations});
  @override
  List<Object?> get props => [conversations];
}

class MessagesLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  final String             conversationId;
  final String             currentUserId;
  final String             conversationStatus;
  const MessagesLoaded({
    required this.messages,
    required this.conversationId,
    required this.currentUserId,
    required this.conversationStatus,
  });
  @override
  List<Object?> get props =>
      [messages, conversationId, currentUserId, conversationStatus];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ConversationCreated extends ChatState {
  final ConversationModel conversation;
  final PostModel?        post;

  const ConversationCreated({
    required this.conversation,
    this.post,
  });

  @override
  List<Object?> get props => [conversation, post];
}

class OfferAccepted extends ChatState {
  final String serviceRequestId;

  const OfferAccepted({required this.serviceRequestId});

  @override
  List<Object?> get props => [serviceRequestId];
}

import 'package:equatable/equatable.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

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
  const MessagesLoaded({
    required this.messages,
    required this.conversationId,
    required this.currentUserId,
  });
  @override
  List<Object?> get props => [messages, conversationId, currentUserId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ConversationCreated extends ChatState {
  final ConversationModel conversation;
  const ConversationCreated({required this.conversation});
  @override
  List<Object?> get props => [conversation];
}

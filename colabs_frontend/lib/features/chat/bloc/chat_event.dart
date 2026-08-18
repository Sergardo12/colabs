import 'package:equatable/equatable.dart';
import '../models/message_model.dart';
import '../../home/models/post_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ConversationsLoadRequested extends ChatEvent {
  const ConversationsLoadRequested();
}

class ChatOpened extends ChatEvent {
  final String conversationId;
  final String currentUserId;
  const ChatOpened({
    required this.conversationId,
    required this.currentUserId,
  });
  @override
  List<Object?> get props => [conversationId, currentUserId];
}

class ChatClosed extends ChatEvent {
  final String conversationId;
  const ChatClosed({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

class MessageSendRequested extends ChatEvent {
  final String conversationId;
  final String content;
  const MessageSendRequested({
    required this.conversationId,
    required this.content,
  });
  @override
  List<Object?> get props => [conversationId, content];
}

class NewMessageReceived extends ChatEvent {
  final MessageModel message;
  const NewMessageReceived({required this.message});
  @override
  List<Object?> get props => [message];
}

class StartConversationRequested extends ChatEvent {
  final String    profileColabId;
  final String?   postId;
  final PostModel? post;

  const StartConversationRequested({
    required this.profileColabId,
    this.postId,
    this.post,
  });

  @override
  List<Object?> get props => [profileColabId, postId, post];
}

class SendOfferRequested extends ChatEvent {
  final String conversationId;
  final String content;
  final double amount;

  const SendOfferRequested({
    required this.conversationId,
    required this.content,
    required this.amount,
  });

  @override
  List<Object?> get props => [conversationId, content, amount];
}

class AcceptOfferRequested extends ChatEvent {
  final String conversationId;
  final String direction;

  const AcceptOfferRequested({
    required this.conversationId,
    required this.direction,
  });

  @override
  List<Object?> get props => [conversationId, direction];
}

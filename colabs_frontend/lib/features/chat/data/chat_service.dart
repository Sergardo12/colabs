import 'package:dio/dio.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio);

  /// Lista todas las conversaciones del usuario autenticado
  Future<List<ConversationModel>> getConversations({
    required String token,
  }) async {
    final response = await _dio.get(
      '/conversations',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List<dynamic>)
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Inicia una conversación con un colaborador
  Future<ConversationModel> createConversation({
    required String token,
    required String profileColabId,
    String? postId,
  }) async {
    final response = await _dio.post(
      '/conversations',
      data: {
        'profileColabId': profileColabId,
        if (postId != null) 'postId': postId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ConversationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene los mensajes de una conversación
  Future<List<MessageModel>> getMessages({
    required String token,
    required String conversationId,
  }) async {
    final response = await _dio.get(
      '/conversations/$conversationId/messages',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List<dynamic>)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene una conversación con su estado actualizado
  Future<ConversationModel> getConversation({
    required String token,
    required String conversationId,
  }) async {
    final response = await _dio.get(
      '/conversations/$conversationId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ConversationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Envía un mensaje en una conversación
  Future<MessageModel> sendMessage({
    required String token,
    required String conversationId,
    required String content,
  }) async {
    final response = await _dio.post(
      '/conversations/$conversationId/messages',
      data: {'content': content},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Envía una oferta formal en una conversación
  Future<MessageModel> sendOffer({
    required String token,
    required String conversationId,
    required String content,
    required double amount,
  }) async {
    final response = await _dio.post(
      '/conversations/$conversationId/messages',
      data: {
        'content': content,
        'type':    'offer',
        'amount':  amount,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Acepta una oferta y crea el service_request
  Future<Map<String, dynamic>> acceptOffer({
    required String token,
    required String conversationId,
    required String direction,
  }) async {
    final response = await _dio.patch(
      '/conversations/$conversationId/accept-offer',
      data: {'direction': direction},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Envía una cotización final en el chat (Flujo A — solo colaborador)
  Future<MessageModel> sendQuote({
    required String token,
    required String conversationId,
    required double amount,
  }) async {
    final response = await _dio.post(
      '/conversations/$conversationId/quote',
      data: {'amount': amount},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Estado de la cotización de la conversación
  Future<Map<String, dynamic>> getQuote({
    required String token,
    required String conversationId,
  }) async {
    final response = await _dio.get(
      '/conversations/$conversationId/quote',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Acepta una cotización del chat (Flujo A — demandante)
  Future<Map<String, dynamic>> acceptQuote({
    required String token,
    required String conversationId,
  }) async {
    final response = await _dio.patch(
      '/conversations/$conversationId/quote/accept',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Rechaza una cotización del chat (Flujo A — demandante)
  Future<Map<String, dynamic>> rejectQuote({
    required String token,
    required String conversationId,
  }) async {
    final response = await _dio.patch(
      '/conversations/$conversationId/quote/reject',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }
}

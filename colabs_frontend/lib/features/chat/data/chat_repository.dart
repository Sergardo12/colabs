import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'chat_service.dart';
import 'chat_socket_service.dart';

class ChatRepository {
  final ChatService          _chatService;
  final ChatSocketService    _socketService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  ChatRepository({
    required ChatService          chatService,
    required ChatSocketService    socketService,
    required FlutterSecureStorage secureStorage,
  })  : _chatService    = chatService,
        _socketService  = socketService,
        _secureStorage  = secureStorage;

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return token;
  }

  /// Conecta el WebSocket
  Future<void> connectSocket() async {
    final token = await _getToken();
    _socketService.connect(token);
  }

  /// Registra el usuario en el Gateway
  void registerUser(String userId) {
    _socketService.registerUser(userId);
  }

  /// Entra a la sala de una conversación
  void joinConversation(String conversationId) {
    _socketService.joinConversation(conversationId);
  }

  /// Sale de la sala de una conversación
  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  /// Escucha mensajes nuevos
  void onNewMessage(Function(MessageModel) callback) {
    _socketService.onNewMessage(callback);
  }

  /// Desconecta el WebSocket
  void disconnect() {
    _socketService.disconnect();
  }

  /// Lista conversaciones
  Future<List<ConversationModel>> getConversations() async {
    final token = await _getToken();
    return _chatService.getConversations(token: token);
  }

  /// Inicia una conversación
  Future<ConversationModel> createConversation({
    required String profileColabId,
    String? postId,
  }) async {
    final token = await _getToken();
    return _chatService.createConversation(
      token:          token,
      profileColabId: profileColabId,
      postId:         postId,
    );
  }

  /// Obtiene mensajes
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final token = await _getToken();
    return _chatService.getMessages(
      token:          token,
      conversationId: conversationId,
    );
  }

  /// Obtiene una conversación con su estado actualizado
  Future<ConversationModel> getConversation(String conversationId) async {
    final token = await _getToken();
    return _chatService.getConversation(
      token:          token,
      conversationId: conversationId,
    );
  }

  /// Envía un mensaje
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final token = await _getToken();
    return _chatService.sendMessage(
      token:          token,
      conversationId: conversationId,
      content:        content,
    );
  }

  /// Envía una oferta formal
  Future<MessageModel> sendOffer({
    required String conversationId,
    required String content,
    required double amount,
  }) async {
    final token = await _getToken();
    return _chatService.sendOffer(
      token:          token,
      conversationId: conversationId,
      content:        content,
      amount:         amount,
    );
  }

  /// Acepta una oferta
  Future<Map<String, dynamic>> acceptOffer({
    required String conversationId,
    required String direction,
  }) async {
    final token = await _getToken();
    return _chatService.acceptOffer(
      token:          token,
      conversationId: conversationId,
      direction:      direction,
    );
  }
}

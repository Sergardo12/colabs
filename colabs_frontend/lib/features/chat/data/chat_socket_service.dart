import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message_model.dart';

class ChatSocketService {
  IO.Socket? _socket;
  final String _baseUrl = 'http://10.0.2.2:8080';

  /// Conecta al WebSocket con el JWT del usuario
  void connect(String token) {
    _socket = IO.io(
      '$_baseUrl/colabs',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );
    _socket!.connect();
  }

  /// Registra el userId en el Gateway
  void registerUser(String userId) {
    _socket?.emit('register', {'userId': userId});
  }

  /// Entra a la sala de una conversación
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', {'conversationId': conversationId});
  }

  /// Sale de la sala de una conversación
  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', {'conversationId': conversationId});
  }

  /// Escucha mensajes nuevos en tiempo real
  void onNewMessage(Function(MessageModel) callback) {
    _socket?.on('new_message', (data) {
      final message = MessageModel.fromJson(data as Map<String, dynamic>);
      callback(message);
    });
  }

  /// Desconecta el socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
}

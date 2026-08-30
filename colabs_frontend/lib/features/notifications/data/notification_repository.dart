import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  NotificationRepository({
    required NotificationService  notificationService,
    required FlutterSecureStorage secureStorage,
  })  : _notificationService = notificationService,
        _secureStorage       = secureStorage;

  Future<List<NotificationModel>> getEnriched() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _notificationService.getEnriched(token: token);
  }

  Future<void> markAsRead(String id) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    await _notificationService.markAsRead(token: token, id: id);
  }

  Future<void> markAllAsRead() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    await _notificationService.markAllAsRead(token: token);
  }

  Future<void> delete(String id) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    await _notificationService.delete(token: token, id: id);
  }
}

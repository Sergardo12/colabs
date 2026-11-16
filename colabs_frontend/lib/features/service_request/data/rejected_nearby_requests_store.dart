import 'package:shared_preferences/shared_preferences.dart';

/// Persiste localmente las solicitudes cercanas que un colaborador rechazó.
/// No altera el registro global: solo se usa para filtrar su vista (HEAD 4).
class RejectedNearbyRequestsStore {
  static const String _keyPrefix = 'rejected_nearby_requests_';

  Future<Set<String>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('$_keyPrefix$userId') ?? const [];
    return values.toSet();
  }

  Future<void> add(String userId, String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final values = (prefs.getStringList(key) ?? const []).toSet()
      ..add(requestId);
    await prefs.setStringList(key, values.toList());
  }
}

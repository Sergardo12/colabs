import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  const ThemeRepository();

  static const String _darkKey = 'theme_dark';

  /// Lee el estado del tema guardado — default: tema claro
  Future<bool> isDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkKey) ?? false;
  }

  /// Persiste el estado del tema seleccionado
  Future<void> saveDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, isDark);
  }
}

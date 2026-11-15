class AppDate {
  AppDate._();

  static final RegExp _hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$');

  /// Instante del API (UTC) -> hora local del dispositivo.
  static DateTime fromApi(String iso) {
    final s = _hasZone.hasMatch(iso) ? iso : '${iso}Z';
    return DateTime.parse(s).toLocal();
  }

  static DateTime? tryFromApi(String? iso) =>
      iso == null ? null : fromApi(iso);

  /// Instante local -> UTC ISO 8601 para enviar al API.
  static String toApi(DateTime d) => d.toUtc().toIso8601String();

  static String hhmm(String iso) {
    final d = fromApi(iso);
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
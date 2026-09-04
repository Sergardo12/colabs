/// Construye el enlace y el texto para compartir un perfil público.
/// El scheme `colabs://` está listo para conectarse al deep link (Fase B).
class ProfileLinkBuilder {
  ProfileLinkBuilder._();

  static const String _scheme = 'colabs://';

  static String buildLink({required String userId}) =>
      '${_scheme}public-profile/$userId';

  static String buildShareText({
    required String userId,
    required String name,
  }) {
    return 'Te comparto el perfil de $name en Colabs\n'
        '${buildLink(userId: userId)}';
  }
}

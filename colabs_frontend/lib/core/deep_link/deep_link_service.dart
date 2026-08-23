import 'package:app_links/app_links.dart';
import 'deep_link_target.dart';

class DeepLinkService {
  DeepLinkService();

  static const String _scheme = 'colabs';
  static const String _publicProfilePath = 'public-profile';

  final AppLinks _appLinks = AppLinks();

  Future<Uri?> getInitialLink() => _appLinks.getInitialLink();

  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;

  DeepLinkTarget? parse(Uri uri) {
    if (uri.scheme != _scheme) return null;
    final segments = uri.pathSegments;
    String? userId;
    if (uri.host == _publicProfilePath) {
      // colabs://public-profile/<userId>  (public-profile en la autoridad/host)
      userId = segments.isNotEmpty ? segments.first : null;
    } else if (segments.length >= 2 && segments.first == _publicProfilePath) {
      // colabs://colabs/public-profile/<userId>  o  colabs:/public-profile/<userId>
      userId = segments[1];
    }
    if (userId == null || userId.isEmpty) return null;
    return DeepLinkTarget(
      type:   DeepLinkType.publicProfile,
      userId: userId,
    );
  }
}

import 'package:throwtrash/usecase/url_launcher_interface.dart';

class UrlLauncherService implements UrlLauncherInterface {
  @override
  Future<bool> canLaunchUrl(Uri url) async {
    return await canLaunchUrl(url);
  }
}

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/usecase/repository/app_version_repository_interface.dart';

class AppVersionRepository implements AppVersionRepositoryInterface {
  static const String _appVersionKey = 'app_version';

  @override
  Future<String?> getSavedAppVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appVersionKey);
  }

  @override
  Future<void> saveAppVersion(String version) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appVersionKey, version);
  }

  Future<String> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}


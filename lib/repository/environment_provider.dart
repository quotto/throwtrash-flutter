import 'package:package_info_plus/package_info_plus.dart';
import 'package:throwtrash/usecase/environment_provider_interface.dart';

class EnvironmentProvider implements EnvironmentProviderInterface {
  String _versionName = "";

  Future<void> initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _versionName = packageInfo.version;
  }

  @override
  String get flavor => const String.fromEnvironment('flavor');
  @override
  String get appIdSuffix => const String.fromEnvironment('appIdSuffix');
  @override
  String get appNameSuffix => const String.fromEnvironment('appNameSuffix');
  @override
  String get versionName => _versionName;
  @override
  String get alarmApiKey => const String.fromEnvironment('alarmApiKey');
}
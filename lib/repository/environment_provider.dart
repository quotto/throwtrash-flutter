import 'package:package_info_plus/package_info_plus.dart';
import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';

class EnvironmentProvider implements EnvironmentProviderInterface {
  final String _versionName;
  static EnvironmentProvider? _instance;

  EnvironmentProvider._(this._versionName);

  static Future<void> initialize() async {
    if(_instance!=null) {
      throw StateError("EnvironmentProvider is already initialized");
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _instance = EnvironmentProvider._(packageInfo.version);
  }

  factory EnvironmentProvider() {
    if(_instance==null) {
      throw StateError("EnvironmentProvider is not initialized");
    }
    return _instance!;
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
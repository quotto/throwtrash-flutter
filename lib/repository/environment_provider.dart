import 'package:throwtrash/usecase/repository/environment_provider_interface.dart';

class EnvironmentProvider implements EnvironmentProviderInterface {
  static EnvironmentProvider? _instance;

  EnvironmentProvider._();

  static Future<void> initialize() async {
    if(_instance!=null) {
      throw StateError("EnvironmentProvider is already initialized");
    }
    _instance = EnvironmentProvider._();
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
  String get alarmApiKey => const String.fromEnvironment('alarmApiKey');
}
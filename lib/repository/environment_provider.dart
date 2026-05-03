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
  String get flavor {
    const lowerFlavor = String.fromEnvironment('flavor');
    if (lowerFlavor.isNotEmpty) {
      return lowerFlavor;
    }

    const upperFlavor = String.fromEnvironment('FLAVOR');
    if (upperFlavor.isNotEmpty) {
      return upperFlavor;
    }

    // --dart-define 未指定時は開発向け設定を利用する
    return 'development';
  }
  @override
  String get alarmApiKey => const String.fromEnvironment('alarmApiKey');
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/usecase/repository/config_repository_interface.dart';

class ConfigRepository implements ConfigRepositoryInterface {
  static const String DARK_MODE_KEY = 'DARK_MODE';
  static const String DEVICE_TOKEN_KEY = 'DEVICE_TOKEN';

  static ConfigRepository? _instance;
  final SharedPreferences _preferences;

  ConfigRepository._(this._preferences);

  static void initialize(SharedPreferences preferences) {
    if(_instance != null) {
      throw StateError('ConfigRepositoryは既に初期化されています');
    }
    _instance = ConfigRepository._(preferences);
  }

  factory ConfigRepository() {
    if(_instance == null) {
      throw StateError('ConfigRepositoryが初期化されていません');
    }
    return _instance!;
  }

  @override
  Future<bool> saveDarkMode(bool darkMode) async {
    return this._preferences.setBool(DARK_MODE_KEY, darkMode);
  }

  @override
  Future<bool?> readDarkMode() async {
    return Future.value(this._preferences.getBool(DARK_MODE_KEY));
  }

  @override
  Future<String?> getDeviceToken() async {
    return Future.value(this._preferences.getString(DEVICE_TOKEN_KEY));
  }

  @override
  Future<bool> saveDeviceToken(String deviceToken) async {
    return this._preferences.setString(DEVICE_TOKEN_KEY, deviceToken);
  }
}
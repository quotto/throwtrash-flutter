import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/usecase/config_repository_interface.dart';

class ConfigRepository implements ConfigRepositoryInterface {
  static const String DARK_MODE_KEY = 'DARK_MODE';

  @override
  Future<bool> saveDarkMode(bool darkMode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setBool(DARK_MODE_KEY, darkMode);
  }

  @override
  Future<bool?> readDarkMode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return Future.value(preferences.getBool(DARK_MODE_KEY));
  }
}
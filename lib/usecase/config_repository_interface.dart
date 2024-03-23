abstract class ConfigRepositoryInterface {
  Future<bool> saveDarkMode(bool isDarkMode);
  Future<bool?> readDarkMode();
  Future<String?> getDeviceToken();
  Future<bool> saveDeviceToken(String deviceToken);
}
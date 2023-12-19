abstract class ConfigRepositoryInterface {
  Future<bool> saveDarkMode(bool isDarkMode);
  Future<bool?> readDarkMode();
}
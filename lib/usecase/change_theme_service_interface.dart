abstract class ChangeThemeServiceInterface {
  Future<void> switchDarkMode(bool darkMode);
  Future<bool> readDarkMode();
}
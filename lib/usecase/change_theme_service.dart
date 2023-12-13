import 'package:throwtrash/usecase/config_repository_interface.dart';

import 'change_theme_service_interface.dart';

class ChangeThemeService implements ChangeThemeServiceInterface {
  ChangeThemeService(this._themeRepository);

  final ConfigRepositoryInterface _themeRepository;

  @override
  Future<void> switchDarkMode(bool darkMode) async {
    if(!await _themeRepository.saveDarkMode(darkMode)) {
      throw Exception("DarkModeの保存に失敗しました");
    }
  }
}
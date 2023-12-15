import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/usecase/change_theme_service.dart';
import 'package:throwtrash/usecase/config_repository_interface.dart';

import 'change_theme_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ConfigRepositoryInterface>()])
void main () {
  group('ChangeThemeModel', ()
  {
    late MockConfigRepositoryInterface configRepository;
    late ChangeThemeService changeThemeService;

    setUp(() {
      configRepository = MockConfigRepositoryInterface();
      changeThemeService = ChangeThemeService(configRepository);
    });

    test('switchDarkMode call saveDarkMode when switch to true', () async {
      bool done = false;
      when(configRepository.saveDarkMode(true))
          .thenAnswer((_) async { done = true; return true;});
      await changeThemeService.switchDarkMode(true);
      expect(done, true);
    });

    test('switchDarkMode call saveDarkMode when switch to false', () async {
      bool done = false;
      when(configRepository.saveDarkMode(false))
          .thenAnswer((_) async { done = true; return true; });
      await changeThemeService.switchDarkMode(false);
      expect(done, true);
    });

    test('raise Exception when saveDarkMode failed', () async {
      final testDarkMode = false;
      when(configRepository.saveDarkMode(testDarkMode))
          .thenAnswer((_) async => false);
      expect(() async => await changeThemeService.switchDarkMode(testDarkMode),
          throwsException);
    });

    test('read saved darkMode when darkMode is false', () async {
      final testDarkMode = false;
      when(configRepository.readDarkMode())
          .thenAnswer((_) async => testDarkMode);
      expect(await changeThemeService.readDarkMode(), testDarkMode);
    });

    test('read saved darkMode when darkMode is true', () async {
      final testDarkMode = true;
      when(configRepository.readDarkMode())
          .thenAnswer((_) async => testDarkMode);
      expect(await changeThemeService.readDarkMode(), testDarkMode);
    });

    test('convert darkMode to false when darkMode is null', () async {
      final testDarkMode = null;
      when(configRepository.readDarkMode())
          .thenAnswer((_) async => testDarkMode);
      expect(await changeThemeService.readDarkMode(), false);
    });
  });
}
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

    test('switchDarkMode sets darkMode false to true', () async {
      final testDarkMode = true;

      bool darkMode = false;
      when(configRepository.saveDarkMode(testDarkMode))
          .thenAnswer((_) async => darkMode = testDarkMode);
      await changeThemeService.switchDarkMode(testDarkMode);
      expect(darkMode, true);
    });

    test('switchDarkMode sets darkMode true to false', () async {
      final testDarkMode = false;
      bool darkMode = true;
      when(configRepository.saveDarkMode(testDarkMode))
          .thenAnswer((_) async => darkMode = testDarkMode);
      await changeThemeService.switchDarkMode(testDarkMode);
      expect(darkMode, false);
    });

    test('raise Exception when saveDarkMode failed', () async {
      final testDarkMode = false;
      when(configRepository.saveDarkMode(testDarkMode))
          .thenAnswer((_) async => false);
      expect(() async => await changeThemeService.switchDarkMode(testDarkMode),
          throwsException);
    });
  });
}
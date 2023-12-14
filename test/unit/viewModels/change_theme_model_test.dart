import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/usecase/change_theme_service_interface.dart';
import 'package:throwtrash/viewModels/change_theme_model.dart';

import 'change_theme_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ChangeThemeServiceInterface>()])
void main () {
    group('ChangeThemeModel', () {
        late MockChangeThemeServiceInterface changeThemeService;
        late ChangeThemeModel changeThemeModel;

        setUp(() {
            changeThemeService = MockChangeThemeServiceInterface();
            changeThemeModel = ChangeThemeModel(changeThemeService);
        });

        test('switchDarkMode sets darkMode false to true', () async {
            final testDarkMode = false;

            when(changeThemeService.readDarkMode())
                .thenAnswer((_) async => testDarkMode);
            when(changeThemeService.switchDarkMode(testDarkMode))
                .thenAnswer((_) async => testDarkMode);

            bool done = false;
            changeThemeModel.addListener(() {
                done = true;
            });

            await changeThemeModel.init();
            await changeThemeModel.switchDarkMode();

            expect(changeThemeModel.darkMode, true);
            expect(done, true);
        });

        test('switchDarkMode sets darkMode true to false', () async {
            final testDarkMode = true;

            when(changeThemeService.readDarkMode())
                .thenAnswer((_) async => testDarkMode);
            when(changeThemeService.switchDarkMode(testDarkMode))
                .thenAnswer((_) async => testDarkMode);

            bool done = false;
            changeThemeModel.addListener(() {
                done = true;
            });
            await changeThemeModel.init();
            await changeThemeModel.switchDarkMode();

            expect(changeThemeModel.darkMode, false);
            expect(done, true);
        });
    });
}
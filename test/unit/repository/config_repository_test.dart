import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/repository/config_repository.dart';

import 'config_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  MockSharedPreferences preferences = MockSharedPreferences();
  late final ConfigRepository configRepository;
  setUpAll(() {
    ConfigRepository.initialize(preferences);
    configRepository = ConfigRepository();
  });
  group("saveDarkMode", () {
    test("正常に保存", () async {
      when(preferences.setBool(ConfigRepository.DARK_MODE_KEY, true))
          .thenAnswer((_) async => true);
      await configRepository.saveDarkMode(true).then((result) {
        expect(result, isTrue);
      });
    });
    test("保存に失敗", () async {
      when(preferences.setBool(ConfigRepository.DARK_MODE_KEY, false))
          .thenAnswer((_) async => false);
      await configRepository.saveDarkMode(false).then((result) {
        expect(result, isFalse);
      });
    });
  });
  group("readDarkMode", () {
    test("保存されている値がtrue", () async {
      when(preferences.getBool(ConfigRepository.DARK_MODE_KEY)).thenReturn(true);
      await configRepository.readDarkMode().then((result) {
        expect(result, isTrue);
      });
    });
    test("保存されている値がfalse", () async {
      when(preferences.getBool(ConfigRepository.DARK_MODE_KEY)).thenReturn(false);
      await configRepository.readDarkMode().then((result) {
        expect(result, isFalse);
      });
    });
    test("保存されている値がnull", () async {
      when(preferences.getBool(ConfigRepository.DARK_MODE_KEY)).thenReturn(null);
      await configRepository.readDarkMode().then((result) {
        expect(result, isNull);
      });
    });
  });
  group("getDeviceToken", () {
    test("保存されている値が存在する", () async {
      when(preferences.getString(ConfigRepository.DEVICE_TOKEN_KEY))
          .thenReturn("test_token");
      await configRepository.getDeviceToken().then((result) {
        expect(result, "test_token");
      });
    });
    test("保存されている値が存在しない", () async {
      when(preferences.getString(ConfigRepository.DEVICE_TOKEN_KEY))
          .thenReturn(null);
      await configRepository.getDeviceToken().then((result) {
        expect(result, isNull);
      });
    });
  });
  group("saveDeviceToken", () {
    test("正常に保存", () async {
      when(preferences.setString(ConfigRepository.DEVICE_TOKEN_KEY, "test_token"))
          .thenAnswer((_) async => true);
      await configRepository.saveDeviceToken("test_token").then((result) {
        expect(result, isTrue);
      });
    });
    test("保存に失敗", () async {
      when(preferences.setString(ConfigRepository.DEVICE_TOKEN_KEY, "test_token"))
          .thenAnswer((_) async => false);
      await configRepository.saveDeviceToken("test_token").then((result) {
        expect(result, isFalse);
      });
    });
  });
  group("initialize", () {
    test("initializeが繰り返し実行された場合はStateErrorが発生すること", () {
      expect(() => ConfigRepository.initialize(preferences),
          throwsStateError);
    });
  });
}
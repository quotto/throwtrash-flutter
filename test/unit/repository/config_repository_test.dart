import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/repository/config_repository.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group("ConfigRepository", () {
    test("saveDarkMode as true", () async {
      ConfigRepository repository = ConfigRepository();
      await repository.saveDarkMode(true).then((result) {
        expect(result, true);
      });
    });
    test("saveDarkMode as false", () async {
      ConfigRepository repository = ConfigRepository();
      await repository.saveDarkMode(false).then((result) {
        expect(result, true);
      });
    });
    test("readDarkMode as true", () async {
      await SharedPreferences.getInstance().then((value) {
        value.setBool(ConfigRepository.DARK_MODE_KEY, true);
      });
      ConfigRepository repository = ConfigRepository();
      await repository.readDarkMode().then((result) {
        expect(result, true);
      });
    });
    test("readDarkMode as false", () async {
      await SharedPreferences.getInstance().then((value) {
        value.setBool(ConfigRepository.DARK_MODE_KEY, false);
      });
      ConfigRepository repository = ConfigRepository();
      await repository.readDarkMode().then((result) {
        expect(result, false);
      });
    });
    test("readDarkMode as null", () async {
      ConfigRepository repository = ConfigRepository();
      await repository.readDarkMode().then((result) {
        expect(result, null);
      });
    });
  });
}
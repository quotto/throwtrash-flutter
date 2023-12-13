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
  });
}
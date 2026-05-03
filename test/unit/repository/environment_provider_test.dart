import 'package:flutter_test/flutter_test.dart';
import 'package:throwtrash/repository/environment_provider.dart';

void main() {
  group('EnvironmentProvider', () {
    test('dart-define未指定時はdevelopmentを返す', () async {
      await EnvironmentProvider.initialize();
      final provider = EnvironmentProvider();
      expect(provider.flavor, 'development');
    });
  });
}

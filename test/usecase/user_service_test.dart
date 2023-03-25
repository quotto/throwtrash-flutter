import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/repository/user_repository.dart';
import 'package:throwtrash/usecase/user_service.dart';

import 'user_service_test.mocks.dart';


@GenerateMocks([UserRepository])
void main() {
  group('UserService', () {
    late UserRepository userRepository;
    late UserService userService;
    final testDeviceToken = 'test_device_token';

    setUp(() {
      userRepository = MockUserRepository();
      userService = UserService(userRepository);
      when(userRepository.readUserId()).thenAnswer((_) async => '');
      when(userRepository.readDeviceToken()).thenAnswer((_) async => testDeviceToken);
    });


    test('refreshUser updates the user object correctly', () async {
      final testId = 'test_id';

      when(userRepository.readUserId()).thenAnswer((_) async => testId);

      await userService.refreshUser();

      expect(userService.user.id, testId);
      expect(userService.user.deviceToken, testDeviceToken);
    });

    test('registerUser successfully registers a user and updates the user object', () async {
      final testId = 'test_id';
      when(userRepository.readUserId()).thenAnswer((_) async => testId);
      when(userRepository.writeUserId(testId)).thenAnswer((_) async => true);

      final result = await userService.registerUser(testId);

      expect(result, true);
      expect(userService.user.id, testId);
    });

    test('registerUser fails to register a user and does not update the user object', () async {
      final testId = 'test_id';
      when(userRepository.writeUserId(testId)).thenAnswer((_) async => false);

      final result = await userService.registerUser(testId);

      expect(result, false);
      expect(userService.user.id, '');
    });
  });
}

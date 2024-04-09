import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/user_service.dart';

import 'user_service_test.mocks.dart';


@GenerateMocks([UserRepositoryInterface])
void main() {
  group('UserService', () {
    late MockUserRepositoryInterface userRepository;
    late UserService userService;

    setUp(() {
      userRepository = MockUserRepositoryInterface();
      userService = UserService(userRepository);
      when(userRepository.readUser()).thenAnswer((_) async => User('test'));
    });


    test('refreshUser updates the user object correctly', () async {
      final testId = 'test_id';

      when(userRepository.readUser()).thenAnswer((_) async => User(testId));

      await userService.refreshUser();

      expect(userService.user.id, testId);
    });

    test('registerUser successfully registers a user and updates the user object', () async {
      final user = User('test_id');
      when(userRepository.readUser()).thenAnswer((_) async => user);
      when(userRepository.writeUser(any)).thenAnswer((_) async => true);
      final result = await userService.registerUser(user.id);

      expect(result, true);
      expect(userService.user.id, user.id);
    });

    test('registerUser fails to register a user and does not update the user object', () async {
      final testId = 'test_id';
      when(userRepository.writeUser(any)).thenAnswer((_) async => false);

      final result = await userService.registerUser(testId);

      expect(result, false);
      expect(userService.user.id, '');
    });
  });
}

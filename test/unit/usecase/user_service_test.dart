import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/repository/user_api_interface.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';
import 'package:throwtrash/usecase/user_service.dart';

import 'user_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepositoryInterface>(), MockSpec<UserApiInterface>(), MockSpec<TrashRepositoryInterface>(), MockSpec<auth.FirebaseAuth>(), MockSpec<GoogleSignIn>(), MockSpec<auth.User>()])
void main() {
  group('UserService', () {
    late MockUserRepositoryInterface userRepository;
    late MockUserApiInterface userApi;
    late MockTrashRepositoryInterface trashRepository;
    late MockFirebaseAuth firebaseAuth;
    late MockGoogleSignIn googleSignIn;
    late MockUser firebaseUser;
    late UserService userService;

    setUp(() {
      userRepository = MockUserRepositoryInterface();
      userApi = MockUserApiInterface();
      trashRepository = MockTrashRepositoryInterface();
      firebaseAuth = MockFirebaseAuth();
      googleSignIn = MockGoogleSignIn();
      firebaseUser = MockUser();

      // Firebaseの動作をモック
      when(firebaseAuth.currentUser).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('mock_uid');

      userService = UserService(
        userRepository,
        userApi,
        trashRepository,
        firebaseAuth: firebaseAuth,
        googleSignIn: googleSignIn
      );

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

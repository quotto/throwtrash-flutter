import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/repository/fcm_service.dart';
import 'package:throwtrash/usecase/config_repository_interface.dart';

import 'fcm_service.test.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseMessaging>(), MockSpec<ConfigRepositoryInterface>() ])
void main() {
  group('FcmService', () {
    late MockFirebaseMessaging firebaseMessaging;
    late MockConfigRepositoryInterface configRepository;
    late FcmService fcmService;

    setUp(() {
      firebaseMessaging = MockFirebaseMessaging();
      configRepository = MockConfigRepositoryInterface();
      fcmService = FcmService(firebaseMessaging, configRepository);
    });

    group('refreshDeviceToken', () {
      test('保存されたトークンが無い状態でデバイストークンの取得に成功', () async {
        when(configRepository.getDeviceToken()).thenAnswer((_) async => null);
        when(firebaseMessaging.getToken()).thenAnswer((_) async => 'test_token');
        when(configRepository.saveDeviceToken(any)).thenAnswer((_) async => true);

        final result = await fcmService.refreshDeviceToken();
        expect(result, 'test_token');
        verify(configRepository.saveDeviceToken('test_token')).called(1);
      });
      test('保存されたトークンがある状態でデバイストークンの更新に成功', () async {
        when(configRepository.getDeviceToken()).thenAnswer((_) async => 'old_test_token');
        when(firebaseMessaging.getToken()).thenAnswer((_) async => 'test_token');
        when(configRepository.saveDeviceToken(any)).thenAnswer((_) async => true);

        final result = await fcmService.refreshDeviceToken();
        expect(result, 'test_token');
        verify(configRepository.saveDeviceToken('test_token'));
      });
      test('保存されたトークンと取得したトークンが同じ場合は更新処理を行わない', () async {
        when(configRepository.getDeviceToken()).thenAnswer((_) async => 'test_token');
        when(firebaseMessaging.getToken()).thenAnswer((_) async => 'test_token');

        final result = await fcmService.refreshDeviceToken();
        expect(result, 'test_token');
        verifyNever(configRepository.saveDeviceToken(any));
      });
      test('デバイストークンの取得に失敗', () async {
        when(firebaseMessaging.getToken()).thenAnswer((_) async => null);

        expect(() async => await fcmService.refreshDeviceToken(), throwsException);
      });
    });
  });
}

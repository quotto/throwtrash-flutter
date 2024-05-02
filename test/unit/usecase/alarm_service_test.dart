import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/models/user.dart';
import 'package:throwtrash/usecase/repository/alarm_api_interface.dart';
import 'package:throwtrash/usecase/repository/alarm_repository_interface.dart';
import 'package:throwtrash/usecase/alarm_service.dart';
import 'package:throwtrash/usecase/repository/config_repository_interface.dart';
import 'package:throwtrash/usecase/repository/fcm_interface.dart';
import 'package:throwtrash/usecase/repository/user_repository_interface.dart';

import 'alarm_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AlarmRepositoryInterface>(), MockSpec<AlarmApiInterface>(), MockSpec<ConfigRepositoryInterface>(), MockSpec<FcmInterface>(), MockSpec<UserRepositoryInterface>()])
void main() async {
  group('AlarmService', () {
    late MockAlarmRepositoryInterface alarmRepository;
    late MockAlarmApiInterface api;
    late MockConfigRepositoryInterface configRepository;
    late MockFcmInterface fcm;
    late MockUserRepositoryInterface userRepository;
    late AlarmService alarmService;

    setUp(() {
      alarmRepository = MockAlarmRepositoryInterface();
      api = MockAlarmApiInterface();
      configRepository = MockConfigRepositoryInterface();
      fcm = MockFcmInterface();
      userRepository = MockUserRepositoryInterface();
      alarmService = AlarmService(alarmRepository, api, configRepository, fcm, userRepository);
    });

    group('getAlarm',() {
      test('正常にアラーム情報が取得される', () async {
        final testAlarm = Alarm(12, 30, true);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => testAlarm);

        Alarm result = await alarmService.getAlarm();
        expect(result.hour, testAlarm.hour);
        expect(result.minute, testAlarm.minute);
        expect(result.isEnable, testAlarm.isEnable);
      });
      test('アラームが設定されていない場合はデフォルト値が返却される', () async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => null);

        Alarm result = await alarmService.getAlarm();
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.isEnable, false);
      });
    });

    group('changeAlarmTime',() {
      test('正常にアラーム時間が更新される', () async {
        final testHour = 12;
        final testMinute = 30;

        when(alarmRepository.readAlarm()).thenAnswer((_) async =>
            Alarm(0, 0, true));
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => true);
        when(api.changeAlarm(any, any)).thenAnswer((_) async => true);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'test_token');

        bool result = await alarmService.changeAlarmTime(hour: testHour, minute: testMinute);
        expect(result, true);

        verify(fcm.refreshDeviceToken()).called(1);
        final verificationChangeAlarm = verify(api.changeAlarm(captureAny, captureAny)).captured;
        expect((verificationChangeAlarm[0] as Alarm).hour, testHour);
        expect((verificationChangeAlarm[0] as Alarm).minute, testMinute);
        expect((verificationChangeAlarm[0] as Alarm).isEnable, true);
        expect((verificationChangeAlarm[1] as String), 'test_token');
        final verificationSaveAlarm = verify(alarmRepository.saveAlarm(captureAny)).captured;
        expect((verificationSaveAlarm[0] as Alarm).hour, testHour);
        expect((verificationSaveAlarm[0] as Alarm).minute, testMinute);
        expect((verificationSaveAlarm[0] as Alarm).isEnable, true);
      });
      test('アラームが設定されていない場合はエラーが発生する', () async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => null);

        expect(() async => await alarmService.changeAlarmTime(hour: 12, minute: 30), throwsException);
        verifyNever(fcm.refreshDeviceToken());
        verifyNever(api.changeAlarm(any, any));
        verifyNever(alarmRepository.saveAlarm(any));
      });
      test('アラームが無効に設定されている場合はエラーが発生する',() async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(0, 0, false));

        expect(() async => await alarmService.changeAlarmTime(hour: 12, minute: 30), throwsException);
        verifyNever(fcm.refreshDeviceToken());
        verifyNever(api.changeAlarm(any, any));
        verifyNever(alarmRepository.saveAlarm(any));
      });
      test('APIの呼び出しに失敗した場合はローカルデータの更新は行われない', () async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(0, 0, true));
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'test_token');
        when(api.changeAlarm(any, any)).thenAnswer((_) async => false);

        bool result = await alarmService.changeAlarmTime(hour: 12, minute: 30);
        expect(result, false);

        verify(fcm.refreshDeviceToken()).called(1);
        verify(api.changeAlarm(any, any)).called(1);
        verifyNever(alarmRepository.saveAlarm(any));
      });
      test('ローカルデータの更新に失敗',() async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(0, 0, true));
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'test_token');
        when(api.changeAlarm(any, any)).thenAnswer((_) async => true);
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => false);

        bool result = await alarmService.changeAlarmTime(hour: 12, minute: 30);
        expect(result, false);

        verify(fcm.refreshDeviceToken()).called(1);
        verify(api.changeAlarm(any, any)).called(1);
        verify(alarmRepository.saveAlarm(any)).called(1);
      });
    });
    group('reRegisterAlarm',()
    {
      test('デバイストークンが登録済みでかつアラームが有効な状態で新しいデバイストークンが検出された場合は再登録が実行される', () async {
        final testUser = User('test_id');
        final savedAlarm = Alarm(12, 30, true);
        final oldToken = 'old_token';
        final newToken = 'new_token';
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => newToken);
        when(configRepository.getDeviceToken()).thenAnswer((_) async => oldToken);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => savedAlarm);
        when(api.setAlarm(any, any, any)).thenAnswer((_) async => true);
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => true);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => savedAlarm);
        when(api.setAlarm(any, any, any)).thenAnswer((_) async => true);
        when(api.cancelAlarm(any)).thenAnswer((_) async => true);
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => true);

        await alarmService.reRegisterAlarm();

        verify(alarmRepository.readAlarm()).called(1);
        verify(userRepository.readUser()).called(1);
        verify(fcm.refreshDeviceToken()).called(1);
        verify(api.cancelAlarm(oldToken)).called(1);
        verify(api.setAlarm(savedAlarm, newToken, any)).called(1);
      });
      test('デバイストークンが登録済みでかつアラームが無効な状態で新しいデバイストークンが検出された場合は再登録が実行されない', () async {
        final testUser = User('test_id');
        final savedAlarm = Alarm(12, 30, false);
        final oldToken = 'old_token';
        final newToken = 'new_token';
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => newToken);
        when(configRepository.getDeviceToken()).thenAnswer((
            _) async => oldToken);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => savedAlarm);

        await alarmService.reRegisterAlarm();
        verify(alarmRepository.readAlarm()).called(1);
        verify(userRepository.readUser()).called(1);
        verifyNever(fcm.refreshDeviceToken());
        verifyNever(api.cancelAlarm(any));
        verifyNever(api.setAlarm(any, any, any));
      });
      test('デバイストークンが登録済みでかつアラームが有効な状態で新しいデバイストークンが検出されない場合は再登録は行わない', () async {
        final testUser = User('test_id');
        final savedAlarm = Alarm(12, 30, true);
        final oldToken = 'old_token';
        final newToken = 'old_token';
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => newToken);
        when(configRepository.getDeviceToken()).thenAnswer((_) async => oldToken);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => savedAlarm);

        await alarmService.reRegisterAlarm();
        verify(alarmRepository.readAlarm()).called(1);
        verify(userRepository.readUser()).called(1);
        verify(fcm.refreshDeviceToken()).called(1);
        verifyNever(api.cancelAlarm(any));
        verifyNever(api.setAlarm(any, any, any));
      });
      test('アラーム情報が取得できない場合は再登録は行わない', () async {
        final testUser = User('test_id');
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => null);

        await alarmService.reRegisterAlarm();
        verify(alarmRepository.readAlarm()).called(1);
        verify(userRepository.readUser()).called(1);
        verifyNever(fcm.refreshDeviceToken());
        verifyNever(api.cancelAlarm(any));
        verifyNever(api.setAlarm(any, any, any));
      });

      test('ユーザー情報が取得できない場合はエラーが発生する', () async {
        when(userRepository.readUser()).thenAnswer((_) async => null);

        expect(() async => await alarmService.reRegisterAlarm(),
            throwsException);
        verifyNever(fcm.refreshDeviceToken());
        verifyNever(api.setAlarm(any, any, any));
        verifyNever(alarmRepository.saveAlarm(any));
      });
      test('デバイストークンの取得に失敗した場合はエラーが発生する', () async {
        final testUser = User('test_id');
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(12, 30, true));
        when(fcm.refreshDeviceToken()).thenThrow(Exception());

        expect(() async => await alarmService.reRegisterAlarm(),
            throwsException);
        verifyNever(api.setAlarm(any, any, any));
        verifyNever(alarmRepository.saveAlarm(any));
      });
      test('アラーム情報の取得に失敗した場合はエラーが発生する', () async {
        final testUser = User('test_id');
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'test_token');
        when(alarmRepository.readAlarm()).thenThrow(Exception());

        expect(() async => await alarmService.reRegisterAlarm(),
            throwsException);
      });
    });
  });
}

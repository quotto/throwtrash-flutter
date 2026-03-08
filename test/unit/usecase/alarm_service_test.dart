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
        final testAlarm = Alarm(12, 30, true, true);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => testAlarm);

        Alarm result = await alarmService.getAlarm();
        expect(result.hour, testAlarm.hour);
        expect(result.minute, testAlarm.minute);
        expect(result.isEnable, testAlarm.isEnable);
        expect(result.nextDayNotificationEnabled, true);
      });

      test('アラームが設定されていない場合はデフォルト値が返却される', () async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => null);

        Alarm result = await alarmService.getAlarm();
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.isEnable, false);
        expect(result.nextDayNotificationEnabled, false);
      });
    });

    group('changeAlarmTime',() {
      test('正常にアラーム時間と翌日通知状態が更新される', () async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(0, 0, true, false));
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => true);
        when(api.changeAlarm(any, any)).thenAnswer((_) async => true);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'test_token');

        bool result = await alarmService.changeAlarmTime(hour: 12, minute: 30, nextDayNotificationEnabled: true);
        expect(result, true);

        final verificationChangeAlarm = verify(api.changeAlarm(captureAny, captureAny)).captured;
        expect((verificationChangeAlarm[0] as Alarm).hour, 12);
        expect((verificationChangeAlarm[0] as Alarm).minute, 30);
        expect((verificationChangeAlarm[0] as Alarm).isEnable, true);
        expect((verificationChangeAlarm[0] as Alarm).nextDayNotificationEnabled, true);
        expect((verificationChangeAlarm[1] as String), 'test_token');
      });

      test('アラームが無効の場合はエラーが発生する',() async {
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(0, 0, false));

        expect(
          () async => await alarmService.changeAlarmTime(hour: 12, minute: 30, nextDayNotificationEnabled: false),
          throwsException,
        );
        verifyNever(fcm.refreshDeviceToken());
        verifyNever(api.changeAlarm(any, any));
      });
    });

    group('enableAlarm', () {
      test('翌日通知状態を含めて有効化できる', () async {
        when(userRepository.readUser()).thenAnswer((_) async => User('test_id'));
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'test_token');
        when(api.setAlarm(any, any, any)).thenAnswer((_) async => true);
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => true);

        final result = await alarmService.enableAlarm(hour: 6, minute: 40, nextDayNotificationEnabled: true);
        expect(result, true);

        final captured = verify(api.setAlarm(captureAny, captureAny, captureAny)).captured;
        final alarm = captured[0] as Alarm;
        expect(alarm.nextDayNotificationEnabled, true);
      });
    });

    group('cancelAlarm', () {
      test('翌日通知状態をローカルに保持したまま無効化できる', () async {
        when(configRepository.getDeviceToken()).thenAnswer((_) async => 'device_token');
        when(api.cancelAlarm('device_token')).thenAnswer((_) async => true);
        when(alarmRepository.readAlarm()).thenAnswer((_) async => Alarm(7, 0, true, false));
        when(alarmRepository.saveAlarm(any)).thenAnswer((_) async => true);

        final result = await alarmService.cancelAlarm(nextDayNotificationEnabled: true);
        expect(result, true);

        final savedAlarm = verify(alarmRepository.saveAlarm(captureAny)).captured.first as Alarm;
        expect(savedAlarm.isEnable, false);
        expect(savedAlarm.nextDayNotificationEnabled, true);
      });
    });

    group('reRegisterAlarm',() {
      test('有効状態でトークン変更時に再登録される', () async {
        final testUser = User('test_id');
        final savedAlarm = Alarm(12, 30, true, true);
        when(userRepository.readUser()).thenAnswer((_) async => testUser);
        when(fcm.refreshDeviceToken()).thenAnswer((_) async => 'new_token');
        when(configRepository.getDeviceToken()).thenAnswer((_) async => 'old_token');
        when(alarmRepository.readAlarm()).thenAnswer((_) async => savedAlarm);
        when(api.cancelAlarm(any)).thenAnswer((_) async => true);
        when(api.setAlarm(any, any, any)).thenAnswer((_) async => true);

        await alarmService.reRegisterAlarm();

        verify(api.cancelAlarm('old_token')).called(1);
        verify(api.setAlarm(savedAlarm, 'new_token', any)).called(1);
      });
    });
  });
}

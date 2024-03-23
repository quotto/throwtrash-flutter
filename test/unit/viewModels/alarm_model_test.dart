
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/viewModels/alarm_model.dart';

import 'alarm_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AlarmServiceInterface>()])
void main() {
  final MockAlarmServiceInterface alarmService = MockAlarmServiceInterface();
  late AlarmModel alarmModel;

  setUp(() {
    alarmModel = AlarmModel(alarmService);
  });

  group('initialize', () {
    test('初期化のテスト', () async {
      when(alarmService.getAlarm())
        .thenAnswer((_) async => Alarm(12, 30, true));

      await alarmModel.initialize();

      expect(alarmModel.hour, 12);
      expect(alarmModel.minute, 30);
      expect(alarmModel.isAlarmEnabled, true);
    });
  });
  group('toggleAlarmEnabled', () {
    test('アラームの有効無効を切り替える-初期状態が有効', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(12, 30, true));

      await alarmModel.initialize();
      alarmModel.toggleAlarmEnabled();
      expect(alarmModel.isAlarmEnabled, false);

      alarmModel.toggleAlarmEnabled();
      expect(alarmModel.isAlarmEnabled, true);
    });
    test('アラームの有効無効を切り替える-初期状態が無効', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(12, 30, false));

      await alarmModel.initialize();
      alarmModel.toggleAlarmEnabled();
      expect(alarmModel.isAlarmEnabled, true);

      alarmModel.toggleAlarmEnabled();
      expect(alarmModel.isAlarmEnabled, false);
    });
  });
  group('setAlarmTime', () {
    test('アラームの時間を設定する', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));

      await alarmModel.initialize();
      alarmModel.setAlarmTime(12, 30);
      expect(alarmModel.hour, 12);
      expect(alarmModel.minute, 30);
    });
  });
  group('submitAlarmTime', () {
    test('アラームの新規有効化', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));
      when(alarmService.enableAlarm(hour: 0, minute: 0))
          .thenAnswer((_) async => true);

      await alarmModel.initialize();
      alarmModel.toggleAlarmEnabled();
      int done = 0;
      alarmModel.addListener(() {
        if(done == 0) {
          expect(alarmModel.submitState, AlarmSubmitState.SUBMITTING);
        }
        done++;
      });
      await alarmModel.submitAlarmTime();
      verify(alarmService.enableAlarm(hour: 0, minute: 0));
      expect(done, 2);
      expect(alarmModel.submitState, AlarmSubmitState.COMPLETE);
    });
    test('有効から無効に変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, true));
      when(alarmService.cancelAlarm())
          .thenAnswer((_) async => true);

      await alarmModel.initialize();
      alarmModel.toggleAlarmEnabled();
      bool done = false;
      alarmModel.addListener(() {
        done = true;
      });

      await alarmModel.submitAlarmTime();
      expect(done, true);
      verify(alarmService.cancelAlarm());
      expect(alarmModel.submitState, AlarmSubmitState.COMPLETE);
    });
    test('無効から有効に変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));
      when(alarmService.enableAlarm(hour: 0, minute: 0))
          .thenAnswer((_) async => true);

      await alarmModel.initialize();
      alarmModel.toggleAlarmEnabled();
      bool done = false;
      alarmModel.addListener(() {
        done = true;
      });

      await alarmModel.submitAlarmTime();
      expect(done, true);
      verify(alarmService.enableAlarm(hour: 0, minute: 0));
      expect(alarmModel.submitState, AlarmSubmitState.COMPLETE);
    });
    test('有効状態で時間を変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, true));
      when(alarmService.changeAlarmTime(hour: 12, minute: 30))
          .thenAnswer((_) async => true);

      await alarmModel.initialize();
      alarmModel.setAlarmTime(12, 30);
      bool done = false;
      alarmModel.addListener(() {
        done = true;
      });

      await alarmModel.submitAlarmTime();
      expect(done,true);
      verify(alarmService.changeAlarmTime(hour: 12, minute: 30));
      expect(alarmModel.submitState, AlarmSubmitState.COMPLETE);
    });
  });
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
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

  group('initialize', () {
    test('初期化のテスト', () async {
      when(alarmService.getAlarm()).thenAnswer((_) async => Alarm(12, 30, true, true));

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      expect(alarmModel.hour, 12);
      expect(alarmModel.minute, 30);
      expect(alarmModel.isAlarmEnabled, true);
      expect(alarmModel.nextDayNotificationEnabled, true);
    });
  });

  group('toggleNextDayNotificationEnabled', () {
    test('翌日通知の有効無効を切り替える', () async {
      when(alarmService.getAlarm()).thenAnswer((_) async => Alarm(12, 30, true, false));
      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor(() => alarmModel.toggleNextDayNotificationEnabled(), alarmModel);
      expect(alarmModel.nextDayNotificationEnabled, true);

      await _waitFor(() => alarmModel.toggleNextDayNotificationEnabled(), alarmModel);
      expect(alarmModel.nextDayNotificationEnabled, false);
    });
  });

  group('submitAlarmTime', () {
    test('新規有効化時に翌日通知フラグを渡す', () async {
      when(alarmService.getAlarm()).thenAnswer((_) async => Alarm(0, 0, false, false));
      when(alarmService.enableAlarm(hour: 0, minute: 0, nextDayNotificationEnabled: true))
          .thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      await _waitFor(() => alarmModel.toggleAlarmEnabled(), alarmModel);
      await _waitFor(() => alarmModel.toggleNextDayNotificationEnabled(), alarmModel);

      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.enableAlarm(hour: 0, minute: 0, nextDayNotificationEnabled: true));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });

    test('有効状態で更新時に翌日通知フラグを渡す', () async {
      when(alarmService.getAlarm()).thenAnswer((_) async => Alarm(0, 0, true, false));
      when(alarmService.changeAlarmTime(hour: 12, minute: 30, nextDayNotificationEnabled: true))
          .thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      await _waitFor(()=>alarmModel.setAlarmTime(12, 30), alarmModel);
      await _waitFor(() => alarmModel.toggleNextDayNotificationEnabled(), alarmModel);

      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.changeAlarmTime(hour: 12, minute: 30, nextDayNotificationEnabled: true));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });

    test('無効化時に翌日通知フラグを渡す', () async {
      when(alarmService.getAlarm()).thenAnswer((_) async => Alarm(0, 0, true, false));
      when(alarmService.cancelAlarm(nextDayNotificationEnabled: true)).thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      await _waitFor(() => alarmModel.toggleAlarmEnabled(), alarmModel);
      await _waitFor(() => alarmModel.toggleNextDayNotificationEnabled(), alarmModel);

      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.cancelAlarm(nextDayNotificationEnabled: true));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });
  });
}


/*
 * ChangeNotifierによるnotifyListenerの実行を待機するためのヘルパーメソッド
 * 使用例: await _waitFor((){alarmModel.initialize();}, alarmModel);
 */
Future<void> _waitFor(Function block, ChangeNotifier changeNotifier, {int count = 1}) async {
  final Completer completer = Completer();
  int completed = 0;
  final listener = () {
    completed++;
    if(completed == count) {
      completer.complete();
    }
  };
  changeNotifier.addListener(listener);
  block();
  // 完了を待機するためにawait指定が必要
  await completer.future.timeout(Duration(seconds: 2));
  changeNotifier.removeListener(listener);
}

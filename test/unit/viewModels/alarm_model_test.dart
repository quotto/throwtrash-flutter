
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

  setUp(() {
  });

  group('initialize', () {
    test('初期化のテスト', () async {
      when(alarmService.getAlarm())
        .thenAnswer((_) async => Alarm(12, 30, true));

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      expect(alarmModel.hour, 12);
      expect(alarmModel.minute, 30);
      expect(alarmModel.isAlarmEnabled, true);
    });
  });
  group('toggleAlarmEnabled', () {
    test('アラームの有効無効を切り替える-初期状態が有効', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(12, 30, true));

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor(()=>alarmModel.toggleAlarmEnabled(), alarmModel);
      expect(alarmModel.isAlarmEnabled, false);

      await _waitFor(()=>alarmModel.toggleAlarmEnabled(), alarmModel);
      expect(alarmModel.isAlarmEnabled, true);
    });
    test('アラームの有効無効を切り替える-初期状態が無効', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(12, 30, false));

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor(()=>alarmModel.toggleAlarmEnabled(), alarmModel);
      expect(alarmModel.isAlarmEnabled, true);

      await _waitFor(()=>alarmModel.toggleAlarmEnabled(), alarmModel);
      expect(alarmModel.isAlarmEnabled, false);
    });
  });
  group('setAlarmTime', () {
    test('アラームの時間を設定する', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor(()=>alarmModel.setAlarmTime(12, 30), alarmModel);
      expect(alarmModel.hour, 12);
      expect(alarmModel.minute, 30);
    });
  });
  group('submitAlarmTime', () {
    test('新規有効化', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));
      when(alarmService.enableAlarm(hour: 0, minute: 0))
          .thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor((){alarmModel.toggleAlarmEnabled();}, alarmModel);
      expect(alarmModel.isAlarmEnabled, true);

      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.enableAlarm(hour: 0, minute: 0));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });
    test('有効から無効に変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, true));
      when(alarmService.cancelAlarm())
          .thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor((){alarmModel.toggleAlarmEnabled();}, alarmModel);

      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.cancelAlarm());
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });
    test('無効から有効に変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));
      when(alarmService.enableAlarm(hour: 0, minute: 0))
          .thenAnswer((_) async => true);

      late AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);

      await _waitFor(()=>alarmModel.toggleAlarmEnabled(), alarmModel);

      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.enableAlarm(hour: 0, minute: 0));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });
    test('有効状態で時間を変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, true));
      when(alarmService.changeAlarmTime(hour: 12, minute: 30))
          .thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      await _waitFor(()=>alarmModel.setAlarmTime(12, 30), alarmModel);
      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.changeAlarmTime(hour: 12, minute: 30));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });
    test('有効状態で何も変更しない',() async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(12, 30, true));

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verify(alarmService.changeAlarmTime(hour: 12, minute: 30));
      expect(alarmModel.submitState, AlarmSubmitState.INIT);
    });
    test('無効状態で時間を変更', () async {
      when(alarmService.getAlarm())
          .thenAnswer((_) async => Alarm(0, 0, false));
      when(alarmService.changeAlarmTime(hour: 12, minute: 30))
          .thenAnswer((_) async => true);

      final AlarmModel alarmModel = AlarmModel(alarmService);
      await _waitFor((){alarmModel.initialize();}, alarmModel);
      await _waitFor(()=>alarmModel.setAlarmTime(12, 30), alarmModel);
      await _waitFor(()=>alarmModel.submitAlarmTime(), alarmModel, count: 2);
      verifyNever(alarmService.changeAlarmTime(hour: 12, minute: 30));
      verify(alarmService.cancelAlarm());
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
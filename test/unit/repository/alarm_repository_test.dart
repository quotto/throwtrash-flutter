import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/repository/alarm_repository.dart';

import 'alarm_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  MockSharedPreferences preferences = MockSharedPreferences();
  late final AlarmRepository alarmRepository;
  setUpAll(() {
    AlarmRepository.initialize(preferences);
    alarmRepository = AlarmRepository();
  });
  group("readAlarm", () {
    test("Alarmが保存されている場合はAlarmが取得できること", () async {
      when(preferences.getInt(AlarmRepository.ALARM_HOUR_KEY)).thenReturn(12);
      when(preferences.getInt(AlarmRepository.ALARM_MINUTE_KEY)).thenReturn(10);
      when(preferences.getBool(AlarmRepository.ALARM_ENABLED_KEY)).thenReturn(true);
      Alarm? result = await alarmRepository.readAlarm();
      expect(result, isNotNull);
      expect(result!.hour, 12);
      expect(result.minute, 10);
      expect(result.isEnable, true);
    });
    test("enabledがfalseの場合はAlarmのenabledがfalseであること", () async {
      when(preferences.getInt(AlarmRepository.ALARM_HOUR_KEY)).thenReturn(12);
      when(preferences.getInt(AlarmRepository.ALARM_MINUTE_KEY)).thenReturn(10);
      when(preferences.getBool(AlarmRepository.ALARM_ENABLED_KEY)).thenReturn(false);
      Alarm? result = await alarmRepository.readAlarm();
      expect(result, isNotNull);
      expect(result!.hour, 12);
      expect(result.minute, 10);
      expect(result.isEnable, false);
    });
    test("保存されているhourがnullの場合はNullが返ること", () async {
      when(preferences.getInt(AlarmRepository.ALARM_HOUR_KEY)).thenReturn(null);
      when(preferences.getInt(AlarmRepository.ALARM_MINUTE_KEY)).thenReturn(10);
      when(preferences.getBool(AlarmRepository.ALARM_ENABLED_KEY)).thenReturn(true);
      Alarm? result = await alarmRepository.readAlarm();
      expect(result, isNull);
    });
    test("保存されているminuteがnullの場合はNullが返ること", () async {
      when(preferences.getInt(AlarmRepository.ALARM_HOUR_KEY)).thenReturn(12);
      when(preferences.getInt(AlarmRepository.ALARM_MINUTE_KEY)).thenReturn(null);
      when(preferences.getBool(AlarmRepository.ALARM_ENABLED_KEY)).thenReturn(true);
      Alarm? result = await alarmRepository.readAlarm();
      expect(result, isNull);
    });
    test("保存されているenabledがnullの場合はNullが返ること", () async {
      when(preferences.getInt(AlarmRepository.ALARM_HOUR_KEY)).thenReturn(12);
      when(preferences.getInt(AlarmRepository.ALARM_MINUTE_KEY)).thenReturn(10);
      when(preferences.getBool(AlarmRepository.ALARM_ENABLED_KEY)).thenReturn(null);
      Alarm? result = await alarmRepository.readAlarm();
      expect(result, isNull);
    });
    test("保存されているhour, minute, enabledがnullの場合はNullが返ること", () async {
      when(preferences.getInt(AlarmRepository.ALARM_HOUR_KEY)).thenReturn(null);
      when(preferences.getInt(AlarmRepository.ALARM_MINUTE_KEY)).thenReturn(null);
      when(preferences.getBool(AlarmRepository.ALARM_ENABLED_KEY)).thenReturn(null);
      Alarm? result = await alarmRepository.readAlarm();
      expect(result, isNull);
    });
  });
  group("saveAlarm", () {
    test("enabledがtrueの場合にAlarmが保存できること", () async {
      when(preferences.setInt(AlarmRepository.ALARM_HOUR_KEY, 12)).thenAnswer((
          _) async => true);
      when(preferences.setInt(AlarmRepository.ALARM_MINUTE_KEY, 10))
          .thenAnswer((_) async => true);
      when(preferences.setBool(AlarmRepository.ALARM_ENABLED_KEY, true))
          .thenAnswer((_) async => true);
      bool result = await alarmRepository.saveAlarm(Alarm(12, 10, true));
      expect(result, isTrue);
    });
    test("enabledがfalseの場合にAlarmが保存できること", () async {
      when(preferences.setInt(AlarmRepository.ALARM_HOUR_KEY, 12)).thenAnswer((
          _) async => true);
      when(preferences.setInt(AlarmRepository.ALARM_MINUTE_KEY, 10))
          .thenAnswer((_) async => true);
      when(preferences.setBool(AlarmRepository.ALARM_ENABLED_KEY, false))
          .thenAnswer((_) async => true);
      bool result = await alarmRepository.saveAlarm(Alarm(12, 10, false));
      expect(result, isTrue);
    });
    test("hourの保存に失敗した場合はfalseが返ること", () async {
      when(preferences.setInt(AlarmRepository.ALARM_HOUR_KEY, 12)).thenAnswer((
          _) async => false);
      when(preferences.setInt(AlarmRepository.ALARM_MINUTE_KEY, 10))
          .thenAnswer((_) async => true);
      when(preferences.setBool(AlarmRepository.ALARM_ENABLED_KEY, true))
          .thenAnswer((_) async => true);
      bool result = await alarmRepository.saveAlarm(Alarm(12, 10, true));
      expect(result, isFalse);
    });
    test("minuteの保存に失敗した場合はfalseが返ること", () async {
      when(preferences.setInt(AlarmRepository.ALARM_HOUR_KEY, 12)).thenAnswer((
          _) async => true);
      when(preferences.setInt(AlarmRepository.ALARM_MINUTE_KEY, 10))
          .thenAnswer((_) async => false);
      when(preferences.setBool(AlarmRepository.ALARM_ENABLED_KEY, true))
          .thenAnswer((_) async => true);
      bool result = await alarmRepository.saveAlarm(Alarm(12, 10, true));
      expect(result, isFalse);
    });
    test("enabledの保存に失敗した場合はfalseが返ること", () async {
      when(preferences.setInt(AlarmRepository.ALARM_HOUR_KEY, 12)).thenAnswer((
          _) async => true);
      when(preferences.setInt(AlarmRepository.ALARM_MINUTE_KEY, 10))
          .thenAnswer((_) async => true);
      when(preferences.setBool(AlarmRepository.ALARM_ENABLED_KEY, true))
          .thenAnswer((_) async => false);
      bool result = await alarmRepository.saveAlarm(Alarm(12, 10, true));
      expect(result, isFalse);
    });
  });
  group("initialize", () {
    test("initializeが繰り返し呼ばれた場合はエラーが発生すること", () async {
      expect(() => AlarmRepository.initialize(preferences), throwsStateError);
    });
  });
}
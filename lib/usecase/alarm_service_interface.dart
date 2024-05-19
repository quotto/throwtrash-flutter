import '../models/alarm.dart';

abstract class AlarmServiceInterface {
  Future<void> reRegisterAlarm();
  Future<bool> enableAlarm({required int hour, required int minute});
  Future<bool> cancelAlarm();
  Future<bool> changeAlarmTime({required int hour, required int minute});
  Future<Alarm> getAlarm();
}
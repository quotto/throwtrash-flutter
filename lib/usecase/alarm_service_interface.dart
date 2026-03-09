import '../models/alarm.dart';

abstract class AlarmServiceInterface {
  Future<void> reRegisterAlarm();
  Future<bool> enableAlarm({required int hour, required int minute, required bool nextDayNotificationEnabled});
  Future<bool> cancelAlarm({bool? nextDayNotificationEnabled});
  Future<bool> changeAlarmTime({required int hour, required int minute, required bool nextDayNotificationEnabled});
  Future<Alarm> getAlarm();
}

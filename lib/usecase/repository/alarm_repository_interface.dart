import '../../models/alarm.dart';

abstract class AlarmRepositoryInterface {
  Future<bool> saveAlarm(Alarm alarm);
  Future<Alarm?> readAlarm();
}
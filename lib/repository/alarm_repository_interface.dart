import 'package:throwtrash/models/alarm.dart';

abstract class AlarmRepositoryInterface {
  Future<bool> setAlarm(Alarm alarm);
  Future<Alarm?> getAlarm();
}
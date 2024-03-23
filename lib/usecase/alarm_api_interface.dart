import '../models/alarm.dart';
import '../models/user.dart';

abstract class AlarmApiInterface {
  Future<bool> setAlarm(Alarm alarm, String deviceToken, User user);
  Future<bool> cancelAlarm(String deviceToken);
  Future<bool> changeAlarm(Alarm alarm, String deviceToken);
}
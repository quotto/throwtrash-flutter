import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/models/trash_data.dart';
abstract class AlarmServiceInterface {
  bool isEnabledToUseAlarm();
  Future<bool> setAlarm(Alarm alarm);
  Future<void> reserveNextAlarm();
  String createAlarmMessage(List<TrashData> allTrashData);
}
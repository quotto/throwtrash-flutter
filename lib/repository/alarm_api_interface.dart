import 'package:throwtrash/models/alarm.dart';

abstract class AlarmApiInterface {
  // hour: ローカル時間, minute: ローカル分
  // 引数で渡された時間をUTC時間に変換して登録する
  Future<bool> updateAlarm(String deviceToken, Alarm alarm);
}